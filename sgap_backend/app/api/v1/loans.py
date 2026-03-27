"""
Loans API — Eligibility check, application, offer acceptance, active loans.
"""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.user import WorkerProfile
from app.models.loan import LoanApplication, LoanOffer, LoanRepayment
from app.utils.security import get_current_user
from app.services.ocen_service import generate_offers
from pydantic import BaseModel
from typing import Optional
from datetime import datetime, date, timedelta
import logging

logger = logging.getLogger(__name__)
router = APIRouter()


# ── Request schemas ──────────────────────────────────────────────────


class LoanApplyRequest(BaseModel):
    worker_id: str
    amount_requested: float
    purpose: Optional[str] = "emergency"
    purpose_description: Optional[str] = ""
    tenure_months: Optional[int] = 6


# ── Endpoints ────────────────────────────────────────────────────────


@router.get("/check-eligibility/{worker_id}")
def check_eligibility(
    worker_id: str,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Check loan eligibility based on trust score and income history."""
    worker = db.query(WorkerProfile).filter(WorkerProfile.id == worker_id).first()
    if not worker:
        raise HTTPException(status_code=404, detail="Worker not found")

    score = worker.trust_score or 300
    total_income = worker.total_income_logged or 0

    is_eligible = score >= 400 and total_income >= 1000

    # Max loan amount scales with score
    if score >= 800:
        max_amount = min(total_income * 3, 100000)
    elif score >= 650:
        max_amount = min(total_income * 2, 50000)
    elif score >= 500:
        max_amount = min(total_income * 1, 25000)
    else:
        max_amount = min(total_income * 0.5, 10000)

    max_amount = round(max_amount / 100) * 100  # round to nearest 100

    reasons = []
    if score < 400:
        reasons.append("Trust score below 400 — keep logging income daily")
    if total_income < 1000:
        reasons.append("Need at least ₹1,000 logged income")
    if not worker.is_aadhaar_verified:
        reasons.append("Complete Aadhaar verification for higher limits")

    return {
        "worker_id": worker_id,
        "is_eligible": is_eligible,
        "trust_score": score,
        "trust_band": worker.trust_band,
        "max_loan_amount": max_amount if is_eligible else 0,
        "total_income_logged": total_income,
        "reasons": reasons,
        "eligible_message_hindi": "आप लोन के लिए योग्य हैं! 🎉" if is_eligible else "अभी योग्य नहीं। कमाई रिकॉर्ड करते रहें।",
    }


@router.post("/apply")
def apply_for_loan(
    request: LoanApplyRequest,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Create a loan application and generate OCEN offers."""
    worker = db.query(WorkerProfile).filter(
        WorkerProfile.id == request.worker_id
    ).first()
    if not worker:
        raise HTTPException(status_code=404, detail="Worker not found")

    score = worker.trust_score or 300
    if score < 400:
        raise HTTPException(
            status_code=400,
            detail="Trust score too low. Minimum 400 required.",
        )

    # Create application
    application = LoanApplication(
        worker_id=request.worker_id,
        amount_requested=request.amount_requested,
        purpose=request.purpose,
        purpose_description=request.purpose_description,
        tenure_months=request.tenure_months,
        trust_score_at_apply=score,
        trust_band_at_apply=worker.trust_band,
        monthly_income_avg=(worker.total_income_logged or 0) / 3,
        total_verified_income=worker.total_verified_income or 0,
        employer_count_at_apply=worker.employer_count or 0,
        status="submitted",
        submitted_at=datetime.utcnow(),
    )
    db.add(application)
    db.commit()
    db.refresh(application)

    # Generate OCEN offers
    offers_data = generate_offers(
        worker_id=request.worker_id,
        amount_requested=request.amount_requested,
        trust_score=score,
        tenure_months=request.tenure_months,
    )

    # Save offers to DB
    saved_offers = []
    for od in offers_data:
        offer = LoanOffer(
            application_id=str(application.id),
            lender_id=None,  # simulated lender
            amount_offered=od["amount_offered"],
            interest_rate=od["interest_rate"],
            tenure_months=od["tenure_months"],
            emi_amount=od["emi_amount"],
            total_repayable=od["total_repayable"],
            processing_fee=od["processing_fee"],
            status="pending",
            expires_at=datetime.fromisoformat(od["expires_at"]),
        )
        db.add(offer)
        db.commit()
        db.refresh(offer)

        saved_offers.append({
            "offer_id": str(offer.id),
            "lender_name": od["lender_name"],
            "lender_type": od["lender_type"],
            "amount_offered": od["amount_offered"],
            "interest_rate": od["interest_rate"],
            "tenure_months": od["tenure_months"],
            "emi_amount": od["emi_amount"],
            "total_repayable": od["total_repayable"],
            "processing_fee": od["processing_fee"],
            "is_best": od["is_best"],
            "expires_at": od["expires_at"],
        })

    return {
        "application_id": str(application.id),
        "status": "submitted",
        "amount_requested": request.amount_requested,
        "offers": saved_offers,
        "message_hindi": f"{len(saved_offers)} लोन ऑफ़र मिले! सबसे अच्छा ऑफ़र चुनें।"
    }


@router.post("/accept/{offer_id}")
def accept_offer(
    offer_id: str,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Accept a loan offer — generates EMI repayment schedule."""
    offer = db.query(LoanOffer).filter(LoanOffer.id == offer_id).first()
    if not offer:
        raise HTTPException(status_code=404, detail="Offer not found")

    offer.status = "accepted"
    offer.accepted_at = datetime.utcnow()

    # Update application
    application = db.query(LoanApplication).filter(
        LoanApplication.id == offer.application_id
    ).first()
    if application:
        application.status = "disbursed"
        application.amount_approved = offer.amount_offered
        application.amount_disbursed = offer.amount_offered
        application.disbursed_at = datetime.utcnow()
        application.interest_rate = offer.interest_rate
        application.emi_amount = offer.emi_amount
        application.remaining_balance = offer.total_repayable
        application.repayment_start_date = date.today() + timedelta(days=30)
        application.repayment_end_date = date.today() + timedelta(
            days=30 * offer.tenure_months
        )

    # Generate repayment schedule
    schedule = []
    for i in range(1, offer.tenure_months + 1):
        due = date.today() + timedelta(days=30 * i)
        repayment = LoanRepayment(
            application_id=str(offer.application_id),
            installment_number=i,
            amount_due=offer.emi_amount,
            due_date=due,
            status="scheduled",
        )
        db.add(repayment)
        schedule.append({
            "installment": i,
            "amount_due": offer.emi_amount,
            "due_date": str(due),
            "status": "scheduled",
        })

    db.commit()

    return {
        "offer_id": offer_id,
        "status": "disbursed",
        "amount_disbursed": offer.amount_offered,
        "emi_amount": offer.emi_amount,
        "tenure_months": offer.tenure_months,
        "repayment_schedule": schedule,
        "message_hindi": f"₹{int(offer.amount_offered)} लोन स्वीकृत! EMI ₹{int(offer.emi_amount)}/महीना",
    }


@router.get("/active/{worker_id}")
def get_active_loans(
    worker_id: str,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Get active loans with EMI status."""
    applications = (
        db.query(LoanApplication)
        .filter(
            LoanApplication.worker_id == worker_id,
            LoanApplication.status.in_(["disbursed", "active", "repaying"]),
        )
        .all()
    )

    loans = []
    for app in applications:
        repayments = (
            db.query(LoanRepayment)
            .filter(LoanRepayment.application_id == str(app.id))
            .order_by(LoanRepayment.installment_number)
            .all()
        )

        paid = sum(1 for r in repayments if r.status == "paid")
        total = len(repayments)
        next_due = next(
            (r for r in repayments if r.status == "scheduled"), None
        )

        loans.append({
            "application_id": str(app.id),
            "amount_disbursed": app.amount_disbursed,
            "emi_amount": app.emi_amount,
            "interest_rate": app.interest_rate,
            "total_repaid": app.total_repaid or 0,
            "remaining_balance": app.remaining_balance or 0,
            "emis_paid": paid,
            "emis_total": total,
            "next_emi": {
                "amount": next_due.amount_due,
                "due_date": str(next_due.due_date),
            } if next_due else None,
            "status": app.status,
        })

    return {"worker_id": worker_id, "active_loans": loans}
