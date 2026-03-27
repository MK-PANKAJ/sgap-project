"""
Admin API — Platform stats, fraud alerts, and worker management.
"""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import func
from app.database import get_db
from app.models.user import User, WorkerProfile, EmployerProfile
from app.models.income_record import IncomeRecord
from app.models.loan import LoanApplication
from app.utils.security import get_current_user
from typing import Optional
import logging

logger = logging.getLogger(__name__)
router = APIRouter()


@router.get("/stats")
def get_platform_stats(
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Platform-wide overview statistics."""
    total_workers = db.query(WorkerProfile).count()
    total_employers = db.query(EmployerProfile).count()
    total_users = db.query(User).count()
    total_records = db.query(IncomeRecord).count()

    total_income = db.query(func.sum(IncomeRecord.amount)).scalar() or 0
    verified_income = (
        db.query(func.sum(IncomeRecord.amount))
        .filter(
            IncomeRecord.verification_status.in_(
                ["employer_confirmed", "auto_verified"]
            )
        )
        .scalar()
        or 0
    )

    total_loans = db.query(LoanApplication).count()
    active_loans = (
        db.query(LoanApplication)
        .filter(LoanApplication.status.in_(["disbursed", "active", "repaying"]))
        .count()
    )
    total_disbursed = (
        db.query(func.sum(LoanApplication.amount_disbursed)).scalar() or 0
    )

    flagged_records = (
        db.query(IncomeRecord)
        .filter(IncomeRecord.verification_status == "flagged")
        .count()
    )

    return {
        "platform": "S-GAP",
        "users": {
            "total": total_users,
            "workers": total_workers,
            "employers": total_employers,
        },
        "income": {
            "total_records": total_records,
            "total_logged": round(total_income, 2),
            "total_verified": round(verified_income, 2),
            "verification_rate": round(
                verified_income / max(total_income, 1) * 100, 1
            ),
        },
        "loans": {
            "total_applications": total_loans,
            "active_loans": active_loans,
            "total_disbursed": round(total_disbursed, 2),
        },
        "fraud": {
            "flagged_records": flagged_records,
        },
    }


@router.get("/fraud-alerts")
def get_fraud_alerts(
    limit: int = 20,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Flagged records sorted by fraud score descending."""
    records = (
        db.query(IncomeRecord)
        .filter(IncomeRecord.fraud_score > 0.3)
        .order_by(IncomeRecord.fraud_score.desc())
        .limit(limit)
        .all()
    )

    return {
        "total_alerts": len(records),
        "alerts": [
            {
                "record_id": str(r.id),
                "worker_id": str(r.worker_id),
                "amount": r.amount,
                "work_date": str(r.work_date) if r.work_date else None,
                "fraud_score": r.fraud_score,
                "fraud_flags": r.fraud_flags.split(",") if r.fraud_flags else [],
                "verification_status": r.verification_status,
                "created_at": r.created_at.isoformat() if r.created_at else None,
            }
            for r in records
        ],
    }


@router.get("/workers")
def get_workers_list(
    city: Optional[str] = None,
    page: int = 1,
    limit: int = 20,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Paginated worker list with optional city filter."""
    query = db.query(WorkerProfile)
    if city:
        query = query.filter(WorkerProfile.city == city)

    total = query.count()
    offset = (page - 1) * limit
    workers = query.order_by(WorkerProfile.created_at.desc()).offset(offset).limit(limit).all()

    return {
        "total": total,
        "page": page,
        "limit": limit,
        "workers": [
            {
                "id": str(w.id),
                "name": w.name,
                "city": w.city,
                "work_type": w.work_type,
                "trust_score": w.trust_score,
                "trust_band": w.trust_band,
                "total_income_logged": w.total_income_logged,
                "total_verified_income": w.total_verified_income,
                "employer_count": w.employer_count,
                "is_aadhaar_verified": w.is_aadhaar_verified,
            }
            for w in workers
        ],
    }
