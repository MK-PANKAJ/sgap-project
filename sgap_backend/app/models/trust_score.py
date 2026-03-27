"""
SGAP Trust Score Models
TrustScoreRecord  – per-event score changes (the ledger).
TrustScoreHistory – periodic snapshots of aggregate trust state.
"""

from sqlalchemy import (
    Column, String, Boolean, DateTime, Integer, Float,
    ForeignKey, Text,
)
from sqlalchemy.orm import relationship
from app.database import Base
from app.models.user import UUID
import uuid
from datetime import datetime
import enum


class TrustEventType(str, enum.Enum):
    """Categories of events that affect a worker's trust score."""
    INCOME_LOGGED = "income_logged"
    INCOME_VERIFIED = "income_verified"
    EMPLOYER_CONFIRMED = "employer_confirmed"
    AADHAAR_VERIFIED = "aadhaar_verified"
    LOAN_REPAID = "loan_repaid"
    LOAN_DEFAULTED = "loan_defaulted"
    FRAUD_DETECTED = "fraud_detected"
    CONSISTENT_LOGGING = "consistent_logging"
    PROFILE_COMPLETED = "profile_completed"
    VOICE_VERIFIED = "voice_verified"
    GPS_CONSISTENT = "gps_consistent"
    PENALTY_DUPLICATE = "penalty_duplicate"
    PENALTY_INCONSISTENCY = "penalty_inconsistency"
    MANUAL_ADJUSTMENT = "manual_adjustment"


class TrustBand(str, enum.Enum):
    """Human-readable trust bands derived from numeric score."""
    BUILDING = "building"    # 0  – 399
    FAIR = "fair"            # 400 – 549
    GOOD = "good"            # 550 – 699
    EXCELLENT = "excellent"  # 700 – 900


class TrustScoreRecord(Base):
    """
    Immutable ledger entry for every trust-score change.
    Each row records *one* event that moved the score up or down.
    """
    __tablename__ = "trust_score_records"

    id = Column(UUID(), primary_key=True, default=lambda: str(uuid.uuid4()))
    worker_id = Column(
        UUID(), ForeignKey("worker_profiles.id"), nullable=False, index=True
    )

    # What happened
    event_type = Column(String(40), nullable=False, index=True)
    event_description = Column(Text)

    # Score delta
    points_change = Column(Integer, nullable=False)   # +ve or –ve
    score_before = Column(Integer, nullable=False)
    score_after = Column(Integer, nullable=False)
    band_before = Column(String(20))
    band_after = Column(String(20))

    # Linkage to the entity that caused this change
    related_entity_type = Column(String(30))  # e.g. "income_record", "loan"
    related_entity_id = Column(UUID())

    # Context metadata
    reason = Column(Text)                     # human-readable explanation
    metadata_json = Column(Text)              # arbitrary JSON context

    created_at = Column(DateTime, default=datetime.utcnow)

    # Relationships
    worker = relationship("WorkerProfile", back_populates="trust_score_records")


class TrustScoreHistory(Base):
    """
    Periodic snapshot of a worker's aggregate trust health.
    Generated daily or on-demand to power dashboards and lender views.
    """
    __tablename__ = "trust_score_history"

    id = Column(UUID(), primary_key=True, default=lambda: str(uuid.uuid4()))
    worker_id = Column(
        UUID(), ForeignKey("worker_profiles.id"), nullable=False, index=True
    )

    # Snapshot values
    score = Column(Integer, nullable=False)
    band = Column(String(20), nullable=False)

    # Aggregated stats at snapshot time
    total_income_logged = Column(Float, default=0.0)
    total_verified_income = Column(Float, default=0.0)
    verification_ratio = Column(Float, default=0.0)   # verified / total
    total_records = Column(Integer, default=0)
    verified_records = Column(Integer, default=0)
    employer_count = Column(Integer, default=0)
    consistency_streak_days = Column(Integer, default=0)

    # Loan health at snapshot time
    active_loans = Column(Integer, default=0)
    loans_repaid = Column(Integer, default=0)
    loans_defaulted = Column(Integer, default=0)

    # Fraud indicators
    fraud_flags_total = Column(Integer, default=0)
    fraud_score_avg = Column(Float, default=0.0)

    # Period this snapshot covers
    snapshot_date = Column(DateTime, default=datetime.utcnow, index=True)
    period_start = Column(DateTime)
    period_end = Column(DateTime)

    created_at = Column(DateTime, default=datetime.utcnow)

    # Relationships
    worker = relationship("WorkerProfile", foreign_keys=[worker_id])
