"""
S-GAP Seed Data Script
========================
Seeds the database with demo data for hackathon presentations.

Usage:
    cd sgap_backend
    python seed_data.py

Creates:
  - 3 demo workers (रामू भाई, लक्ष्मी देवी, अर्जुन कुमार)
  - 1 demo employer (सुरेश कंस्ट्रक्शन)
  - 5 lenders (MFI, NBFC, bank types)
  - 6 government schemes (real Indian schemes)
  - 3 insurance plans
  - 30 income records for रामू भाई
  - 6-month trust score history for रामू भाई
  - Trains ML models if not already saved
"""

import sys
import os
import random
import uuid
from datetime import datetime, timedelta, date

# Ensure project root is on path
sys.path.insert(0, os.path.dirname(__file__))

from app.database import engine, SessionLocal, Base
from app.models.user import User, WorkerProfile, EmployerProfile
from app.models.income_record import IncomeRecord
from app.models.trust_score import TrustScoreRecord, TrustScoreHistory
from app.models.loan import Lender, LoanApplication, LoanOffer, LoanRepayment
from app.models.scheme import GovernmentScheme, InsurancePlan, VerificationToken
from app.utils.hash_utils import hash_phone, hash_aadhaar, generate_income_record_hash


def seed():
    print("=" * 60)
    print("  S-GAP Demo Data Seeder")
    print("=" * 60)

    # ── Step 1: Create tables ────────────────────────────────────────
    print("\n📦 Creating database tables...")
    Base.metadata.create_all(bind=engine)
    print("   ✅ All 13 tables created")

    # ── Step 2: Train ML models ──────────────────────────────────────
    print("\n🤖 Checking ML models...")
    models_dir = os.path.join(os.path.dirname(__file__), "app", "ml", "models")
    credit_path = os.path.join(models_dir, "credit_model.pkl")
    fraud_path = os.path.join(models_dir, "fraud_model.pkl")

    if os.path.exists(credit_path) and os.path.exists(fraud_path):
        print("   ✅ ML models already trained")
    else:
        print("   🔄 Training ML models...")
        from app.ml.credit_scoring_model import credit_model
        from app.ml.fraud_detection_model import fraud_model
        cr = credit_model.train()
        fr = fraud_model.train()
        print(f"   ✅ Credit model R² = {cr['test_r2']}")
        print(f"   ✅ Fraud model trained (contamination={fr['contamination']})")

    # ── Step 3: Seed data ────────────────────────────────────────────
    db = SessionLocal()

    try:
        # Check if already seeded
        existing = db.query(User).filter(User.phone == "9999900001").first()
        if existing:
            print("\n⚠️  Demo data already exists! Skipping seed.")
            print("   Delete sgap_dev.db and re-run to reseed.")
            _print_summary()
            return

        print("\n👤 Creating demo users...")
        _seed_users(db)

        print("\n🏦 Creating lenders...")
        _seed_lenders(db)

        print("\n🏛️  Creating government schemes...")
        _seed_schemes(db)

        print("\n🛡️  Creating insurance plans...")
        _seed_insurance(db)

        print("\n📝 Creating income records for रामू भाई (30 days)...")
        _seed_income_records(db)

        print("\n📈 Creating trust score history for रामू भाई...")
        _seed_trust_history(db)

        print("\n✅ All demo data seeded successfully!")
        _print_summary()

    except Exception as e:
        db.rollback()
        print(f"\n❌ Error: {e}")
        raise
    finally:
        db.close()


# ═══════════════════════════════════════════════════════════════════════
# Seed functions
# ═══════════════════════════════════════════════════════════════════════


def _seed_users(db):
    """Create 3 demo workers + 1 employer."""
    random.seed(42)

    # ── Worker 1: रामू भाई (Construction, Delhi, score 720) ──────────
    user1 = User(
        id=str(uuid.uuid5(uuid.NAMESPACE_DNS, "ramu")),
        phone="9999900001",
        phone_hash=hash_phone("9999900001"),
        role="worker",
        language="hi",
        is_verified=True,
    )
    db.add(user1)
    db.flush()

    wp1 = WorkerProfile(
        id=str(uuid.uuid5(uuid.NAMESPACE_DNS, "ramu-profile")),
        user_id=user1.id,
        name="रामू भाई",
        city="Delhi",
        state="Delhi",
        pincode="110001",
        work_type="Construction",
        aadhaar_hash=hash_aadhaar("998877665544"),
        aadhaar_last_four="5544",
        is_aadhaar_verified=True,
        trust_score=720,
        trust_band="good",
        total_income_logged=27500.0,
        total_verified_income=22000.0,
        employer_count=3,
    )
    db.add(wp1)

    # ── Worker 2: लक्ष्मी देवी (Domestic, Mumbai, score 650) ────────
    user2 = User(
        id=str(uuid.uuid5(uuid.NAMESPACE_DNS, "lakshmi")),
        phone="9999900002",
        phone_hash=hash_phone("9999900002"),
        role="worker",
        language="hi",
        is_verified=True,
    )
    db.add(user2)
    db.flush()

    wp2 = WorkerProfile(
        id=str(uuid.uuid5(uuid.NAMESPACE_DNS, "lakshmi-profile")),
        user_id=user2.id,
        name="लक्ष्मी देवी",
        city="Mumbai",
        state="Maharashtra",
        pincode="400001",
        work_type="Domestic",
        aadhaar_hash=hash_aadhaar("887766554433"),
        aadhaar_last_four="4433",
        is_aadhaar_verified=True,
        trust_score=650,
        trust_band="good",
        total_income_logged=18000.0,
        total_verified_income=14000.0,
        employer_count=2,
    )
    db.add(wp2)

    # ── Worker 3: अर्जुन कुमार (Delivery, Bangalore, score 580) ────
    user3 = User(
        id=str(uuid.uuid5(uuid.NAMESPACE_DNS, "arjun")),
        phone="9999900003",
        phone_hash=hash_phone("9999900003"),
        role="worker",
        language="hi",
        is_verified=True,
    )
    db.add(user3)
    db.flush()

    wp3 = WorkerProfile(
        id=str(uuid.uuid5(uuid.NAMESPACE_DNS, "arjun-profile")),
        user_id=user3.id,
        name="अर्जुन कुमार",
        city="Bangalore",
        state="Karnataka",
        pincode="560001",
        work_type="Delivery",
        trust_score=580,
        trust_band="fair",
        total_income_logged=12000.0,
        total_verified_income=6000.0,
        employer_count=1,
    )
    db.add(wp3)

    # ── Employer: सुरेश कंस्ट्रक्शन ────────────────────────────────
    user_emp = User(
        id=str(uuid.uuid5(uuid.NAMESPACE_DNS, "suresh-employer")),
        phone="9999900010",
        phone_hash=hash_phone("9999900010"),
        role="employer",
        language="hi",
        is_verified=True,
    )
    db.add(user_emp)
    db.flush()

    ep = EmployerProfile(
        id=str(uuid.uuid5(uuid.NAMESPACE_DNS, "suresh-employer-profile")),
        user_id=user_emp.id,
        business_name="सुरेश कंस्ट्रक्शन",
        contact_person="सुरेश ठेकेदार",
        business_type="Construction",
        city="Delhi",
        state="Delhi",
        address="Nehru Place, New Delhi",
        worker_count=15,
        is_verified=True,
    )
    db.add(ep)

    db.commit()
    print("   ✅ रामू भाई (9999900001) — Construction, Delhi, Score: 720")
    print("   ✅ लक्ष्मी देवी (9999900002) — Domestic, Mumbai, Score: 650")
    print("   ✅ अर्जुन कुमार (9999900003) — Delivery, Bangalore, Score: 580")
    print("   ✅ सुरेश कंस्ट्रक्शन (9999900010) — Employer, Delhi")


def _seed_lenders(db):
    """Create 5 lending institutions."""
    lenders_data = [
        {
            "institution_name": "JanSeva MicroFin",
            "institution_type": "mfi",
            "rbi_registration": "MFI-2024-001",
            "contact_person": "Rajesh Sharma",
            "contact_email": "contact@janseva.in",
            "city": "Mumbai", "state": "Maharashtra",
            "min_loan_amount": 1000, "max_loan_amount": 25000,
            "min_trust_score": 400,
            "interest_rate_min": 18.0, "interest_rate_max": 24.0,
        },
        {
            "institution_name": "GigCredit NBFC",
            "institution_type": "nbfc",
            "rbi_registration": "NBFC-2024-042",
            "contact_person": "Priya Kapoor",
            "contact_email": "loans@gigcredit.in",
            "city": "Delhi", "state": "Delhi",
            "min_loan_amount": 5000, "max_loan_amount": 100000,
            "min_trust_score": 500,
            "interest_rate_min": 12.0, "interest_rate_max": 18.0,
        },
        {
            "institution_name": "NanoPay Finance",
            "institution_type": "fintech",
            "rbi_registration": "NBFC-2024-088",
            "contact_person": "Amit Patel",
            "contact_email": "hello@nanopay.in",
            "city": "Bangalore", "state": "Karnataka",
            "min_loan_amount": 500, "max_loan_amount": 15000,
            "min_trust_score": 350,
            "interest_rate_min": 20.0, "interest_rate_max": 28.0,
        },
        {
            "institution_name": "Bharat Small Finance Bank",
            "institution_type": "bank",
            "rbi_registration": "SFB-2023-015",
            "contact_person": "Sunita Verma",
            "contact_email": "microloans@bharatsfb.in",
            "city": "Chennai", "state": "Tamil Nadu",
            "min_loan_amount": 10000, "max_loan_amount": 200000,
            "min_trust_score": 600,
            "interest_rate_min": 10.0, "interest_rate_max": 14.0,
        },
        {
            "institution_name": "Sahara Micro Loans",
            "institution_type": "mfi",
            "rbi_registration": "MFI-2024-027",
            "contact_person": "Deepak Singh",
            "contact_email": "info@saharamicro.in",
            "city": "Lucknow", "state": "Uttar Pradesh",
            "min_loan_amount": 2000, "max_loan_amount": 50000,
            "min_trust_score": 450,
            "interest_rate_min": 15.0, "interest_rate_max": 22.0,
        },
    ]

    # Each lender needs a dummy user
    for i, ld in enumerate(lenders_data):
        lender_user = User(
            id=str(uuid.uuid5(uuid.NAMESPACE_DNS, f"lender-{i}")),
            phone=f"888800000{i}",
            phone_hash=hash_phone(f"888800000{i}"),
            role="lender",
            is_verified=True,
        )
        db.add(lender_user)
        db.flush()

        lender = Lender(
            user_id=lender_user.id,
            is_active=True,
            is_verified=True,
            **ld,
        )
        db.add(lender)
        print(f"   ✅ {ld['institution_name']} ({ld['institution_type']}) — "
              f"{ld['interest_rate_min']}-{ld['interest_rate_max']}%, "
              f"min score {ld['min_trust_score']}")

    db.commit()


def _seed_schemes(db):
    """Create 6 real Indian government schemes."""
    schemes = [
        {
            "name": "PM Suraksha Bima Yojana",
            "name_hindi": "प्रधानमंत्री सुरक्षा बीमा योजना",
            "code": "PMSBY",
            "category": "insurance",
            "description": "Accident insurance cover of ₹2 lakh at just ₹12/year for all bank account holders aged 18-70.",
            "description_hindi": "₹12/वर्ष में ₹2 लाख का दुर्घटना बीमा। 18-70 वर्ष के सभी बैंक खाताधारकों के लिए।",
            "benefits": "₹2 lakh accidental death cover, ₹1 lakh partial disability cover at ₹12/year",
            "benefits_hindi": "₹2 लाख दुर्घटना मृत्यु कवर, ₹1 लाख आंशिक विकलांगता कवर — सिर्फ ₹12/वर्ष",
            "min_age": 18, "max_age": 70,
            "ministry": "Ministry of Finance",
            "official_url": "https://jansuraksha.gov.in/",
        },
        {
            "name": "PM Jeevan Jyoti Bima Yojana",
            "name_hindi": "प्रधानमंत्री जीवन ज्योति बीमा योजना",
            "code": "PMJJBY",
            "category": "insurance",
            "description": "Life insurance of ₹2 lakh at ₹436/year for any cause of death. Ages 18-50.",
            "description_hindi": "₹436/वर्ष में ₹2 लाख का जीवन बीमा। किसी भी कारण से मृत्यु पर।",
            "benefits": "₹2 lakh life insurance cover at ₹436/year — any cause of death",
            "benefits_hindi": "₹2 लाख जीवन बीमा — ₹436/वर्ष",
            "min_age": 18, "max_age": 50,
            "ministry": "Ministry of Finance",
            "official_url": "https://jansuraksha.gov.in/",
        },
        {
            "name": "Ayushman Bharat - PMJAY",
            "name_hindi": "आयुष्मान भारत - पीएम जन आरोग्य योजना",
            "code": "PMJAY",
            "category": "health",
            "description": "₹5 lakh per family per year health insurance for secondary and tertiary care hospitalisation.",
            "description_hindi": "₹5 लाख/वर्ष प्रति परिवार स्वास्थ्य बीमा। अस्पताल में भर्ती के खर्च के लिए।",
            "benefits": "Cashless treatment at empanelled hospitals, ₹5 lakh cover per family",
            "benefits_hindi": "एम्पैनल्ड अस्पतालों में कैशलेस इलाज, ₹5 लाख प्रति परिवार",
            "min_age": 0, "max_age": 100,
            "ministry": "Ministry of Health & Family Welfare",
            "official_url": "https://pmjay.gov.in/",
        },
        {
            "name": "e-Shram Card",
            "name_hindi": "ई-श्रम कार्ड",
            "code": "ESHRAM",
            "category": "livelihood",
            "description": "Universal worker identity card for unorganised workers with ₹2 lakh accidental insurance.",
            "description_hindi": "असंगठित कामगारों के लिए पहचान पत्र + ₹2 लाख दुर्घटना बीमा।",
            "benefits": "Unique worker ID (UAN), ₹2 lakh accident insurance, access to govt schemes",
            "benefits_hindi": "यूनिक वर्कर आईडी, ₹2 लाख दुर्घटना बीमा, सरकारी योजनाओं का लाभ",
            "min_age": 16, "max_age": 59,
            "max_income": 15000,
            "ministry": "Ministry of Labour & Employment",
            "official_url": "https://eshram.gov.in/",
        },
        {
            "name": "PM Mudra Yojana",
            "name_hindi": "प्रधानमंत्री मुद्रा योजना",
            "code": "PMMY",
            "category": "financial_inclusion",
            "description": "Collateral-free loans up to ₹10 lakh for micro/small businesses. Shishu (up to ₹50K), Kishor (₹50K-5L), Tarun (₹5L-10L).",
            "description_hindi": "₹10 लाख तक बिना गारंटी लोन। शिशु (₹50K तक), किशोर (₹50K-5L), तरुण (₹5L-10L)।",
            "benefits": "Collateral-free loans, no processing fee, flexible repayment",
            "benefits_hindi": "बिना गारंटी लोन, कोई प्रोसेसिंग फीस नहीं, लचीला भुगतान",
            "min_age": 18,
            "ministry": "Ministry of Finance",
            "official_url": "https://mudra.org.in/",
        },
        {
            "name": "PM Vishwakarma Yojana",
            "name_hindi": "प्रधानमंत्री विश्वकर्मा योजना",
            "code": "PMVY",
            "category": "skill_training",
            "description": "Skill training + toolkit + ₹3 lakh collateral-free loan at 5% for traditional artisans and craftspeople.",
            "description_hindi": "पारंपरिक कारीगरों के लिए स्किल ट्रेनिंग + टूलकिट + ₹3 लाख लोन 5% ब्याज पर।",
            "benefits": "5-day skill training, modern toolkit, ₹3 lakh loan at 5%, digital access",
            "benefits_hindi": "5 दिन ट्रेनिंग, आधुनिक टूलकिट, ₹3 लाख लोन 5% पर, डिजिटल पहुँच",
            "min_age": 18,
            "ministry": "Ministry of MSME",
            "official_url": "https://pmvishwakarma.gov.in/",
        },
    ]

    for s in schemes:
        db.add(GovernmentScheme(**s, is_active=True))
        print(f"   ✅ {s['code']}: {s['name_hindi']}")

    db.commit()


def _seed_insurance(db):
    """Create 3 insurance plans."""
    plans = [
        {
            "name": "PMJJBY Life Cover",
            "name_hindi": "जीवन ज्योति जीवन बीमा",
            "plan_code": "PMJJBY-LIFE",
            "insurance_type": "life",
            "provider_name": "LIC of India",
            "provider_type": "government",
            "coverage_amount": 200000,
            "premium_monthly": 36, "premium_annual": 436,
            "coverage_description": "₹2 lakh life cover for death due to any cause",
            "coverage_description_hindi": "किसी भी कारण से मृत्यु पर ₹2 लाख जीवन बीमा",
            "min_age": 18, "max_age": 50,
        },
        {
            "name": "PMSBY Accident Cover",
            "name_hindi": "सुरक्षा बीमा दुर्घटना कवर",
            "plan_code": "PMSBY-ACCIDENT",
            "insurance_type": "accident",
            "provider_name": "National Insurance Co",
            "provider_type": "government",
            "coverage_amount": 200000,
            "premium_monthly": 1, "premium_annual": 12,
            "coverage_description": "₹2 lakh accidental death, ₹1 lakh partial disability",
            "coverage_description_hindi": "₹2 लाख दुर्घटना मृत्यु, ₹1 लाख आंशिक विकलांगता",
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
            "premium_monthly": 99, "premium_annual": 999,
            "coverage_description": "₹1 lakh health cover for OPD + hospitalisation",
            "coverage_description_hindi": "₹1 लाख OPD + अस्पताल भर्ती स्वास्थ्य कवर",
            "min_age": 18, "max_age": 60,
        },
    ]

    for p in plans:
        db.add(InsurancePlan(**p, is_active=True))
        print(f"   ✅ {p['plan_code']}: {p['name']} — ₹{p['premium_annual']}/year")

    db.commit()


def _seed_income_records(db):
    """Generate 30 income records for रामू भाई over the past 30 days."""
    random.seed(42)
    ramu_profile_id = str(uuid.uuid5(uuid.NAMESPACE_DNS, "ramu-profile"))

    employers = [
        ("सुरेश ठेकेदार", "9876500001"),
        ("राजेश सेठ", "9876500002"),
        ("मोहन लाल", "9876500003"),
    ]

    work_descriptions = [
        "ईंट ढुलाई और प्लास्टर का काम",
        "सीमेंट घोलना और दीवार बनाना",
        "लोहा काटना और सरिया बांधना",
        "मिस्त्री का काम — छत ढलाई",
        "टाइल्स लगाना और फ़र्श बनाना",
        "पेंटिंग और पुताई का काम",
        "गड्ढा खोदना और नींव भरना",
        "पानी की टंकी बनाना",
    ]

    transcription_templates = [
        "aaj {employer} ke yahan se {amount} rupaye mile {desc}",
        "{employer} bhai se {amount} ka kaam kiya {desc}",
        "aaj {amount} rupaye kamaye {employer} se {desc}",
        "{employer} seth ne {amount} diye aaj ka kaam karke {desc}",
    ]

    # Delhi coords near construction sites
    base_lat, base_lon = 28.6139, 77.2090

    records_created = 0
    for day_offset in range(30, 0, -1):
        work_day = date.today() - timedelta(days=day_offset)
        amount = random.choice([600, 700, 750, 800, 850, 900, 950, 1000, 1100, 1200])
        emp_name, emp_phone = random.choice(employers)
        desc = random.choice(work_descriptions)
        tmpl = random.choice(transcription_templates)

        # 80% confirmed, 20% pending
        if random.random() < 0.8:
            status = "employer_confirmed"
        else:
            status = "pending"

        record_hash = generate_income_record_hash(
            ramu_profile_id, amount, str(work_day),
            timestamp=datetime(work_day.year, work_day.month, work_day.day, 18, 0).isoformat(),
        )

        transcription = tmpl.format(employer=emp_name, amount=amount, desc=desc)

        record = IncomeRecord(
            worker_id=ramu_profile_id,
            amount=float(amount),
            currency="INR",
            work_date=work_day,
            work_type="Construction",
            work_description=desc,
            hours_worked=round(random.uniform(7, 10), 1),
            employer_name=emp_name,
            employer_phone=emp_phone,
            voice_transcription=transcription,
            voice_language="hi",
            voice_confidence=round(random.uniform(0.78, 0.96), 2),
            voice_amount_extracted=float(amount),
            gps_latitude=round(base_lat + random.uniform(-0.02, 0.02), 6),
            gps_longitude=round(base_lon + random.uniform(-0.02, 0.02), 6),
            gps_accuracy_meters=round(random.uniform(3, 15), 1),
            location_city="Delhi",
            location_state="Delhi",
            verification_status=status,
            verified_at=datetime.utcnow() if status == "employer_confirmed" else None,
            record_hash=record_hash,
            fraud_score=round(random.uniform(0.01, 0.15), 3),
            trust_points_earned=10 if status == "employer_confirmed" else 5,
            created_at=datetime(work_day.year, work_day.month, work_day.day,
                                random.randint(17, 20), random.randint(0, 59)),
        )
        db.add(record)
        records_created += 1

    db.commit()

    confirmed = sum(1 for _ in range(30) if random.random() < 0.8)
    print(f"   ✅ {records_created} income records created")
    print(f"      Employers: सुरेश ठेकेदार, राजेश सेठ, मोहन लाल")
    print(f"      Amounts: ₹600 – ₹1,200 range")
    print(f"      ~80% employer_confirmed, ~20% pending")


def _seed_trust_history(db):
    """Generate 6-month trust score history for रामू भाई."""
    ramu_profile_id = str(uuid.uuid5(uuid.NAMESPACE_DNS, "ramu-profile"))
    random.seed(42)

    now = datetime.utcnow()
    score = 420  # Starting score 6 months ago

    for i in range(6, 0, -1):
        snapshot_date = now - timedelta(days=30 * i)
        growth = random.randint(30, 70)
        score = min(score + growth, 900)

        if score >= 800:
            band = "excellent"
        elif score >= 650:
            band = "good"
        elif score >= 500:
            band = "fair"
        else:
            band = "building"

        month_num = 7 - i
        income_factor = month_num * random.uniform(3000, 5000)
        verified_factor = income_factor * random.uniform(0.7, 0.9)

        entry = TrustScoreHistory(
            worker_id=ramu_profile_id,
            score=score,
            band=band,
            total_income_logged=round(income_factor, 2),
            total_verified_income=round(verified_factor, 2),
            verification_ratio=round(verified_factor / max(income_factor, 1), 2),
            total_records=month_num * random.randint(4, 6),
            verified_records=month_num * random.randint(3, 5),
            employer_count=min(month_num, 3),
            consistency_streak_days=random.randint(5, 25),
            active_loans=0,
            loans_repaid=0,
            loans_defaulted=0,
            fraud_flags_total=0,
            fraud_score_avg=round(random.uniform(0.02, 0.08), 3),
            snapshot_date=snapshot_date,
            period_start=snapshot_date - timedelta(days=30),
            period_end=snapshot_date,
        )
        db.add(entry)
        print(f"   📅 Month -{i}: Score {score} ({band})")

    db.commit()


def _print_summary():
    """Print login credentials and summary."""
    print("\n" + "=" * 60)
    print("  🎉 DEMO ACCOUNTS")
    print("=" * 60)
    print()
    print("  ┌─────────────────────────────────────────────────┐")
    print("  │  Workers (OTP for all: 123456)                  │")
    print("  ├─────────────────────────────────────────────────┤")
    print("  │  📱 9999900001 → रामू भाई (Construction/Delhi)  │")
    print("  │     Trust: 720 (good) | 30 income records       │")
    print("  │                                                 │")
    print("  │  📱 9999900002 → लक्ष्मी देवी (Domestic/Mumbai) │")
    print("  │     Trust: 650 (good)                           │")
    print("  │                                                 │")
    print("  │  📱 9999900003 → अर्जुन कुमार (Delivery/Blr)   │")
    print("  │     Trust: 580 (fair)                           │")
    print("  ├─────────────────────────────────────────────────┤")
    print("  │  Employer                                       │")
    print("  │  📱 9999900010 → सुरेश कंस्ट्रक्शन (Delhi)     │")
    print("  ├─────────────────────────────────────────────────┤")
    print("  │  API: http://localhost:8000/docs                │")
    print("  │  Login: POST /api/v1/auth/send-otp              │")
    print("  │         POST /api/v1/auth/verify-otp            │")
    print("  └─────────────────────────────────────────────────┘")
    print()


if __name__ == "__main__":
    seed()
