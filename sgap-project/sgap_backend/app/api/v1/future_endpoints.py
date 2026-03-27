"""
Future Endpoints — Planned features with roadmap info.
Each returns: status, phase, eta, description, description_hindi
"""

from fastapi import APIRouter
import logging

logger = logging.getLogger(__name__)
router = APIRouter()

ROADMAP = [
    {"phase": 1, "name": "Foundation", "status": "completed",
     "features": ["OTP Auth", "Voice Income Logging", "Trust Score", "Fraud Detection", "Micro-Loans"]},
    {"phase": 2, "name": "Growth", "status": "in_progress", "eta": "Q3 2025",
     "features": ["WhatsApp Bot", "Real Aadhaar eKYC", "Account Aggregator", "Worker Circles", "Auto-Save"]},
    {"phase": 3, "name": "Scale", "status": "planned", "eta": "Q4 2025",
     "features": ["USSD Access", "Blockchain Certificates", "UPI Collect", "DigiLocker", "IVR System"]},
    {"phase": 4, "name": "Ecosystem", "status": "planned", "eta": "Q1 2026",
     "features": ["Micro-SIP", "Ambassador Network", "Insurance Claims", "Credit Cards", "Remittances", "Govt Dashboard"]},
]


def _stub(phase: int, eta: str, desc: str, desc_hindi: str):
    return {"status": "planned", "phase": phase, "eta": eta,
            "description": desc, "description_hindi": desc_hindi}


@router.post("/whatsapp/send-message")
def whatsapp_send():
    return _stub(2, "Q3 2025", "Send templated WhatsApp messages to workers",
                 "कामगारों को WhatsApp संदेश भेजें")

@router.post("/aadhaar/real-ekyc")
def aadhaar_real_ekyc():
    return _stub(2, "Q3 2025", "Real Aadhaar eKYC via licensed ASA",
                 "लाइसेंस्ड ASA के माध्यम से आधार eKYC")

@router.post("/account-aggregator/link")
def aa_link():
    return _stub(2, "Q3 2025", "Link bank accounts via Account Aggregator framework",
                 "अकाउंट एग्रीगेटर से बैंक खाता जोड़ें")

@router.post("/worker-circles/create")
def worker_circles():
    return _stub(2, "Q3 2025", "Create savings circles among workers",
                 "कामगारों के बीच बचत समूह बनाएं")

@router.post("/savings/auto-save")
def auto_save():
    return _stub(2, "Q3 2025", "Auto-save a percentage of daily income",
                 "दैनिक आय का कुछ प्रतिशत स्वचालित बचत")

@router.post("/micro-sip/start")
def micro_sip():
    return _stub(4, "Q1 2026", "Start micro SIP investments from ₹10/day",
                 "₹10/दिन से माइक्रो SIP शुरू करें")

@router.post("/ussd/session")
def ussd_session():
    return _stub(3, "Q4 2025", "USSD-based access for feature phones",
                 "फ़ीचर फ़ोन के लिए USSD सेवा")

@router.get("/blockchain/certificate/{hash}")
def blockchain_cert(hash: str):
    return _stub(3, "Q4 2025", "Verify income certificate on blockchain",
                 "ब्लॉकचेन पर आय प्रमाणपत्र सत्यापन")

@router.post("/upi/collect")
def upi_collect():
    return _stub(3, "Q4 2025", "UPI collect request for loan repayments",
                 "लोन EMI के लिए UPI कलेक्ट")

@router.post("/digilocker/link")
def digilocker_link():
    return _stub(3, "Q4 2025", "Link DigiLocker for document verification",
                 "डिजिलॉकर से दस्तावेज़ सत्यापन")

@router.post("/ivr/call")
def ivr_call():
    return _stub(3, "Q4 2025", "IVR-based income logging via phone call",
                 "फ़ोन कॉल से आय दर्ज करें")

@router.post("/ambassador/register")
def ambassador_register():
    return _stub(4, "Q1 2026", "Register as a community ambassador",
                 "समुदाय एंबेसडर के रूप में पंजीकरण")

@router.post("/insurance/claim")
def insurance_claim():
    return _stub(4, "Q1 2026", "File an insurance claim",
                 "बीमा दावा दर्ज करें")

@router.post("/credit-card/apply")
def credit_card_apply():
    return _stub(4, "Q1 2026", "Apply for a credit card based on trust score",
                 "ट्रस्ट स्कोर से क्रेडिट कार्ड आवेदन")

@router.post("/remittance/send")
def remittance_send():
    return _stub(4, "Q1 2026", "Send money to family across India",
                 "भारत भर में परिवार को पैसे भेजें")

@router.get("/govt-dashboard/analytics")
def govt_dashboard():
    return _stub(4, "Q1 2026", "Government analytics dashboard for gig economy data",
                 "गिग इकॉनमी डेटा के लिए सरकारी डैशबोर्ड")

@router.get("/roadmap")
def get_roadmap():
    return {
        "platform": "S-GAP",
        "tagline": "Smart Gig-worker Assistance Platform",
        "total_phases": 4,
        "roadmap": ROADMAP,
    }
