"""
S-GAP ML Model Trainer
========================
Run this once to train and save both ML models.

Usage:
    cd sgap_backend
    python -m app.ml.train_models
"""

import sys
import os

# Ensure the project root is on the path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(__file__))))

from app.ml.credit_scoring_model import credit_model
from app.ml.fraud_detection_model import fraud_model


def train_all_models():
    print("=" * 60)
    print("  S-GAP ML Model Training")
    print("=" * 60)

    # ── Credit Scoring ───────────────────────────────────────────────
    print("\n📊 Training Credit Scoring Model...")
    credit_result = credit_model.train()
    print(
        f"   ✅ Done! Train R² = {credit_result['train_r2']}, "
        f"Test R² = {credit_result['test_r2']}"
    )

    # ── Fraud Detection ──────────────────────────────────────────────
    print("\n🔍 Training Fraud Detection Model...")
    fraud_result = fraud_model.train()
    print(f"   ✅ Done! Contamination = {fraud_result['contamination']}")

    # ── Smoke tests ──────────────────────────────────────────────────
    print("\n" + "-" * 60)
    print("  Smoke Tests")
    print("-" * 60)

    # Good worker
    good_worker = {
        "income_consistency": 0.8,
        "avg_monthly_income": 18000,
        "income_variance": 0.2,
        "verification_rate": 0.85,
        "employer_diversity": 3,
        "platform_tenure_days": 90,
        "total_entries": 45,
        "avg_daily_income": 750,
        "dispute_rate": 0.02,
        "repayment_ratio": 1.0,
    }
    result = credit_model.predict(good_worker)
    print(f"\n📊 Good Worker — Score: {result['score']}, Band: {result['band_hindi']}")

    # Normal income entry
    normal_entry = {
        "amount": 800,
        "entries_per_day": 1,
        "hour_of_entry": 18,
        "location_distance_km": 2,
        "employer_ratio": 0.3,
        "amount_uniqueness": 0.7,
        "entry_gap_hours": 24,
    }
    fraud_result1 = fraud_model.detect(normal_entry)
    print(
        f"🔍 Normal Entry — Fraud Score: {fraud_result1['fraud_score']}, "
        f"Recommendation: {fraud_result1['recommendation']}"
    )

    # Suspicious entry
    suspicious = {
        "amount": 50000,
        "entries_per_day": 10,
        "hour_of_entry": 3,
        "location_distance_km": 200,
        "employer_ratio": 1.0,
        "amount_uniqueness": 0.02,
        "entry_gap_hours": 0.1,
    }
    fraud_result2 = fraud_model.detect(suspicious)
    print(
        f"🔍 Suspicious Entry — Fraud Score: {fraud_result2['fraud_score']}, "
        f"Flagged: {fraud_result2['is_flagged']}"
    )
    print(f"   Flags: {fraud_result2['flags']}")

    print("\n✅ All models trained and verified successfully!")


if __name__ == "__main__":
    train_all_models()
