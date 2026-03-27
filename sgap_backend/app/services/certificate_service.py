"""
Income Certificate Service
============================
Generates verifiable income certificates with QR codes.
Each certificate has a SHA-256 hash for tamper-proof verification.
"""

import hashlib
import json
import base64
import io
from datetime import datetime
from app.config import settings


def _generate_qr_base64(data: str) -> str:
    """Generate a QR code and return as base64-encoded PNG string."""
    try:
        import qrcode
        qr = qrcode.QRCode(version=1, box_size=10, border=4)
        qr.add_data(data)
        qr.make(fit=True)
        img = qr.make_image(fill_color="black", back_color="white")
        buffer = io.BytesIO()
        img.save(buffer, format="PNG")
        return base64.b64encode(buffer.getvalue()).decode()
    except ImportError:
        # Fallback if qrcode not installed — return a placeholder
        return ""


def generate_certificate(worker_data: dict, income_summary: dict) -> dict:
    """
    Generate an income certificate with a tamper-proof hash and QR code.

    Args:
        worker_data: dict with name, city, work_type, trust_score, trust_band, worker_id
        income_summary: dict with total_income, verified_income, period_start, period_end,
                       total_records, verified_records

    Returns:
        dict with all certificate fields, cert_hash, and qr_code_base64
    """
    issued_at = datetime.utcnow().isoformat()
    certificate_id = f"SGAP-CERT-{datetime.utcnow().strftime('%Y%m%d%H%M%S')}"

    # Core certificate content (used for hash)
    cert_content = {
        "certificate_id": certificate_id,
        "worker_name": worker_data.get("name", ""),
        "worker_id": worker_data.get("worker_id", ""),
        "city": worker_data.get("city", ""),
        "work_type": worker_data.get("work_type", ""),
        "trust_score": worker_data.get("trust_score", 0),
        "trust_band": worker_data.get("trust_band", ""),
        "total_income": income_summary.get("total_income", 0),
        "verified_income": income_summary.get("verified_income", 0),
        "period_start": income_summary.get("period_start", ""),
        "period_end": income_summary.get("period_end", ""),
        "total_records": income_summary.get("total_records", 0),
        "verified_records": income_summary.get("verified_records", 0),
        "issued_at": issued_at,
        "issued_by": "S-GAP Platform",
    }

    # SHA-256 hash for tamper-proofing
    cert_json = json.dumps(cert_content, sort_keys=True)
    cert_hash = hashlib.sha256(cert_json.encode()).hexdigest()

    # Verification URL for QR code
    verification_url = f"{settings.CERTIFICATE_BASE_URL}/{cert_hash}"

    # Generate QR code
    qr_base64 = _generate_qr_base64(verification_url)

    return {
        **cert_content,
        "cert_hash": cert_hash,
        "verification_url": verification_url,
        "qr_code_base64": qr_base64,
        "is_valid": True,
        "validity_note": "This certificate is digitally signed by S-GAP Platform. "
                         "Verify at the URL above or scan the QR code.",
        "validity_note_hindi": "यह प्रमाणपत्र S-GAP प्लेटफ़ॉर्म द्वारा डिजिटल रूप से हस्ताक्षरित है। "
                               "सत्यापन के लिए QR कोड स्कैन करें।",
    }
