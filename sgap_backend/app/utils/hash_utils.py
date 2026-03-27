"""
SGAP Hashing Utilities
SHA-256 hashing for Aadhaar, phone, and income record integrity.
"""

import hashlib
import json
from datetime import datetime


def sha256_hash(data: str) -> str:
    """Return the hex SHA-256 digest of the input string."""
    return hashlib.sha256(data.encode()).hexdigest()


def hash_aadhaar(aadhaar_number: str) -> str:
    """One-way hash an Aadhaar number with an application-specific salt."""
    return sha256_hash(f"sgap-aadhaar-{aadhaar_number}-salt-2025")


def hash_phone(phone: str) -> str:
    """One-way hash a phone number with an application-specific salt."""
    return sha256_hash(f"sgap-phone-{phone}-salt-2025")


def generate_income_record_hash(
    worker_id: str,
    amount: float,
    work_date: str,
    timestamp: str = None,
) -> str:
    """
    Generate a tamper-proof hash for an income record.
    Deterministic for the same inputs — used to detect duplicates and tampering.
    """
    if timestamp is None:
        timestamp = datetime.utcnow().isoformat()
    data = json.dumps(
        {
            "worker_id": str(worker_id),
            "amount": float(amount),
            "work_date": str(work_date),
            "timestamp": timestamp,
        },
        sort_keys=True,
    )
    return sha256_hash(data)
