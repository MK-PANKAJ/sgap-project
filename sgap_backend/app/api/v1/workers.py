"""
Workers API — Worker profile lookup.
"""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.user import WorkerProfile
from app.utils.security import get_current_user
import logging

logger = logging.getLogger(__name__)
router = APIRouter()


@router.get("/{worker_id}")
def get_worker(
    worker_id: str,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Get a worker profile by ID."""
    worker = db.query(WorkerProfile).filter(WorkerProfile.id == worker_id).first()
    if not worker:
        raise HTTPException(status_code=404, detail="Worker not found")

    return {
        "id": str(worker.id),
        "user_id": str(worker.user_id),
        "name": worker.name,
        "city": worker.city,
        "state": worker.state,
        "pincode": worker.pincode,
        "work_type": worker.work_type,
        "profile_photo_url": worker.profile_photo_url,
        "trust_score": worker.trust_score,
        "trust_band": worker.trust_band,
        "total_income_logged": worker.total_income_logged,
        "total_verified_income": worker.total_verified_income,
        "employer_count": worker.employer_count,
        "is_aadhaar_verified": worker.is_aadhaar_verified,
        "aadhaar_last_four": worker.aadhaar_last_four,
        "created_at": worker.created_at.isoformat() if worker.created_at else None,
    }
