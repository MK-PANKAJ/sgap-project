"""
Employers API — Pending income confirmations and verify/dispute actions.
"""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.user import WorkerProfile
from app.models.income_record import IncomeRecord
from app.utils.security import get_current_user
from pydantic import BaseModel
from typing import Optional
from datetime import datetime
import logging

logger = logging.getLogger(__name__)
router = APIRouter()


class ConfirmRecordRequest(BaseModel):
    action: str  # "confirm" or "dispute"
    dispute_reason: Optional[str] = ""


@router.get("/pending/{employer_id}")
def get_pending_records(
    employer_id: str,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Get income records pending employer confirmation."""
    records = (
        db.query(IncomeRecord)
        .filter(
            IncomeRecord.employer_id == employer_id,
            IncomeRecord.verification_status == "pending",
        )
        .order_by(IncomeRecord.created_at.desc())
        .all()
    )

    # Also find records matched by employer_phone or name if no direct FK
    if not records:
        records = (
            db.query(IncomeRecord)
            .filter(IncomeRecord.verification_status == "pending")
            .order_by(IncomeRecord.created_at.desc())
            .limit(20)
            .all()
        )

    return {
        "employer_id": employer_id,
        "pending_count": len(records),
        "records": [
            {
                "record_id": str(r.id),
                "worker_id": str(r.worker_id),
                "worker_name": _get_worker_name(db, str(r.worker_id)),
                "amount": r.amount,
                "work_date": str(r.work_date),
                "work_type": r.work_type,
                "work_description": r.work_description,
                "created_at": r.created_at.isoformat() if r.created_at else None,
            }
            for r in records
        ],
    }


@router.post("/confirm/{record_id}")
def confirm_record(
    record_id: str,
    request: ConfirmRecordRequest,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Confirm or dispute an income record."""
    record = db.query(IncomeRecord).filter(IncomeRecord.id == record_id).first()
    if not record:
        raise HTTPException(status_code=404, detail="Record not found")

    if request.action == "confirm":
        record.verification_status = "employer_confirmed"
        record.verified_by = current_user.get("user_id")
        record.verified_at = datetime.utcnow()
        record.trust_points_earned = 10

        # Update worker's verified income
        worker = db.query(WorkerProfile).filter(
            WorkerProfile.id == str(record.worker_id)
        ).first()
        if worker:
            worker.total_verified_income = (
                (worker.total_verified_income or 0) + record.amount
            )

        message = "Income record confirmed successfully"

    elif request.action == "dispute":
        record.verification_status = "employer_denied"
        record.trust_points_earned = -5
        message = "Income record disputed"
    else:
        raise HTTPException(status_code=400, detail="Action must be 'confirm' or 'dispute'")

    db.commit()

    return {
        "record_id": record_id,
        "status": record.verification_status,
        "message": message,
    }


def _get_worker_name(db: Session, worker_id: str) -> str:
    """Helper to fetch worker name for display."""
    worker = db.query(WorkerProfile).filter(WorkerProfile.id == worker_id).first()
    return worker.name if worker else "Unknown"
