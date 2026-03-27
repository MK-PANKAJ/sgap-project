<p align="center">
  <h1 align="center">🏗️ S-GAP — Smart Gig-worker Assistance Platform</h1>
  <p align="center">
    <strong>Empowering India's 300 million unorganised workers with AI-powered financial identity</strong>
  </p>
  <p align="center">
    <em>ET Gen AI Hackathon 2025 — Track: Financial Inclusion</em>
  </p>
</p>

---

## 🎯 Problem Statement

India has **300+ million** gig and informal workers (construction labourers, domestic helpers, street vendors, delivery riders) who:

- ❌ Have **no income proof** — paid in cash, no payslips
- ❌ Are **invisible to banks** — zero credit history
- ❌ Miss **government welfare schemes** they qualify for
- ❌ Fall prey to **predatory lenders** charging 60-120% interest

**S-GAP creates India's first voice-based digital income identity for informal workers**, enabling them to access micro-loans, insurance, and government benefits — all in their own language.

---

## 🏛️ Architecture Overview

```
┌──────────────────────────────────────────────────────────────────┐
│                        S-GAP PLATFORM                           │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌─────────────┐    ┌─────────────┐    ┌──────────────────┐     │
│  │   Flutter    │    │  Streamlit  │    │   Lender Web     │     │
│  │  Mobile App  │    │   Admin     │    │   Dashboard      │     │
│  │  (Worker)    │    │  Dashboard  │    │  (Employer/NBFC) │     │
│  └──────┬───────┘    └──────┬──────┘    └───────┬──────────┘     │
│         │                   │                    │               │
│         └───────────────────┼────────────────────┘               │
│                             │                                    │
│                     ┌───────▼────────┐                           │
│                     │   FastAPI      │                           │
│                     │   Backend      │                           │
│                     │  (Port 8000)   │                           │
│                     └───────┬────────┘                           │
│                             │                                    │
│         ┌───────────────────┼───────────────────┐               │
│         │                   │                   │               │
│  ┌──────▼──────┐   ┌───────▼───────┐   ┌───────▼──────┐       │
│  │  Bhashini   │   │  ML Engine    │   │   OCEN 4.0   │       │
│  │  AI (GoI)   │   │  (sklearn)    │   │  Loan Bridge │       │
│  │             │   │               │   │              │       │
│  │ • ASR (STT) │   │ • Credit Score│   │ • MFI/NBFC   │       │
│  │ • NMT       │   │ • Fraud Det.  │   │ • EMI Calc   │       │
│  │ • TTS       │   │ • GBR + IF    │   │ • Offers     │       │
│  └─────────────┘   └───────────────┘   └──────────────┘       │
│                             │                                    │
│                     ┌───────▼────────┐                           │
│                     │   Database     │                           │
│                     │  SQLite (Dev)  │                           │
│                     │  PostgreSQL    │                           │
│                     │  (Production)  │                           │
│                     └────────────────┘                           │
└──────────────────────────────────────────────────────────────────┘
```

---

## 🛠️ Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Mobile App** | Flutter + Dart | Cross-platform worker app (Android/iOS) |
| **Backend API** | FastAPI + Python 3.11+ | REST API with async support |
| **Database** | SQLite (dev) / PostgreSQL (prod) | 13-table relational schema |
| **AI/NLP** | Bhashini (GoI ULCA Platform) | Speech-to-Text, Translation, TTS in 22 Indian languages |
| **ML Models** | scikit-learn | Credit scoring (GBR) + Fraud detection (Isolation Forest) |
| **Loans** | OCEN 4.0 Protocol | Open Credit Enablement Network — NBFC/MFI integration |
| **Auth** | JWT + bcrypt | Stateless token auth with password hashing |
| **Encryption** | AES-256 (Fernet) + SHA-256 | PII encryption + tamper-proof hashes |
| **Admin** | Streamlit | Real-time admin dashboard |
| **ORM** | SQLAlchemy | Database abstraction layer |
| **QR Codes** | qrcode + Pillow | Income certificate verification |

---

## 📁 Project Structure

```
sgap-project/
├── sgap_backend/                  # FastAPI Backend
│   ├── app/
│   │   ├── api/v1/               # API Endpoints (10 routers)
│   │   │   ├── auth.py           # OTP login, registration
│   │   │   ├── income.py         # Voice log, entries, certificates
│   │   │   ├── trust_score.py    # ML scoring + history
│   │   │   ├── loans.py          # Eligibility, apply, offers, EMI
│   │   │   ├── employers.py      # Pending confirmations
│   │   │   ├── schemes.py        # Government welfare schemes
│   │   │   ├── verification.py   # Certificate & Aadhaar verify
│   │   │   ├── admin.py          # Platform stats & fraud alerts
│   │   │   ├── workers.py        # Worker profile lookup
│   │   │   └── future_endpoints.py # 15+ planned feature stubs
│   │   ├── models/               # SQLAlchemy Models (13 tables)
│   │   │   ├── user.py           # User, WorkerProfile, EmployerProfile
│   │   │   ├── income_record.py  # IncomeRecord + verification
│   │   │   ├── trust_score.py    # TrustScoreRecord, TrustScoreHistory
│   │   │   ├── loan.py           # Lender, LoanApplication, LoanOffer, LoanRepayment
│   │   │   └── scheme.py         # GovernmentScheme, InsurancePlan, VerificationToken
│   │   ├── services/             # Business Logic
│   │   │   ├── bhashini_service.py    # Bhashini AI integration
│   │   │   ├── voice_service.py       # Voice → structured income
│   │   │   ├── ocen_service.py        # OCEN 4.0 loan offers
│   │   │   └── certificate_service.py # SHA-256 certificates + QR
│   │   ├── ml/                   # Machine Learning
│   │   │   ├── credit_scoring_model.py  # GradientBoostingRegressor
│   │   │   ├── fraud_detection_model.py # IsolationForest
│   │   │   └── train_models.py          # Training CLI
│   │   ├── utils/                # Utilities
│   │   │   ├── security.py       # JWT + encryption
│   │   │   ├── hash_utils.py     # SHA-256 hashing
│   │   │   └── helpers.py        # Phone validation, state lookup
│   │   ├── config.py             # Pydantic settings
│   │   ├── database.py           # SQLAlchemy engine
│   │   └── main.py               # FastAPI app entry point
│   ├── seed_data.py              # Demo data seeder
│   └── requirements.txt
├── sgap_admin/                    # Streamlit Admin Dashboard
│   ├── admin_dashboard.py
│   └── requirements.txt
├── sgap_flutter/                  # Flutter Mobile App
│   └── ...
└── README.md                      # ← You are here
```

---

## 🚀 Quick Start

### Prerequisites

- Python 3.11+
- pip
- Git

### Backend Setup

```bash
# Clone
git clone https://github.com/MK-PANKAJ/sgap-project.git
cd sgap-project/sgap_backend

# Install dependencies
pip install -r requirements.txt

# Train ML models
python -m app.ml.train_models

# Seed demo data
python seed_data.py

# Start server
python -m uvicorn app.main:app --reload --port 8000
```

The API is now live at **http://localhost:8000/docs** (Swagger UI).

### Admin Dashboard

```bash
cd sgap_admin
pip install -r requirements.txt
streamlit run admin_dashboard.py
```

Dashboard opens at **http://localhost:8501**.

### Flutter App

```bash
cd sgap_flutter
flutter pub get
flutter run
```

---

## 🔑 Demo Credentials

All accounts use OTP **`123456`** in demo mode.

| Phone | Name | Role | Trust Score | City |
|-------|------|------|-------------|------|
| `9999900001` | रामू भाई | Worker | 720 (good) | Delhi |
| `9999900002` | लक्ष्मी देवी | Worker | 650 (good) | Mumbai |
| `9999900003` | अर्जुन कुमार | Worker | 580 (fair) | Bangalore |
| `9999900010` | सुरेश कंस्ट्रक्शन | Employer | — | Delhi |

### Quick Login Flow

```bash
# Step 1: Send OTP
curl -X POST http://localhost:8000/api/v1/auth/send-otp \
  -H "Content-Type: application/json" \
  -d '{"phone": "9999900001"}'

# Step 2: Verify OTP → get JWT token
curl -X POST http://localhost:8000/api/v1/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{"phone": "9999900001", "otp": "123456"}'
```

Use the returned `token` in all subsequent requests:
```
Authorization: Bearer <token>
```

---

## 📡 API Documentation

### Auth (`/api/v1/auth`)

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/send-otp` | Send OTP to phone number |
| `POST` | `/verify-otp` | Verify OTP → returns JWT token |
| `POST` | `/register/worker` | Register worker profile (auth required) |
| `POST` | `/register/employer` | Register employer profile (auth required) |
| `GET` | `/me` | Get current user profile |

### Income (`/api/v1/income`)

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/voice-log` | Send audio → Bhashini STT → parsed income |
| `POST` | `/confirm-entry` | Confirm parsed entry (runs fraud detection) |
| `GET` | `/worker/{id}` | Paginated income records (filters: month, year, status) |
| `GET` | `/monthly-summary/{id}` | Monthly totals + weekly breakdown |
| `GET` | `/certificate/{id}` | Generate income certificate with QR code |

### Trust Score (`/api/v1/trust-score`)

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/{worker_id}` | Calculate ML-powered trust score |
| `GET` | `/{worker_id}/history` | Last 6 months score history |

### Loans (`/api/v1/loans`)

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/check-eligibility/{id}` | Score-based eligibility + max amount |
| `POST` | `/apply` | Submit loan application → generates OCEN offers |
| `POST` | `/accept/{offer_id}` | Accept offer → generates EMI schedule |
| `GET` | `/active/{worker_id}` | Active loans with repayment status |

### Employers (`/api/v1/employers`)

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/pending/{employer_id}` | Income records awaiting confirmation |
| `POST` | `/confirm/{record_id}` | Confirm or dispute a record |

### Schemes (`/api/v1/schemes`)

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/all` | All government schemes (optional category filter) |
| `GET` | `/recommended/{worker_id}` | AI-matched scheme recommendations |
| `GET` | `/insurance/plans` | All micro-insurance plans |

### Verification (`/api/v1/verification`)

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/certificate/{hash}` | Verify certificate by SHA-256 hash |
| `POST` | `/aadhaar-sandbox` | Simulated Aadhaar eKYC |

### Admin (`/api/v1/admin`)

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/stats` | Platform overview (users, income, loans) |
| `GET` | `/fraud-alerts` | Flagged records sorted by fraud score |
| `GET` | `/workers` | Paginated worker list with city filter |

### Workers (`/api/v1/workers`)

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/{worker_id}` | Worker profile by ID |

### Future (`/api/v1/future`) — 15+ Planned Endpoints

| Method | Endpoint | Phase |
|--------|----------|-------|
| `POST` | `/whatsapp/send-message` | 2 |
| `POST` | `/aadhaar/real-ekyc` | 2 |
| `POST` | `/account-aggregator/link` | 2 |
| `POST` | `/worker-circles/create` | 2 |
| `POST` | `/savings/auto-save` | 2 |
| `POST` | `/micro-sip/start` | 4 |
| `POST` | `/ussd/session` | 3 |
| `GET` | `/blockchain/certificate/{hash}` | 3 |
| `POST` | `/upi/collect` | 3 |
| `POST` | `/digilocker/link` | 3 |
| `POST` | `/ivr/call` | 3 |
| `POST` | `/ambassador/register` | 4 |
| `POST` | `/insurance/claim` | 4 |
| `POST` | `/credit-card/apply` | 4 |
| `POST` | `/remittance/send` | 4 |
| `GET` | `/govt-dashboard/analytics` | 4 |
| `GET` | `/roadmap` | — |

---

## 🤖 Machine Learning Models

### Credit Scoring Model

| Property | Value |
|----------|-------|
| **Algorithm** | Gradient Boosting Regressor (scikit-learn) |
| **Output** | Trust Score 300–1000 |
| **Training Data** | 2,000 synthetic samples |
| **Train R²** | 0.97 |
| **Test R²** | 0.89 |

**10 Input Features:**

| Feature | Description |
|---------|-------------|
| `income_consistency` | Fraction of active days with entries |
| `avg_monthly_income` | Average monthly earnings (₹) |
| `income_variance` | Standard deviation / mean ratio |
| `verification_rate` | % of employer-confirmed records |
| `employer_diversity` | Number of unique employers |
| `platform_tenure_days` | Days since registration |
| `total_entries` | Total income records logged |
| `avg_daily_income` | Average daily earnings (₹) |
| `dispute_rate` | % of flagged/disputed records |
| `repayment_ratio` | Loan repayment track record |

**Score Bands:**

| Band | Range | Hindi | Action |
|------|-------|-------|--------|
| Building | 300–500 | बन रहा है | Keep logging daily |
| Fair | 501–650 | ठीक है | Eligible for basic loans |
| Good | 651–800 | अच्छा है | Better rates, higher limits |
| Excellent | 801–1000 | बहुत अच्छा ⭐ | Best rates, credit cards |

### Fraud Detection Model

| Property | Value |
|----------|-------|
| **Algorithm** | Isolation Forest (unsupervised) |
| **Contamination** | 5% |
| **Combined** | ML anomaly score + 6 rule-based flags |

**7 Input Features:**

| Feature | Description |
|---------|-------------|
| `amount` | Entry amount (₹) |
| `entries_per_day` | Number of entries same day |
| `hour_of_entry` | Time of day (0–23) |
| `location_distance_km` | GPS distance from usual location |
| `employer_ratio` | Single-employer concentration |
| `amount_uniqueness` | How unique is the amount |
| `entry_gap_hours` | Hours since last entry |

**Rule-Based Flags:**

| Flag | Trigger |
|------|---------|
| `unusually_high_amount` | Amount > ₹25,000 |
| `rapid_successive_entries` | > 5 entries/day |
| `unusual_time` | Entry between midnight and 5 AM |
| `excessive_entries` | > 3 entries/day |
| `gps_location_anomaly` | > 100 km from usual location |
| `round_number_pattern` | Suspiciously round amounts |

---

## 🔐 Security Architecture

```
┌─────────────────────────────────────────────────────┐
│                  SECURITY LAYERS                     │
├─────────────────────────────────────────────────────┤
│                                                      │
│  🔑 Authentication                                   │
│  ├─ Phone OTP (6-digit, 10-min expiry)              │
│  ├─ JWT Tokens (HS256, 72-hour expiry)              │
│  └─ Role-based access (worker/employer/admin)        │
│                                                      │
│  🔒 Data Encryption                                  │
│  ├─ AES-256 (Fernet) for PII (Aadhaar numbers)     │
│  ├─ bcrypt for phone number hashing                  │
│  └─ SHA-256 for income record integrity              │
│                                                      │
│  🛡️ Fraud Prevention                                 │
│  ├─ Isolation Forest ML model                        │
│  ├─ 6 rule-based fraud flags                         │
│  ├─ GPS location verification                        │
│  └─ Voice-amount cross-validation                    │
│                                                      │
│  📜 Tamper Proofing                                   │
│  ├─ SHA-256 hash per income record                   │
│  ├─ SHA-256 hash per certificate                     │
│  └─ QR code for instant verification                 │
│                                                      │
└─────────────────────────────────────────────────────┘
```

---

## 🗺️ 4-Phase Feature Roadmap

### Phase 1: Foundation ✅ (Built)
- OTP Authentication
- Voice Income Logging (Bhashini AI — 22 languages)
- Trust Score Engine (ML-powered, 300–1000)
- Fraud Detection (Isolation Forest + rules)
- Micro-Loans via OCEN 4.0
- Income Certificates (SHA-256 + QR)
- Government Scheme Matching
- Lender Dashboard

### Phase 2: Growth 🔄 (Q3 2025)
- WhatsApp Bot Integration
- Real Aadhaar eKYC (licensed ASA)
- Account Aggregator Framework
- Worker Savings Circles
- Auto-Save from Daily Income

### Phase 3: Scale 📋 (Q4 2025)
- USSD Access (feature phones)
- Blockchain-backed Certificates
- UPI Auto-debit for EMI
- DigiLocker Integration
- IVR-based Income Logging

### Phase 4: Ecosystem 📋 (Q1 2026)
- Micro-SIP Investments (₹10/day)
- Community Ambassador Network
- Insurance Claims Processing
- Trust Score-based Credit Cards
- Low-cost Remittances
- Government Analytics Dashboard

---

## 🏛️ Government Schemes Integrated

| Scheme | Benefit | For |
|--------|---------|-----|
| **PM Suraksha Bima Yojana** | ₹2 lakh accident cover @ ₹12/year | All workers 18-70 |
| **PM Jeevan Jyoti Bima Yojana** | ₹2 lakh life cover @ ₹436/year | All workers 18-50 |
| **Ayushman Bharat (PMJAY)** | ₹5 lakh health cover/family | BPL families |
| **e-Shram Card** | Worker ID + ₹2 lakh insurance | Unorganised workers |
| **PM Mudra Yojana** | Collateral-free loans up to ₹10 lakh | Micro entrepreneurs |
| **PM Vishwakarma Yojana** | Training + ₹3 lakh loan @ 5% | Traditional artisans |

---

## 🎯 Impact Metrics

| Metric | Target |
|--------|--------|
| Workers onboarded | 50 Lakh+ |
| Income digitised | ₹500 Crore+ |
| Micro-loans enabled | ₹100 Crore+ |
| Languages supported | 22 (all scheduled) |
| Average interest rate reduction | 40-60% |
| Scheme enrollment increase | 3x |

---

## 👥 Team

**Team S-GAP** — ET Gen AI Hackathon 2025

---

## 📄 License

This project is built for the ET Gen AI Hackathon 2025. All rights reserved.
