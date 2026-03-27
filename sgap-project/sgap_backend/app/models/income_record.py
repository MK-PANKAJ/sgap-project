"""
SGAP Income Record Model
Captures daily/gig income with optional voice evidence, GPS location,
employer verification, and fraud detection metadata.
"""

from sqlalchemy import (
    Column, String, Boolean, DateTime, Integer, Float,
    ForeignKey, Text, Date, Enum as SAEnum,
)
from sqlalchemy.orm import relationship
from app.database import Base
from app.models.user import UUID
import uuid
from datetime import datetime
import enum


class VerificationStatus(str, enum.Enum):
    """Status of an income record's verification lifecycle."""
    PENDING = "pending"
    EMPLOYER_CONFIRMED = "employer_confirmed"
    EMPLOYER_DENIED = "employer_denied"
    SELF_DECLARED = "self_declared"
    AUTO_VERIFIED = "auto_verified"
    FLAGGED = "flagged"


class IncomeRecord(Base):
    """
    A single income entry logged by a worker.

    Supports multiple evidence channels:
      - Voice recording (with optional transcription)
      - GPS coordinates at time of logging
      - Photo evidence (receipt / worksite)
      - Employer-side verification

    Fraud detection fields track anomalies and scoring.
    """
    __tablename__ = "income_records"

    # ── Primary key & foreign keys ───────────────────────────────────
    id = Column(UUID(), primary_key=True, default=lambda: str(uuid.uuid4()))
    worker_id = Column(
        UUID(), ForeignKey("worker_profiles.id"), nullable=False, index=True
    )
    employer_id = Column(
        UUID(), ForeignKey("employer_profiles.id"), nullable=True, index=True
    )

    # ── Core income data ─────────────────────────────────────────────
    amount = Column(Float, nullable=False)
    currency = Column(String(3), default="INR")
    work_date = Column(Date, nullable=False, index=True)
    work_type = Column(String(50))
    work_description = Column(Text)
    hours_worked = Column(Float)

    # ── Voice evidence ───────────────────────────────────────────────
    voice_recording_url = Column(Text)           # S3/GCS URL of the audio file
    voice_duration_seconds = Column(Float)       # length of the recording
    voice_transcription = Column(Text)           # STT output (Hindi / English)
    voice_language = Column(String(5))           # detected language code
    voice_confidence = Column(Float)             # STT confidence 0.0 – 1.0
    voice_amount_extracted = Column(Float)       # amount parsed from voice

    # ── GPS / Location ───────────────────────────────────────────────
    gps_latitude = Column(Float)
    gps_longitude = Column(Float)
    gps_accuracy_meters = Column(Float)
    location_address = Column(Text)              # reverse-geocoded address
    location_city = Column(String(100))
    location_state = Column(String(100))

    # ── Photo evidence ───────────────────────────────────────────────
    photo_evidence_url = Column(Text)            # receipt / worksite photo
    photo_verified = Column(Boolean, default=False)

    # ── Verification ─────────────────────────────────────────────────
    verification_status = Column(
        String(25), default=VerificationStatus.PENDING.value
    )
    verified_by = Column(UUID(), nullable=True)  # user_id of verifier
    verified_at = Column(DateTime, nullable=True)
    employer_name = Column(String(200))          # denormalised for display
    employer_phone = Column(String(15))          # for OTP-based verification

    # ── Integrity hash (tamper-proofing) ─────────────────────────────
    record_hash = Column(String(64))             # SHA-256 of core fields

    # ── Fraud detection ──────────────────────────────────────────────
    fraud_score = Column(Float, default=0.0)     # 0 = clean, 1.0 = likely fraud
    fraud_flags = Column(Text)                   # JSON list of triggered rules
    is_duplicate_suspect = Column(Boolean, default=False)
    duplicate_of_id = Column(UUID(), nullable=True)  # FK to a potential dup record
    gps_mismatch = Column(Boolean, default=False)
    voice_amount_mismatch = Column(Boolean, default=False)
    time_anomaly = Column(Boolean, default=False)

    # ── Trust impact ─────────────────────────────────────────────────
    trust_points_earned = Column(Integer, default=0)
    trust_score_after = Column(Integer)          # snapshot after this entry

    # ── Timestamps ───────────────────────────────────────────────────
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # ── Relationships ────────────────────────────────────────────────
    worker = relationship("WorkerProfile", back_populates="income_records")
    employer = relationship("EmployerProfile", foreign_keys=[employer_id])
