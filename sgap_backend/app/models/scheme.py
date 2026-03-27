"""
SGAP Scheme & Verification Models
GovernmentScheme   – government welfare schemes workers may be eligible for.
InsurancePlan      – micro-insurance plans offered through the platform.
VerificationToken  – OTP / magic-link tokens for phone and Aadhaar verification.
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


# ── Enums ────────────────────────────────────────────────────────────


class SchemeCategory(str, enum.Enum):
    HOUSING = "housing"
    HEALTH = "health"
    EDUCATION = "education"
    PENSION = "pension"
    INSURANCE = "insurance"
    SKILL_TRAINING = "skill_training"
    FOOD_SECURITY = "food_security"
    LIVELIHOOD = "livelihood"
    FINANCIAL_INCLUSION = "financial_inclusion"
    OTHER = "other"


class InsuranceType(str, enum.Enum):
    LIFE = "life"
    HEALTH = "health"
    ACCIDENT = "accident"
    CROP = "crop"
    ASSET = "asset"


class TokenPurpose(str, enum.Enum):
    PHONE_VERIFICATION = "phone_verification"
    AADHAAR_VERIFICATION = "aadhaar_verification"
    LOGIN_OTP = "login_otp"
    PASSWORD_RESET = "password_reset"
    EMPLOYER_VERIFICATION = "employer_verification"
    INCOME_VERIFICATION = "income_verification"


# ── Models ───────────────────────────────────────────────────────────


class GovernmentScheme(Base):
    """
    A government welfare scheme that workers may be eligible for.
    The platform matches workers to schemes based on profile data.
    """
    __tablename__ = "government_schemes"

    id = Column(UUID(), primary_key=True, default=lambda: str(uuid.uuid4()))

    # Scheme identity
    name = Column(String(300), nullable=False)
    name_hindi = Column(String(300))
    code = Column(String(30), unique=True, index=True)  # e.g. "PMJAY", "PMAY"
    category = Column(String(30), default=SchemeCategory.OTHER.value, index=True)

    # Details
    description = Column(Text)
    description_hindi = Column(Text)
    benefits = Column(Text)              # what the beneficiary receives
    benefits_hindi = Column(Text)

    # Eligibility criteria (stored as structured text / JSON)
    eligibility_criteria = Column(Text)
    min_age = Column(Integer)
    max_age = Column(Integer)
    min_income = Column(Float)
    max_income = Column(Float)
    required_documents = Column(Text)    # JSON list of doc types
    applicable_states = Column(Text)     # JSON list or "ALL"
    applicable_work_types = Column(Text) # JSON list or "ALL"

    # External links
    official_url = Column(Text)
    application_url = Column(Text)

    # Administering body
    ministry = Column(String(200))
    department = Column(String(200))

    # Status
    is_active = Column(Boolean, default=True)
    valid_from = Column(DateTime)
    valid_until = Column(DateTime)

    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


class InsurancePlan(Base):
    """
    Micro-insurance plans offered through the platform.
    Can be government-backed (e.g. PMJJBY) or private.
    """
    __tablename__ = "insurance_plans"

    id = Column(UUID(), primary_key=True, default=lambda: str(uuid.uuid4()))

    # Plan identity
    name = Column(String(200), nullable=False)
    name_hindi = Column(String(200))
    plan_code = Column(String(30), unique=True, index=True)
    insurance_type = Column(String(20), default=InsuranceType.LIFE.value, index=True)

    # Provider
    provider_name = Column(String(200), nullable=False)
    provider_type = Column(String(30))         # government | private
    provider_logo_url = Column(Text)

    # Coverage details
    coverage_amount = Column(Float, nullable=False)
    premium_monthly = Column(Float)
    premium_annual = Column(Float)
    coverage_description = Column(Text)
    coverage_description_hindi = Column(Text)
    exclusions = Column(Text)

    # Eligibility
    min_age = Column(Integer)
    max_age = Column(Integer)
    min_trust_score = Column(Integer)
    applicable_work_types = Column(Text)       # JSON list or "ALL"

    # Status
    is_active = Column(Boolean, default=True)
    valid_from = Column(DateTime)
    valid_until = Column(DateTime)

    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


class VerificationToken(Base):
    """
    Short-lived token used for OTP / magic-link verification flows.
    Supports phone verification, Aadhaar OTP, login, and income confirmation.
    """
    __tablename__ = "verification_tokens"

    id = Column(UUID(), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(UUID(), ForeignKey("users.id"), nullable=False, index=True)

    # Token data
    token = Column(String(10), nullable=False, index=True)  # the OTP / code
    purpose = Column(String(30), nullable=False, index=True)
    target = Column(String(100))             # phone number or entity being verified
    related_entity_id = Column(UUID())       # e.g. income_record_id for income OTP

    # Lifecycle
    is_used = Column(Boolean, default=False)
    used_at = Column(DateTime)
    expires_at = Column(DateTime, nullable=False)
    attempts = Column(Integer, default=0)    # wrong-entry counter
    max_attempts = Column(Integer, default=3)

    created_at = Column(DateTime, default=datetime.utcnow)

    # Relationships
    user = relationship("User", foreign_keys=[user_id])
