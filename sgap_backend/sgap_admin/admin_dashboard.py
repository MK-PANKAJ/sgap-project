"""
S-GAP Admin Dashboard
======================
Streamlit-powered admin panel for the S-GAP platform.
Connects to the FastAPI backend at http://localhost:8000/api/v1

Pages:
  1. Overview   — Platform stats
  2. Workers    — Worker management
  3. Income     — Income record explorer
  4. Loans      — Loan applications & offers
  5. Fraud      — Fraud alerts
  6. Roadmap    — Feature roadmap

Run:
    cd sgap_admin
    pip install -r requirements.txt
    streamlit run admin_dashboard.py
"""

import streamlit as st
import requests
import pandas as pd
from datetime import datetime

# ── Configuration ────────────────────────────────────────────────────

API_BASE = "http://localhost:8000/api/v1"
DEMO_TOKEN = None  # Will be set after login


def get_headers():
    """Return auth headers for API calls."""
    if st.session_state.get("token"):
        return {"Authorization": f"Bearer {st.session_state.token}"}
    return {}


def api_get(endpoint, params=None):
    """Make a GET request to the backend API."""
    try:
        r = requests.get(
            f"{API_BASE}{endpoint}",
            headers=get_headers(),
            params=params,
            timeout=10,
        )
        if r.status_code == 200:
            return r.json()
        else:
            st.error(f"API Error {r.status_code}: {r.text[:200]}")
            return None
    except requests.exceptions.ConnectionError:
        st.error("⚠️ Cannot connect to backend. Is the server running on port 8000?")
        return None
    except Exception as e:
        st.error(f"Error: {e}")
        return None


def api_post(endpoint, data=None):
    """Make a POST request to the backend API."""
    try:
        r = requests.post(
            f"{API_BASE}{endpoint}",
            headers=get_headers(),
            json=data,
            timeout=10,
        )
        if r.status_code == 200:
            return r.json()
        else:
            st.error(f"API Error {r.status_code}: {r.text[:200]}")
            return None
    except requests.exceptions.ConnectionError:
        st.error("⚠️ Cannot connect to backend.")
        return None
    except Exception as e:
        st.error(f"Error: {e}")
        return None


# ── Auto-Login ───────────────────────────────────────────────────────


def auto_login():
    """Login with demo admin credentials."""
    if st.session_state.get("token"):
        return True

    # Send OTP
    api_post("/auth/send-otp", {"phone": "9999900001"})
    # Verify with demo OTP
    result = api_post("/auth/verify-otp", {"phone": "9999900001", "otp": "123456"})
    if result and "token" in result:
        st.session_state.token = result["token"]
        st.session_state.user = result.get("user", {})
        return True
    return False


# ═══════════════════════════════════════════════════════════════════════
# PAGE 1: Overview
# ═══════════════════════════════════════════════════════════════════════


def page_overview():
    st.title("📊 Platform Overview")
    st.caption("Real-time metrics from the S-GAP platform")

    data = api_get("/admin/stats")
    if not data:
        st.warning("Could not load stats. Showing placeholder data.")
        data = {
            "users": {"total": 0, "workers": 0, "employers": 0},
            "income": {"total_records": 0, "total_logged": 0, "total_verified": 0, "verification_rate": 0},
            "loans": {"total_applications": 0, "active_loans": 0, "total_disbursed": 0},
            "fraud": {"flagged_records": 0},
        }

    users = data.get("users", {})
    income = data.get("income", {})
    loans = data.get("loans", {})
    fraud = data.get("fraud", {})

    # ── Top metric cards ─────────────────────────────────────────────
    st.markdown("### 👥 Users")
    c1, c2, c3, c4 = st.columns(4)
    c1.metric("Total Users", users.get("total", 0))
    c2.metric("Workers", users.get("workers", 0))
    c3.metric("Employers", users.get("employers", 0))
    c4.metric("Lenders", 5)

    st.divider()

    st.markdown("### 💰 Income")
    c1, c2, c3, c4 = st.columns(4)
    c1.metric("Total Records", income.get("total_records", 0))
    c2.metric("Total Logged", f"₹{income.get('total_logged', 0):,.0f}")
    c3.metric("Verified", f"₹{income.get('total_verified', 0):,.0f}")
    c4.metric("Verification Rate", f"{income.get('verification_rate', 0)}%")

    st.divider()

    st.markdown("### 🏦 Loans")
    c1, c2, c3 = st.columns(3)
    c1.metric("Applications", loans.get("total_applications", 0))
    c2.metric("Active Loans", loans.get("active_loans", 0))
    c3.metric("Disbursed", f"₹{loans.get('total_disbursed', 0):,.0f}")

    st.divider()

    st.markdown("### 🛡️ Fraud Detection")
    c1, c2 = st.columns(2)
    c1.metric("Flagged Records", fraud.get("flagged_records", 0))
    c2.metric("Fraud Rate", f"{fraud.get('flagged_records', 0) / max(income.get('total_records', 1), 1) * 100:.1f}%")

    # ── Worker trust score distribution ──────────────────────────────
    st.divider()
    st.markdown("### 📈 Trust Score Distribution")

    workers_data = api_get("/admin/workers", {"limit": 100})
    if workers_data and workers_data.get("workers"):
        workers_list = workers_data["workers"]
        scores = [w.get("trust_score", 0) for w in workers_list]
        bands = {}
        for s in scores:
            if s >= 800:
                bands["⭐ Excellent (800+)"] = bands.get("⭐ Excellent (800+)", 0) + 1
            elif s >= 650:
                bands["✅ Good (650-799)"] = bands.get("✅ Good (650-799)", 0) + 1
            elif s >= 500:
                bands["🔶 Fair (500-649)"] = bands.get("🔶 Fair (500-649)", 0) + 1
            else:
                bands["🔴 Building (<500)"] = bands.get("🔴 Building (<500)", 0) + 1

        df_bands = pd.DataFrame(list(bands.items()), columns=["Band", "Count"])
        st.bar_chart(df_bands.set_index("Band"))


# ═══════════════════════════════════════════════════════════════════════
# PAGE 2: Workers
# ═══════════════════════════════════════════════════════════════════════


def page_workers():
    st.title("👷 Workers")
    st.caption("Manage registered workers on the platform")

    # Filters
    col1, col2, col3 = st.columns(3)
    with col1:
        city_filter = st.text_input("🏙️ Filter by City", "")
    with col2:
        page_num = st.number_input("Page", min_value=1, value=1, step=1)
    with col3:
        limit = st.selectbox("Per Page", [10, 20, 50], index=1)

    params = {"page": page_num, "limit": limit}
    if city_filter:
        params["city"] = city_filter

    data = api_get("/admin/workers", params)

    if data and data.get("workers"):
        st.info(f"Total: **{data['total']}** workers | Page {data['page']}")

        rows = []
        for w in data["workers"]:
            trust_badge = {
                "excellent": "⭐",
                "good": "✅",
                "fair": "🔶",
                "building": "🔴",
            }.get(w.get("trust_band", ""), "")

            rows.append({
                "Name": w.get("name", ""),
                "City": w.get("city", ""),
                "Work Type": w.get("work_type", ""),
                "Trust Score": w.get("trust_score", 0),
                "Band": f"{trust_badge} {w.get('trust_band', '')}",
                "Income Logged": f"₹{w.get('total_income_logged', 0):,.0f}",
                "Verified Income": f"₹{w.get('total_verified_income', 0):,.0f}",
                "Employers": w.get("employer_count", 0),
                "Aadhaar": "✅" if w.get("is_aadhaar_verified") else "❌",
            })

        df = pd.DataFrame(rows)
        st.dataframe(df, use_container_width=True, hide_index=True)
    else:
        st.warning("No workers found. Run `python seed_data.py` first.")


# ═══════════════════════════════════════════════════════════════════════
# PAGE 3: Income Records
# ═══════════════════════════════════════════════════════════════════════


def page_income():
    st.title("📝 Income Records")
    st.caption("Browse and filter worker income entries")

    # Get workers first for the dropdown
    workers_data = api_get("/admin/workers", {"limit": 100})
    worker_options = {}
    if workers_data and workers_data.get("workers"):
        for w in workers_data["workers"]:
            worker_options[f"{w['name']} ({w['city']})"] = w["id"]

    if not worker_options:
        st.warning("No workers found.")
        return

    # Filters
    col1, col2, col3 = st.columns(3)
    with col1:
        selected_worker = st.selectbox("👷 Worker", list(worker_options.keys()))
    with col2:
        status_filter = st.selectbox(
            "📋 Status",
            ["all", "pending", "employer_confirmed", "self_declared", "flagged"],
        )
    with col3:
        page_num = st.number_input("Page", min_value=1, value=1, step=1, key="income_page")

    worker_id = worker_options[selected_worker]
    params = {"page": page_num, "limit": 20}
    if status_filter != "all":
        params["status"] = status_filter

    data = api_get(f"/income/worker/{worker_id}", params)

    if data and data.get("records"):
        st.info(f"Total: **{data['total']}** records | Page {data['page']}")

        rows = []
        for r in data["records"]:
            status_icon = {
                "employer_confirmed": "✅",
                "pending": "⏳",
                "self_declared": "📝",
                "flagged": "🚩",
                "employer_denied": "❌",
            }.get(r.get("verification_status", ""), "")

            rows.append({
                "Date": r.get("work_date", ""),
                "Amount": f"₹{r.get('amount', 0):,.0f}",
                "Work Type": r.get("work_type", ""),
                "Employer": r.get("employer_name", ""),
                "Status": f"{status_icon} {r.get('verification_status', '')}",
                "Fraud Score": r.get("fraud_score", 0),
                "Hash": r.get("record_hash", "")[:12] + "..." if r.get("record_hash") else "",
            })

        df = pd.DataFrame(rows)
        st.dataframe(df, use_container_width=True, hide_index=True)

        # Monthly summary
        st.divider()
        st.markdown("### 📊 Monthly Summary")
        summary = api_get(f"/income/monthly-summary/{worker_id}")
        if summary:
            c1, c2, c3, c4 = st.columns(4)
            c1.metric("Total Income", f"₹{summary.get('total_income', 0):,.0f}")
            c2.metric("Verified", f"₹{summary.get('verified_income', 0):,.0f}")
            c3.metric("Pending", f"₹{summary.get('pending_income', 0):,.0f}")
            c4.metric("Disputed", f"₹{summary.get('disputed_income', 0):,.0f}")
    else:
        st.info("No income records found for this worker.")


# ═══════════════════════════════════════════════════════════════════════
# PAGE 4: Loans
# ═══════════════════════════════════════════════════════════════════════


def page_loans():
    st.title("🏦 Loans")
    st.caption("Loan applications, offers, and repayment tracking")

    # Get workers for dropdown
    workers_data = api_get("/admin/workers", {"limit": 100})
    worker_options = {}
    if workers_data and workers_data.get("workers"):
        for w in workers_data["workers"]:
            worker_options[f"{w['name']} (Score: {w['trust_score']})"] = w["id"]

    if not worker_options:
        st.warning("No workers found.")
        return

    selected_worker = st.selectbox("👷 Worker", list(worker_options.keys()))
    worker_id = worker_options[selected_worker]

    # Eligibility check
    st.markdown("### ✅ Loan Eligibility")
    eligibility = api_get(f"/loans/check-eligibility/{worker_id}")
    if eligibility:
        col1, col2, col3 = st.columns(3)
        col1.metric("Eligible", "Yes ✅" if eligibility.get("is_eligible") else "No ❌")
        col2.metric("Max Amount", f"₹{eligibility.get('max_loan_amount', 0):,.0f}")
        col3.metric("Trust Score", eligibility.get("trust_score", 0))

        if eligibility.get("reasons"):
            for reason in eligibility["reasons"]:
                st.caption(f"ℹ️ {reason}")

        st.info(eligibility.get("eligible_message_hindi", ""))

    # Active loans
    st.divider()
    st.markdown("### 📋 Active Loans")
    active = api_get(f"/loans/active/{worker_id}")
    if active and active.get("active_loans"):
        for loan in active["active_loans"]:
            with st.expander(f"Loan ₹{loan.get('amount_disbursed', 0):,.0f} — {loan.get('status', '')}"):
                c1, c2, c3 = st.columns(3)
                c1.metric("EMI", f"₹{loan.get('emi_amount', 0):,.0f}")
                c2.metric("Rate", f"{loan.get('interest_rate', 0)}%")
                c3.metric("EMIs Paid", f"{loan.get('emis_paid', 0)}/{loan.get('emis_total', 0)}")

                if loan.get("next_emi"):
                    st.caption(f"📅 Next EMI: ₹{loan['next_emi']['amount']:,.0f} due {loan['next_emi']['due_date']}")
    else:
        st.info("No active loans for this worker.")

    # Quick apply
    st.divider()
    st.markdown("### 🆕 Quick Loan Application (Demo)")
    with st.form("loan_form"):
        amount = st.number_input("Amount (₹)", min_value=1000, max_value=100000, value=10000, step=1000)
        purpose = st.selectbox("Purpose", ["emergency", "medical", "education", "business", "housing"])
        tenure = st.selectbox("Tenure (months)", [3, 6, 9, 12], index=1)
        submitted = st.form_submit_button("Apply for Loan")

        if submitted:
            result = api_post("/loans/apply", {
                "worker_id": worker_id,
                "amount_requested": amount,
                "purpose": purpose,
                "tenure_months": tenure,
            })
            if result:
                st.success(result.get("message_hindi", "Loan applied!"))
                if result.get("offers"):
                    st.markdown("#### 📋 Offers Received:")
                    for o in result["offers"]:
                        best = " ⭐ BEST" if o.get("is_best") else ""
                        st.markdown(
                            f"- **{o['lender_name']}**: ₹{o['amount_offered']:,.0f} @ "
                            f"{o['interest_rate']}% — EMI ₹{o['emi_amount']:,.0f}/mo{best}"
                        )


# ═══════════════════════════════════════════════════════════════════════
# PAGE 5: Fraud Alerts
# ═══════════════════════════════════════════════════════════════════════


def page_fraud():
    st.title("🚨 Fraud Alerts")
    st.caption("Income records flagged by the Isolation Forest ML model")

    data = api_get("/admin/fraud-alerts", {"limit": 50})

    if data and data.get("alerts"):
        st.error(f"⚠️ **{data['total_alerts']}** suspicious records detected")

        rows = []
        for a in data["alerts"]:
            score = a.get("fraud_score", 0)
            severity = "🔴 High" if score > 0.7 else "🟠 Medium" if score > 0.5 else "🟡 Low"

            rows.append({
                "Worker ID": a.get("worker_id", "")[:8] + "...",
                "Amount": f"₹{a.get('amount', 0):,.0f}",
                "Date": a.get("work_date", ""),
                "Fraud Score": round(score, 3),
                "Severity": severity,
                "Flags": ", ".join(a.get("fraud_flags", [])),
                "Status": a.get("verification_status", ""),
            })

        df = pd.DataFrame(rows)
        st.dataframe(df, use_container_width=True, hide_index=True)

        # Fraud score distribution
        st.divider()
        st.markdown("### 📊 Fraud Score Distribution")
        scores = [a.get("fraud_score", 0) for a in data["alerts"]]
        if scores:
            chart_data = pd.DataFrame({"Fraud Score": scores})
            st.bar_chart(chart_data)
    else:
        st.success("✅ No fraud alerts detected! All records look clean.")


# ═══════════════════════════════════════════════════════════════════════
# PAGE 6: Roadmap
# ═══════════════════════════════════════════════════════════════════════


def page_roadmap():
    st.title("🗺️ Feature Roadmap")
    st.caption("S-GAP platform development phases")

    phases = [
        {
            "phase": 1,
            "name": "Foundation",
            "status": "✅ Completed",
            "timeline": "Built",
            "color": "green",
            "features": [
                ("📱 OTP Authentication", "Phone-based passwordless login"),
                ("🎤 Voice Income Logging", "Bhashini AI STT in Hindi + 22 languages"),
                ("📊 Trust Score", "ML-powered credit scoring (300-1000)"),
                ("🔍 Fraud Detection", "Isolation Forest anomaly detection"),
                ("🏦 Micro-Loans", "OCEN 4.0 integration with NBFC/MFI offers"),
                ("📜 Income Certificates", "SHA-256 tamper-proof with QR codes"),
                ("🏛️ Government Schemes", "Auto-matching workers to 6+ schemes"),
                ("🛡️ Security Layer", "JWT + AES-256 + bcrypt"),
            ],
        },
        {
            "phase": 2,
            "name": "Growth",
            "status": "🔄 In Progress",
            "timeline": "Q3 2025",
            "features": [
                ("💬 WhatsApp Bot", "Send income summaries & alerts via WhatsApp"),
                ("🆔 Real Aadhaar eKYC", "UIDAI-licensed ASA integration"),
                ("🏦 Account Aggregator", "Bank statement fetch for income proof"),
                ("👥 Worker Circles", "Peer savings groups among workers"),
                ("💰 Auto-Save", "Auto-deduct savings from daily income"),
            ],
        },
        {
            "phase": 3,
            "name": "Scale",
            "status": "📋 Planned",
            "timeline": "Q4 2025",
            "features": [
                ("📟 USSD Access", "Feature phone access via *123# menu"),
                ("⛓️ Blockchain Certificates", "Immutable income proof on-chain"),
                ("💸 UPI Collect", "Auto-debit EMI via UPI mandate"),
                ("📂 DigiLocker Integration", "Government document verification"),
                ("📞 IVR System", "Phone call-based income logging"),
            ],
        },
        {
            "phase": 4,
            "name": "Ecosystem",
            "status": "📋 Planned",
            "timeline": "Q1 2026",
            "features": [
                ("📈 Micro-SIP Investments", "Start SIP from ₹10/day"),
                ("🤝 Ambassador Network", "Community onboarding agents"),
                ("🏥 Insurance Claims", "One-tap claim filing"),
                ("💳 Credit Cards", "Trust score-based credit cards"),
                ("💸 Remittances", "Low-cost money transfer across India"),
                ("📊 Govt Dashboard", "Analytics for policymakers"),
            ],
        },
    ]

    for p in phases:
        st.markdown(f"---")
        st.markdown(f"### Phase {p['phase']}: {p['name']}  {p['status']}")
        st.caption(f"Timeline: {p['timeline']}")

        for feat_name, feat_desc in p["features"]:
            st.markdown(f"- **{feat_name}** — {feat_desc}")

    st.divider()
    st.markdown("### 🎯 Impact Targets")
    c1, c2, c3, c4 = st.columns(4)
    c1.metric("Workers Targeted", "50 Lakh+")
    c2.metric("Income Digitised", "₹500 Cr+")
    c3.metric("Loans Enabled", "₹100 Cr+")
    c4.metric("Languages", "22+")


# ═══════════════════════════════════════════════════════════════════════
# Main App
# ═══════════════════════════════════════════════════════════════════════


def main():
    st.set_page_config(
        page_title="S-GAP Admin Dashboard",
        page_icon="📊",
        layout="wide",
        initial_sidebar_state="expanded",
    )

    # Sidebar
    with st.sidebar:
        st.image("https://img.icons8.com/color/96/administrative-tools.png", width=60)
        st.title("S-GAP Admin")
        st.caption("Smart Gig-worker Assistance Platform")
        st.divider()

        page = st.radio(
            "Navigation",
            [
                "📊 Overview",
                "👷 Workers",
                "📝 Income Records",
                "🏦 Loans",
                "🚨 Fraud Alerts",
                "🗺️ Roadmap",
            ],
            label_visibility="collapsed",
        )

        st.divider()

        # Login status
        if st.session_state.get("token"):
            st.success("🔓 Connected to API")
        else:
            st.warning("🔒 Not connected")
            if st.button("🔑 Connect to Backend"):
                if auto_login():
                    st.success("Connected!")
                    st.rerun()
                else:
                    st.error("Failed to connect")

        st.divider()
        st.caption(f"Backend: {API_BASE}")
        st.caption(f"Time: {datetime.now().strftime('%H:%M:%S')}")

    # Auto-login on first load
    if not st.session_state.get("token"):
        auto_login()

    # Route to page
    if page == "📊 Overview":
        page_overview()
    elif page == "👷 Workers":
        page_workers()
    elif page == "📝 Income Records":
        page_income()
    elif page == "🏦 Loans":
        page_loans()
    elif page == "🚨 Fraud Alerts":
        page_fraud()
    elif page == "🗺️ Roadmap":
        page_roadmap()


if __name__ == "__main__":
    main()
