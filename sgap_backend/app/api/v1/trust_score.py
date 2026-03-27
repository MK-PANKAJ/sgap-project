"""
Trust Score API — ML-powered credit scoring and score history.
"""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.user import WorkerProfile
from app.models.income_record import IncomeRecord
from app.models.trust_score import TrustScoreRecord, TrustScoreHistory
from app.utils.security import get_current_user
from app.ml.credit_scoring_model import credit_model
from datetime import datetime, timedelta
import logging

logger = logging.getLogger(__name__)
router = APIRouter()


@router.get("/{worker_id}")
def get_trust_score(
    worker_id: str,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    Calculate the worker's trust score using the ML model,
    update the worker profile, and save a score record.
    """
    worker = db.query(WorkerProfile).filter(WorkerProfile.id == worker_id).first()
    if not worker:
        raise HTTPException(status_code=404, detail="Worker not found")

    # Gather features from income records
    records = db.query(IncomeRecord).filter(
        IncomeRecord.worker_id == worker_id
    ).all()

    total_entries = len(records)
    total_income = sum(r.amount for r in records)
    verified_count = sum(
        1 for r in records
        if r.verification_status in ("employer_confirmed", "auto_verified")
    )
    disputed_count = sum(
        1 for r in records if r.verification_status == "flagged"
    )

    # Unique employers
    employers = set(r.employer_name for r in records if r.employer_name)

    # Platform tenure
    tenure_days = 1
    if worker.created_at:
        tenure_days = max((datetime.utcnow() - worker.created_at).days, 1)

    # Daily income average
    dates = set(r.work_date for r in records if r.work_date)
    active_days = max(len(dates), 1)
    avg_daily = total_income / active_days if active_days else 0

    # Income variance
    amounts = [r.amount for r in records]
    if len(amounts) > 1:
        mean_amt = sum(amounts) / len(amounts)
        variance = sum((a - mean_amt) ** 2 for a in amounts) / len(amounts)
        income_variance = min((variance ** 0.5) / max(mean_amt, 1), 2.0)
    else:
        income_variance = 0.5

    # Consistency: fraction of days in tenure with an entry
    income_consistency = min(active_days / max(tenure_days, 1), 1.0)

    features = {
        "income_consistency": income_consistency,
        "avg_monthly_income": total_income / max(tenure_days / 30, 1),
        "income_variance": income_variance,
        "verification_rate": verified_count / max(total_entries, 1),
        "employer_diversity": len(employers),
        "platform_tenure_days": tenure_days,
        "total_entries": total_entries,
        "avg_daily_income": avg_daily,
        "dispute_rate": disputed_count / max(total_entries, 1),
        "repayment_ratio": 0.8,  # default until loan history exists
    }

    result = credit_model.predict(features)

    # Update worker
    old_score = worker.trust_score or 300
    worker.trust_score = result["score"]
    worker.trust_band = result["band"]

    # Save score record
    score_record = TrustScoreRecord(
        worker_id=worker_id,
        event_type="score_recalculated",
        event_description="ML model recalculation",
        points_change=result["score"] - old_score,
        score_before=old_score,
        score_after=result["score"],
        band_before=worker.trust_band,
        band_after=result["band"],
    )
    db.add(score_record)
    db.commit()

    return {
        "worker_id": worker_id,
        "worker_name": worker.name,
        **result,
        "features_used": features,
    }


@router.get("/{worker_id}/history")
def get_trust_history(
    worker_id: str,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    Last 6 months of trust score history.
    Generates demo data if the history table is empty.
    """
    worker = db.query(WorkerProfile).filter(WorkerProfile.id == worker_id).first()
    if not worker:
        raise HTTPException(status_code=404, detail="Worker not found")

    history = (
        db.query(TrustScoreHistory)
        .filter(TrustScoreHistory.worker_id == worker_id)
        .order_by(TrustScoreHistory.snapshot_date.desc())
        .limit(6)
        .all()
    )

    # Generate demo data if empty
    if not history:
        import random
        random.seed(hash(worker_id))
        base_score = 300
        now = datetime.utcnow()

        for i in range(6, 0, -1):
            snapshot_date = now - timedelta(days=30 * i)
            base_score = min(base_score + random.randint(20, 80), 900)

            if base_score >= 800:
                band = "excellent"
            elif base_score >= 650:
                band = "good"
            elif base_score >= 500:
                band = "fair"
            else:
                band = "building"

            entry = TrustScoreHistory(
                worker_id=worker_id,
                score=base_score,
                band=band,
                total_income_logged=random.uniform(5000, 30000) * (7 - i),
                total_verified_income=random.uniform(3000, 20000) * (7 - i),
                verification_ratio=random.uniform(0.5, 0.95),
                total_records=random.randint(5, 30) * (7 - i),
                verified_records=random.randint(3, 20) * (7 - i),
                employer_count=random.randint(1, 5),
                consistency_streak_days=random.randint(0, 30),
                snapshot_date=snapshot_date,
                period_start=snapshot_date - timedelta(days=30),
                period_end=snapshot_date,
            )
            db.add(entry)

        db.commit()
        history = (
            db.query(TrustScoreHistory)
            .filter(TrustScoreHistory.worker_id == worker_id)
            .order_by(TrustScoreHistory.snapshot_date.desc())
            .limit(6)
            .all()
        )

    return {
        "worker_id": worker_id,
        "current_score": worker.trust_score,
        "current_band": worker.trust_band,
        "history": [
            {
                "score": h.score,
                "band": h.band,
                "snapshot_date": h.snapshot_date.isoformat() if h.snapshot_date else None,
                "total_income_logged": round(h.total_income_logged or 0, 2),
                "total_verified_income": round(h.total_verified_income or 0, 2),
                "verification_ratio": round(h.verification_ratio or 0, 2),
                "total_records": h.total_records,
                "employer_count": h.employer_count,
                "consistency_streak_days": h.consistency_streak_days,
            }
            for h in history
        ],
    }
