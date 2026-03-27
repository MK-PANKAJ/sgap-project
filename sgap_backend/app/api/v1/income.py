"""
Income API — Voice logging, entry confirmation with fraud detection,
income records, monthly summaries, and certificates.
"""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import func, extract
from app.database import get_db
from app.models.user import WorkerProfile
from app.models.income_record import IncomeRecord
from app.utils.security import get_current_user
from app.utils.hash_utils import generate_income_record_hash
from app.services.voice_service import voice_service
from app.services.certificate_service import generate_certificate
from app.ml.fraud_detection_model import fraud_model
from pydantic import BaseModel
from typing import Optional
from datetime import datetime, date, timedelta
import logging

logger = logging.getLogger(__name__)
router = APIRouter()


# ── Request schemas ──────────────────────────────────────────────────


class VoiceLogRequest(BaseModel):
    audio_base64: str
    language: Optional[str] = "hi"


class ConfirmEntryRequest(BaseModel):
    worker_id: str
    amount: float
    work_date: str  # YYYY-MM-DD
    work_type: Optional[str] = "Other"
    employer_name: Optional[str] = ""
    employer_phone: Optional[str] = ""
    work_description: Optional[str] = ""
    hours_worked: Optional[float] = None
    gps_latitude: Optional[float] = None
    gps_longitude: Optional[float] = None
    gps_accuracy_meters: Optional[float] = None
    voice_transcription: Optional[str] = ""


# ── Endpoints ────────────────────────────────────────────────────────


@router.post("/voice-log")
async def voice_log(
    request: VoiceLogRequest,
    current_user: dict = Depends(get_current_user),
):
    """Send audio to Bhashini STT → extract amount, employer, work type."""
    result = await voice_service.process_voice(
        request.audio_base64, request.language
    )
    return result


@router.post("/confirm-entry")
def confirm_entry(
    request: ConfirmEntryRequest,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    Confirm a parsed income entry:
      1. Run fraud detection
      2. Generate integrity hash
      3. Save to DB
      4. Update worker aggregates
    """
    # Verify worker exists
    worker = db.query(WorkerProfile).filter(
        WorkerProfile.id == request.worker_id
    ).first()
    if not worker:
        raise HTTPException(status_code=404, detail="Worker not found")

    # Count today's entries for fraud features
    today_count = db.query(IncomeRecord).filter(
        IncomeRecord.worker_id == request.worker_id,
        IncomeRecord.work_date == date.fromisoformat(request.work_date),
    ).count()

    # Last entry gap
    last_entry = db.query(IncomeRecord).filter(
        IncomeRecord.worker_id == request.worker_id,
    ).order_by(IncomeRecord.created_at.desc()).first()
    gap_hours = 24.0
    if last_entry and last_entry.created_at:
        delta = datetime.utcnow() - last_entry.created_at
        gap_hours = max(delta.total_seconds() / 3600, 0.01)

    # Run fraud detection
    fraud_features = {
        "amount": request.amount,
        "entries_per_day": today_count + 1,
        "hour_of_entry": datetime.utcnow().hour,
        "location_distance_km": 2.0,  # placeholder — real app uses GPS delta
        "employer_ratio": 0.3,
        "amount_uniqueness": 0.7,
        "entry_gap_hours": gap_hours,
    }
    fraud_result = fraud_model.detect(fraud_features)

    # Generate integrity hash
    record_hash = generate_income_record_hash(
        request.worker_id, request.amount, request.work_date
    )

    # Determine initial verification status
    if fraud_result["recommendation"] == "reject":
        verification_status = "flagged"
    elif request.employer_phone:
        verification_status = "pending"
    else:
        verification_status = "self_declared"

    # Create record
    record = IncomeRecord(
        worker_id=request.worker_id,
        amount=request.amount,
        work_date=date.fromisoformat(request.work_date),
        work_type=request.work_type,
        work_description=request.work_description,
        hours_worked=request.hours_worked,
        employer_name=request.employer_name,
        employer_phone=request.employer_phone,
        voice_transcription=request.voice_transcription,
        gps_latitude=request.gps_latitude,
        gps_longitude=request.gps_longitude,
        gps_accuracy_meters=request.gps_accuracy_meters,
        record_hash=record_hash,
        verification_status=verification_status,
        fraud_score=fraud_result["fraud_score"],
        fraud_flags=",".join(fraud_result["flags"]) if fraud_result["flags"] else None,
        is_duplicate_suspect=False,
        trust_points_earned=5 if verification_status != "flagged" else 0,
    )
    db.add(record)

    # Update worker aggregates
    worker.total_income_logged = (worker.total_income_logged or 0) + request.amount
    db.commit()
    db.refresh(record)

    return {
        "record_id": str(record.id),
        "amount": record.amount,
        "work_date": str(record.work_date),
        "work_type": record.work_type,
        "verification_status": record.verification_status,
        "record_hash": record.record_hash,
        "fraud_check": {
            "fraud_score": fraud_result["fraud_score"],
            "flags": fraud_result["flags"],
            "recommendation": fraud_result["recommendation"],
        },
    }


@router.get("/worker/{worker_id}")
def get_income_records(
    worker_id: str,
    month: Optional[int] = None,
    year: Optional[int] = None,
    status: Optional[str] = None,
    page: int = 1,
    limit: int = 20,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Paginated income records with optional filters."""
    query = db.query(IncomeRecord).filter(IncomeRecord.worker_id == worker_id)

    if month:
        query = query.filter(extract("month", IncomeRecord.work_date) == month)
    if year:
        query = query.filter(extract("year", IncomeRecord.work_date) == year)
    if status:
        query = query.filter(IncomeRecord.verification_status == status)

    total = query.count()
    offset = (page - 1) * limit
    records = query.order_by(IncomeRecord.work_date.desc()).offset(offset).limit(limit).all()

    return {
        "total": total,
        "page": page,
        "limit": limit,
        "records": [
            {
                "id": str(r.id),
                "amount": r.amount,
                "work_date": str(r.work_date),
                "work_type": r.work_type,
                "employer_name": r.employer_name,
                "verification_status": r.verification_status,
                "fraud_score": r.fraud_score,
                "record_hash": r.record_hash,
                "created_at": r.created_at.isoformat() if r.created_at else None,
            }
            for r in records
        ],
    }


@router.get("/monthly-summary/{worker_id}")
def monthly_summary(
    worker_id: str,
    month: Optional[int] = None,
    year: Optional[int] = None,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Monthly income summary with weekly breakdown."""
    now = datetime.utcnow()
    m = month or now.month
    y = year or now.year

    records = db.query(IncomeRecord).filter(
        IncomeRecord.worker_id == worker_id,
        extract("month", IncomeRecord.work_date) == m,
        extract("year", IncomeRecord.work_date) == y,
    ).all()

    total_income = sum(r.amount for r in records)
    verified_income = sum(
        r.amount for r in records
        if r.verification_status in ("employer_confirmed", "auto_verified")
    )
    pending_income = sum(
        r.amount for r in records if r.verification_status == "pending"
    )
    disputed_income = sum(
        r.amount for r in records if r.verification_status == "flagged"
    )

    # Weekly breakdown
    weekly = {}
    for r in records:
        if r.work_date:
            week_num = r.work_date.isocalendar()[1]
            key = f"week_{week_num}"
            if key not in weekly:
                weekly[key] = {"total": 0, "count": 0}
            weekly[key]["total"] += r.amount
            weekly[key]["count"] += 1

    return {
        "month": m,
        "year": y,
        "total_income": round(total_income, 2),
        "verified_income": round(verified_income, 2),
        "pending_income": round(pending_income, 2),
        "disputed_income": round(disputed_income, 2),
        "total_records": len(records),
        "weekly_breakdown": weekly,
    }


@router.get("/certificate/{worker_id}")
def get_certificate(
    worker_id: str,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Generate an income certificate with QR code."""
    worker = db.query(WorkerProfile).filter(WorkerProfile.id == worker_id).first()
    if not worker:
        raise HTTPException(status_code=404, detail="Worker not found")

    # Gather income stats
    records = db.query(IncomeRecord).filter(
        IncomeRecord.worker_id == worker_id
    ).all()

    total_income = sum(r.amount for r in records)
    verified_income = sum(
        r.amount for r in records
        if r.verification_status in ("employer_confirmed", "auto_verified")
    )

    # Date range
    dates = [r.work_date for r in records if r.work_date]
    period_start = str(min(dates)) if dates else ""
    period_end = str(max(dates)) if dates else ""

    worker_data = {
        "name": worker.name,
        "worker_id": str(worker.id),
        "city": worker.city,
        "work_type": worker.work_type,
        "trust_score": worker.trust_score,
        "trust_band": worker.trust_band,
    }

    income_summary = {
        "total_income": total_income,
        "verified_income": verified_income,
        "total_records": len(records),
        "verified_records": sum(
            1 for r in records
            if r.verification_status in ("employer_confirmed", "auto_verified")
        ),
        "period_start": period_start,
        "period_end": period_end,
    }

    return generate_certificate(worker_data, income_summary)
