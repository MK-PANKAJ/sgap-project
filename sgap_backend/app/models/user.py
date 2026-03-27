"""
SGAP User Models
Core user entity with Worker and Employer profile extensions.
"""

from sqlalchemy import Column, String, Boolean, DateTime, Integer, Float, ForeignKey, Text
from sqlalchemy.types import TypeDecorator, CHAR
from sqlalchemy.orm import relationship
from app.database import Base
import uuid
from datetime import datetime


class UUID(TypeDecorator):
    """Platform-independent UUID type.
    Uses CHAR(36) to store UUIDs as strings, compatible with both SQLite and PostgreSQL.
    """
    impl = CHAR
    cache_ok = True

    def __init__(self):
        super().__init__(length=36)

    def process_bind_param(self, value, dialect):
        if value is not None:
            return str(value)
        return value

    def process_result_value(self, value, dialect):
        if value is not None:
            return str(value)
        return value


class User(Base):
    """Base user account — every person in the system has one."""
    __tablename__ = "users"

    id = Column(UUID(), primary_key=True, default=lambda: str(uuid.uuid4()))
    phone = Column(String(15), unique=True, nullable=False, index=True)
    phone_hash = Column(String(64))
    role = Column(String(20), nullable=False, default="worker")  # worker | employer | lender | admin
    language = Column(String(5), default="hi")
    is_verified = Column(Boolean, default=False)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    worker_profile = relationship(
        "WorkerProfile", back_populates="user", uselist=False, cascade="all, delete-orphan"
    )
    employer_profile = relationship(
        "EmployerProfile", back_populates="user", uselist=False, cascade="all, delete-orphan"
    )


class WorkerProfile(Base):
    """Extended profile for gig workers / daily-wage labourers."""
    __tablename__ = "worker_profiles"

    id = Column(UUID(), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(UUID(), ForeignKey("users.id"), unique=True, nullable=False)

    # Personal info
    name = Column(String(100), nullable=False)
    aadhaar_hash = Column(String(64))
    aadhaar_last_four = Column(String(4))
    is_aadhaar_verified = Column(Boolean, default=False)

    # Location
    city = Column(String(100))
    state = Column(String(100))
    pincode = Column(String(6))

    # Work details
    work_type = Column(String(50))
    profile_photo_url = Column(Text)

    # Trust & income aggregates
    trust_score = Column(Integer, default=300)
    trust_band = Column(String(20), default="building")  # building | fair | good | excellent
    total_income_logged = Column(Float, default=0.0)
    total_verified_income = Column(Float, default=0.0)
    employer_count = Column(Integer, default=0)

    created_at = Column(DateTime, default=datetime.utcnow)

    # Relationships
    user = relationship("User", back_populates="worker_profile")
    income_records = relationship("IncomeRecord", back_populates="worker", cascade="all, delete-orphan")
    loan_applications = relationship("LoanApplication", back_populates="worker", cascade="all, delete-orphan")
    trust_score_records = relationship("TrustScoreRecord", back_populates="worker", cascade="all, delete-orphan")


class EmployerProfile(Base):
    """Extended profile for employers / businesses who hire gig workers."""
    __tablename__ = "employer_profiles"

    id = Column(UUID(), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(UUID(), ForeignKey("users.id"), unique=True, nullable=False)

    # Business info
    business_name = Column(String(200), nullable=False)
    contact_person = Column(String(100))
    gst_number = Column(String(15))
    business_type = Column(String(50))

    # Location
    city = Column(String(100))
    state = Column(String(100))
    address = Column(Text)

    # Stats
    worker_count = Column(Integer, default=0)
    is_verified = Column(Boolean, default=False)

    created_at = Column(DateTime, default=datetime.utcnow)

    # Relationships
    user = relationship("User", back_populates="employer_profile")
