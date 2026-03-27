"""
SGAP Loan Models
Lender            – registered lending institutions / NBFCs.
LoanApplication   – worker's request for a micro-loan.
LoanOffer         – lender's counter-offer with terms.
LoanRepayment     – individual repayment transactions.
"""

from sqlalchemy import (
    Column, String, Boolean, DateTime, Integer, Float,
    ForeignKey, Text, Date,
)
from sqlalchemy.orm import relationship
from app.database import Base
from app.models.user import UUID
import uuid
from datetime import datetime
import enum


# ── Enums ────────────────────────────────────────────────────────────


class LoanStatus(str, enum.Enum):
    DRAFT = "draft"
    SUBMITTED = "submitted"
    UNDER_REVIEW = "under_review"
    APPROVED = "approved"
    REJECTED = "rejected"
    DISBURSED = "disbursed"
    ACTIVE = "active"
    REPAYING = "repaying"
    COMPLETED = "completed"
    DEFAULTED = "defaulted"
    CANCELLED = "cancelled"


class OfferStatus(str, enum.Enum):
    PENDING = "pending"
    ACCEPTED = "accepted"
    REJECTED = "rejected"
    EXPIRED = "expired"
    WITHDRAWN = "withdrawn"


class RepaymentStatus(str, enum.Enum):
    SCHEDULED = "scheduled"
    PAID = "paid"
    OVERDUE = "overdue"
    PARTIALLY_PAID = "partially_paid"
    WAIVED = "waived"


# ── Models ───────────────────────────────────────────────────────────


class Lender(Base):
    """A registered lending institution / NBFC / MFI."""
    __tablename__ = "lenders"

    id = Column(UUID(), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(UUID(), ForeignKey("users.id"), unique=True, nullable=False)

    # Organisation details
    institution_name = Column(String(200), nullable=False)
    institution_type = Column(String(50))        # nbfc | mfi | bank | fintech
    rbi_registration = Column(String(50))
    contact_person = Column(String(100))
    contact_email = Column(String(100))
    contact_phone = Column(String(15))

    # Location
    city = Column(String(100))
    state = Column(String(100))
    address = Column(Text)

    # Lending parameters
    min_loan_amount = Column(Float, default=1000.0)
    max_loan_amount = Column(Float, default=50000.0)
    min_trust_score = Column(Integer, default=400)
    interest_rate_min = Column(Float, default=12.0)   # annual %
    interest_rate_max = Column(Float, default=36.0)

    # Status
    is_active = Column(Boolean, default=True)
    is_verified = Column(Boolean, default=False)

    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    user = relationship("User", foreign_keys=[user_id])
    loan_offers = relationship("LoanOffer", back_populates="lender", cascade="all, delete-orphan")


class LoanApplication(Base):
    """A worker's request for a micro-loan."""
    __tablename__ = "loan_applications"

    id = Column(UUID(), primary_key=True, default=lambda: str(uuid.uuid4()))
    worker_id = Column(
        UUID(), ForeignKey("worker_profiles.id"), nullable=False, index=True
    )

    # Requested terms
    amount_requested = Column(Float, nullable=False)
    purpose = Column(String(100))                 # medical | education | housing | business | emergency
    purpose_description = Column(Text)
    tenure_months = Column(Integer, default=6)

    # Worker snapshot at application time
    trust_score_at_apply = Column(Integer)
    trust_band_at_apply = Column(String(20))
    monthly_income_avg = Column(Float)
    total_verified_income = Column(Float)
    employer_count_at_apply = Column(Integer)

    # Application lifecycle
    status = Column(String(20), default=LoanStatus.DRAFT.value, index=True)
    submitted_at = Column(DateTime)
    reviewed_at = Column(DateTime)
    decision_reason = Column(Text)

    # Disbursement
    amount_approved = Column(Float)
    amount_disbursed = Column(Float)
    disbursed_at = Column(DateTime)
    disbursement_mode = Column(String(30))        # upi | bank_transfer | cash
    disbursement_reference = Column(String(100))

    # Repayment tracking
    interest_rate = Column(Float)                  # annual %
    emi_amount = Column(Float)
    total_repaid = Column(Float, default=0.0)
    remaining_balance = Column(Float)
    next_due_date = Column(Date)
    repayment_start_date = Column(Date)
    repayment_end_date = Column(Date)

    # Metadata
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    worker = relationship("WorkerProfile", back_populates="loan_applications")
    offers = relationship("LoanOffer", back_populates="application", cascade="all, delete-orphan")
    repayments = relationship("LoanRepayment", back_populates="application", cascade="all, delete-orphan")


class LoanOffer(Base):
    """A lender's counter-offer for a loan application."""
    __tablename__ = "loan_offers"

    id = Column(UUID(), primary_key=True, default=lambda: str(uuid.uuid4()))
    application_id = Column(
        UUID(), ForeignKey("loan_applications.id"), nullable=False, index=True
    )
    lender_id = Column(
        UUID(), ForeignKey("lenders.id"), nullable=False, index=True
    )

    # Offered terms
    amount_offered = Column(Float, nullable=False)
    interest_rate = Column(Float, nullable=False)    # annual %
    tenure_months = Column(Integer, nullable=False)
    emi_amount = Column(Float)
    processing_fee = Column(Float, default=0.0)
    total_repayable = Column(Float)

    # Conditions
    conditions = Column(Text)                        # free-text lender conditions
    min_trust_score_required = Column(Integer)

    # Status
    status = Column(String(20), default=OfferStatus.PENDING.value, index=True)
    expires_at = Column(DateTime)
    accepted_at = Column(DateTime)
    rejected_at = Column(DateTime)
    rejection_reason = Column(Text)

    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    application = relationship("LoanApplication", back_populates="offers")
    lender = relationship("Lender", back_populates="loan_offers")


class LoanRepayment(Base):
    """Individual repayment transaction against a loan."""
    __tablename__ = "loan_repayments"

    id = Column(UUID(), primary_key=True, default=lambda: str(uuid.uuid4()))
    application_id = Column(
        UUID(), ForeignKey("loan_applications.id"), nullable=False, index=True
    )

    # Payment details
    installment_number = Column(Integer, nullable=False)
    amount_due = Column(Float, nullable=False)
    amount_paid = Column(Float, default=0.0)
    due_date = Column(Date, nullable=False)
    paid_date = Column(DateTime)
    payment_mode = Column(String(30))               # upi | bank_transfer | cash | auto_debit
    payment_reference = Column(String(100))

    # Status
    status = Column(String(20), default=RepaymentStatus.SCHEDULED.value, index=True)
    days_overdue = Column(Integer, default=0)
    penalty_amount = Column(Float, default=0.0)

    # Balance after this payment
    balance_after = Column(Float)

    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    application = relationship("LoanApplication", back_populates="repayments")
