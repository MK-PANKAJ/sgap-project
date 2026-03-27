"""
Verification API — Certificate verification and Aadhaar sandbox eKYC.
"""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.user import WorkerProfile
from app.utils.security import get_current_user
from app.utils.hash_utils import hash_aadhaar
from pydantic import BaseModel
from typing import Optional
import random
import logging

logger = logging.getLogger(__name__)
router = APIRouter()

# In-memory certificate store for demo verification
certificate_store = {}


class AadhaarVerifyRequest(BaseModel):
    worker_id: str
    aadhaar_number: str
    name: str
    dob: Optional[str] = ""


@router.get("/certificate/{cert_hash}")
def verify_certificate(
    cert_hash: str,
    db: Session = Depends(get_db),
):
    """Verify an income certificate by its SHA-256 hash (public endpoint)."""
    stored = certificate_store.get(cert_hash)
    if stored:
        return {
            "is_valid": True,
            "certificate": stored,
            "message": "Certificate verified successfully",
            "message_hindi": "प्रमाणपत्र सत्यापित!",
        }

    return {
        "is_valid": False,
        "message": "Certificate not found or invalid",
        "message_hindi": "प्रमाणपत्र नहीं मिला या अमान्य है।",
    }


@router.post("/aadhaar-sandbox")
def aadhaar_sandbox_verify(
    request: AadhaarVerifyRequest,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    Simulated Aadhaar eKYC verification (sandbox mode).
    In production, this would call UIDAI APIs via a licensed ASA.
    """
    if len(request.aadhaar_number) != 12 or not request.aadhaar_number.isdigit():
        raise HTTPException(status_code=400, detail="Aadhaar must be 12 digits")

    worker = db.query(WorkerProfile).filter(
        WorkerProfile.id == request.worker_id
    ).first()
    if not worker:
        raise HTTPException(status_code=404, detail="Worker not found")

    # Simulate verification (always succeeds in sandbox)
    worker.aadhaar_hash = hash_aadhaar(request.aadhaar_number)
    worker.aadhaar_last_four = request.aadhaar_number[-4:]
    worker.is_aadhaar_verified = True
    db.commit()

    # Simulated eKYC response
    return {
        "status": "success",
        "is_verified": True,
        "worker_id": request.worker_id,
        "aadhaar_last_four": request.aadhaar_number[-4:],
        "name_match": True,
        "sandbox_mode": True,
        "message": "Aadhaar verified successfully (sandbox mode)",
        "message_hindi": "आधार सत्यापित (सैंडबॉक्स मोड)",
        "ekyc_data": {
            "name": request.name,
            "dob": request.dob or "1990-01-01",
            "gender": "M",
            "address": {"state": worker.state or "", "city": worker.city or ""},
            "photo_base64": "",
        },
    }
