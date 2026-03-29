"""
Auth API — OTP login, worker/employer registration, profile retrieval.
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.user import User, WorkerProfile, EmployerProfile
from app.utils.security import create_jwt_token, get_current_user
from app.utils.hash_utils import hash_phone, hash_aadhaar
from app.utils.helpers import clean_phone, validate_indian_phone, get_state_from_city
from app.config import settings
from pydantic import BaseModel
from typing import Optional
import random
import logging

logger = logging.getLogger(__name__)
router = APIRouter()

# In-memory OTP store (swap for Redis in production)
otp_store = {}


# ── Request schemas ──────────────────────────────────────────────────


class SendOtpRequest(BaseModel):
    phone: str


class VerifyOtpRequest(BaseModel):
    phone: str
    otp: str


class RegisterWorkerRequest(BaseModel):
    name: str
    city: str
    state: Optional[str] = ""
    work_type: str
    language: Optional[str] = "hi"
    aadhaar_number: Optional[str] = None


class RegisterEmployerRequest(BaseModel):
    business_name: str
    contact_person: Optional[str] = ""
    city: str
    state: Optional[str] = ""


# ── Endpoints ────────────────────────────────────────────────────────

@router.post("/send-otp")
def send_otp(request: SendOtpRequest, db: Session = Depends(get_db)):
    phone = clean_phone(request.phone)
    if not validate_indian_phone(phone):
        raise HTTPException(status_code=400, detail="Invalid phone number")

    otp = "123456" if settings.DEMO_MODE else str(random.randint(100000, 999999))
    otp_store[phone] = otp
    print(f"🔔 DEV MODE: The OTP for {phone} is {otp}")
    logger.info("OTP generated for %s", phone[:4] + "****")

    response = {"message": "OTP sent successfully", "phone": phone}
    if settings.DEMO_MODE:
        response["demo_otp"] = otp
    return response

@router.post("/verify-otp")
def verify_otp(request: VerifyOtpRequest, db: Session = Depends(get_db)):
    phone = clean_phone(request.phone)
    stored_otp = otp_store.get(phone)

    # Demo mode bypass
    if settings.DEMO_MODE and request.otp == "123456":
        pass
    elif stored_otp != request.otp:
        raise HTTPException(status_code=400, detail="Invalid OTP")

    otp_store.pop(phone, None)

    # Find or create user
    user = db.query(User).filter(User.phone == phone).first()
    is_new_user = user is None

    if is_new_user:
        user = User(
            phone=phone,
            phone_hash=hash_phone(phone),
            role="worker",
            is_verified=True,
        )
        db.add(user)
        db.commit()
        db.refresh(user)

    token = create_jwt_token({
        "user_id": str(user.id),
        "phone": phone,
        "role": user.role,
    })

    return {
        "token": token,
        "is_new_user": is_new_user,
        "user": {
            "id": str(user.id),
            "phone": user.phone,
            "role": user.role,
            "language": user.language,
        },
    }


@router.post("/register/worker")
def register_worker(
    request: RegisterWorkerRequest,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    user_id = current_user["user_id"]
    existing = db.query(WorkerProfile).filter(WorkerProfile.user_id == user_id).first()
    if existing:
        raise HTTPException(status_code=400, detail="Profile already exists")

    state = request.state or get_state_from_city(request.city)
    profile = WorkerProfile(
        user_id=user_id,
        name=request.name,
        city=request.city,
        state=state,
        work_type=request.work_type,
        trust_score=300,
        trust_band="building",
    )

    if request.aadhaar_number:
        profile.aadhaar_hash = hash_aadhaar(request.aadhaar_number)
        profile.aadhaar_last_four = request.aadhaar_number[-4:]

    user = db.query(User).filter(User.id == user_id).first()
    if user:
        user.language = request.language

    db.add(profile)
    db.commit()
    db.refresh(profile)

    return {
        "id": str(profile.id),
        "name": profile.name,
        "city": profile.city,
        "state": profile.state,
        "work_type": profile.work_type,
        "trust_score": profile.trust_score,
        "trust_band": profile.trust_band,
        "is_aadhaar_verified": profile.is_aadhaar_verified,
    }


@router.post("/register/employer")
def register_employer(
    request: RegisterEmployerRequest,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    user_id = current_user["user_id"]
    user = db.query(User).filter(User.id == user_id).first()
    if user:
        user.role = "employer"

    state = request.state or get_state_from_city(request.city)
    profile = EmployerProfile(
        user_id=user_id,
        business_name=request.business_name,
        contact_person=request.contact_person,
        city=request.city,
        state=state,
    )
    db.add(profile)
    db.commit()
    db.refresh(profile)

    return {
        "id": str(profile.id),
        "business_name": profile.business_name,
        "city": profile.city,
    }


@router.get("/me")
def get_me(
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    user = db.query(User).filter(User.id == current_user["user_id"]).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    response = {
        "id": str(user.id),
        "phone": user.phone,
        "role": user.role,
        "language": user.language,
    }

    if user.role == "worker" and user.worker_profile:
        wp = user.worker_profile
        response["profile"] = {
            "id": str(wp.id),
            "name": wp.name,
            "city": wp.city,
            "trust_score": wp.trust_score,
            "trust_band": wp.trust_band,
            "total_income_logged": wp.total_income_logged,
        }

    return response
