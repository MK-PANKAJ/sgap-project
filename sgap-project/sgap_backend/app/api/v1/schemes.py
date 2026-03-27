"""
Schemes API — Government schemes, recommended schemes, and insurance plans.
"""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.user import WorkerProfile
from app.models.scheme import GovernmentScheme, InsurancePlan
from app.utils.security import get_current_user
from typing import Optional
import logging

logger = logging.getLogger(__name__)
router = APIRouter()

_seeded = False

DEMO_SCHEMES = [
    {
        "name": "Pradhan Mantri Jan Dhan Yojana",
        "name_hindi": "प्रधानमंत्री जन धन योजना",
        "code": "PMJDY",
        "category": "financial_inclusion",
        "description": "Financial inclusion scheme providing bank accounts with overdraft facility and insurance.",
        "description_hindi": "बैंक खाता, ओवरड्राफ्ट और बीमा सुविधा के साथ वित्तीय समावेशन योजना।",
        "benefits": "Zero-balance bank account, ₹10,000 overdraft, ₹2 lakh accident insurance",
        "min_age": 18, "max_age": 65,
        "ministry": "Ministry of Finance",
    },
    {
        "name": "PM Shram Yogi Maan-dhan",
        "name_hindi": "पीएम श्रम योगी मानधन",
        "code": "PMSYM",
        "category": "pension",
        "description": "Pension scheme for unorganised workers. ₹3,000/month pension after 60.",
        "description_hindi": "असंगठित श्रमिकों के लिए पेंशन योजना। 60 के बाद ₹3,000/महीना।",
        "benefits": "₹3,000 monthly pension after age 60",
        "min_age": 18, "max_age": 40, "max_income": 15000,
        "ministry": "Ministry of Labour & Employment",
    },
    {
        "name": "Pradhan Mantri Jeevan Jyoti Bima Yojana",
        "name_hindi": "प्रधानमंत्री जीवन ज्योति बीमा योजना",
        "code": "PMJJBY",
        "category": "insurance",
        "description": "Life insurance scheme at ₹436/year for ₹2 lakh coverage.",
        "description_hindi": "₹436/वर्ष में ₹2 लाख का जीवन बीमा।",
        "benefits": "₹2 lakh life insurance cover at ₹436/year",
        "min_age": 18, "max_age": 50,
        "ministry": "Ministry of Finance",
    },
    {
        "name": "Pradhan Mantri Suraksha Bima Yojana",
        "name_hindi": "प्रधानमंत्री सुरक्षा बीमा योजना",
        "code": "PMSBY",
        "category": "insurance",
        "description": "Accident insurance at ₹20/year for ₹2 lakh coverage.",
        "description_hindi": "₹20/वर्ष में ₹2 लाख का दुर्घटना बीमा।",
        "benefits": "₹2 lakh accident insurance at ₹20/year",
        "min_age": 18, "max_age": 70,
        "ministry": "Ministry of Finance",
    },
    {
        "name": "Pradhan Mantri Awas Yojana",
        "name_hindi": "प्रधानमंत्री आवास योजना",
        "code": "PMAY",
        "category": "housing",
        "description": "Affordable housing with interest subsidy for economically weaker sections.",
        "description_hindi": "किफ़ायती आवास — ब्याज सब्सिडी के साथ।",
        "benefits": "Interest subsidy up to ₹2.67 lakh on home loans",
        "min_age": 18, "max_income": 18000,
        "ministry": "Ministry of Housing & Urban Affairs",
    },
    {
        "name": "Ayushman Bharat - PMJAY",
        "name_hindi": "आयुष्मान भारत - पीएमजेएवाई",
        "code": "PMJAY",
        "category": "health",
        "description": "Health insurance of ₹5 lakh per family per year.",
        "description_hindi": "₹5 लाख/वर्ष का स्वास्थ्य बीमा।",
        "benefits": "₹5 lakh health insurance per family per year",
        "min_age": 0, "max_age": 100,
        "ministry": "Ministry of Health & Family Welfare",
    },
]

DEMO_INSURANCE = [
    {
        "name": "PMJJBY Life Cover",
        "name_hindi": "पीएमजेजेबीवाई जीवन बीमा",
        "plan_code": "PMJJBY-LIFE",
        "insurance_type": "life",
        "provider_name": "LIC of India",
        "provider_type": "government",
        "coverage_amount": 200000,
        "premium_monthly": 36,
        "premium_annual": 436,
        "min_age": 18, "max_age": 50,
    },
    {
        "name": "PMSBY Accident Cover",
        "name_hindi": "पीएमएसबीवाई दुर्घटना बीमा",
        "plan_code": "PMSBY-ACCIDENT",
        "insurance_type": "accident",
        "provider_name": "General Insurance Corp",
        "provider_type": "government",
        "coverage_amount": 200000,
        "premium_monthly": 2,
        "premium_annual": 20,
        "min_age": 18, "max_age": 70,
    },
    {
        "name": "GigShield Health Micro",
        "name_hindi": "गिगशील्ड स्वास्थ्य बीमा",
        "plan_code": "GIG-HEALTH-001",
        "insurance_type": "health",
        "provider_name": "GigShield Insurance",
        "provider_type": "private",
        "coverage_amount": 100000,
        "premium_monthly": 99,
        "premium_annual": 999,
        "min_age": 18, "max_age": 60,
    },
]


def _seed_demo_data(db: Session):
    global _seeded
    if _seeded:
        return
    _seeded = True
    if db.query(GovernmentScheme).count() == 0:
        for s in DEMO_SCHEMES:
            db.add(GovernmentScheme(**s, is_active=True))
        db.commit()
    if db.query(InsurancePlan).count() == 0:
        for p in DEMO_INSURANCE:
            db.add(InsurancePlan(**p, is_active=True))
        db.commit()


@router.get("/all")
def get_all_schemes(
    category: Optional[str] = None,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """List all government schemes with optional category filter."""
    _seed_demo_data(db)
    query = db.query(GovernmentScheme).filter(GovernmentScheme.is_active == True)
    if category:
        query = query.filter(GovernmentScheme.category == category)
    schemes = query.all()
    return {
        "total": len(schemes),
        "schemes": [
            {
                "id": str(s.id),
                "name": s.name,
                "name_hindi": s.name_hindi,
                "code": s.code,
                "category": s.category,
                "description": s.description,
                "description_hindi": s.description_hindi,
                "benefits": s.benefits,
                "ministry": s.ministry,
            }
            for s in schemes
        ],
    }


@router.get("/recommended/{worker_id}")
def get_recommended_schemes(
    worker_id: str,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Recommend government schemes based on worker profile."""
    _seed_demo_data(db)
    worker = db.query(WorkerProfile).filter(WorkerProfile.id == worker_id).first()
    if not worker:
        raise HTTPException(status_code=404, detail="Worker not found")

    schemes = db.query(GovernmentScheme).filter(GovernmentScheme.is_active == True).all()
    monthly_income = (worker.total_income_logged or 0) / 3

    recommended = []
    for s in schemes:
        match_score = 0
        reasons = []
        if s.max_income and monthly_income <= s.max_income:
            match_score += 30
            reasons.append("Income eligible")
        if s.category == "financial_inclusion":
            match_score += 40
            reasons.append("Essential financial service")
        if s.category == "insurance":
            match_score += 25
            reasons.append("Basic protection needed")
        if s.category == "pension":
            match_score += 20
            reasons.append("Start early for pension benefits")
        if s.category == "health":
            match_score += 35
            reasons.append("Healthcare coverage")
        if match_score > 0:
            recommended.append({
                "scheme_id": str(s.id),
                "name": s.name,
                "name_hindi": s.name_hindi,
                "code": s.code,
                "category": s.category,
                "benefits": s.benefits,
                "match_score": match_score,
                "match_reasons": reasons,
            })

    recommended.sort(key=lambda x: x["match_score"], reverse=True)
    return {
        "worker_id": worker_id,
        "worker_name": worker.name,
        "total_recommended": len(recommended),
        "schemes": recommended,
    }


@router.get("/insurance/plans")
def get_insurance_plans(
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """List all insurance plans."""
    _seed_demo_data(db)
    plans = db.query(InsurancePlan).filter(InsurancePlan.is_active == True).all()
    return {
        "total": len(plans),
        "plans": [
            {
                "id": str(p.id),
                "name": p.name,
                "name_hindi": p.name_hindi,
                "plan_code": p.plan_code,
                "insurance_type": p.insurance_type,
                "provider_name": p.provider_name,
                "provider_type": p.provider_type,
                "coverage_amount": p.coverage_amount,
                "premium_monthly": p.premium_monthly,
                "premium_annual": p.premium_annual,
            }
            for p in plans
        ],
    }
