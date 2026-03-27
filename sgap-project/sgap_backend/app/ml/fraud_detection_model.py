"""
S-GAP Fraud Detection Model
=============================
Algorithm: Isolation Forest (unsupervised anomaly detection)

Features (7):
  amount, entries_per_day, hour_of_entry, location_distance_km,
  employer_ratio, amount_uniqueness, entry_gap_hours

Output:
  fraud_score  : 0.0 (clean) → 1.0 (highly suspicious)
  is_flagged   : boolean
  flags        : list of triggered rule names
  recommendation: approve | review | reject
"""

import numpy as np
import pandas as pd
from sklearn.ensemble import IsolationForest
from sklearn.preprocessing import StandardScaler
import joblib
import os
import logging

logger = logging.getLogger(__name__)

MODELS_DIR = os.path.join(os.path.dirname(__file__), "models")


class FraudDetectionModel:
    """
    Isolation Forest anomaly detector.

    Combines the statistical model score with deterministic rule-based flags
    (high amount, GPS mismatch, rapid entries, etc.) for robust detection.
    """

    FEATURE_NAMES = [
        "amount",
        "entries_per_day",
        "hour_of_entry",
        "location_distance_km",
        "employer_ratio",
        "amount_uniqueness",
        "entry_gap_hours",
    ]

    def __init__(self):
        self.model = None
        self.scaler = StandardScaler()
        self.model_path = os.path.join(MODELS_DIR, "fraud_model.pkl")
        self.version = "1.0.0"
        self.is_trained = False

    # ── Synthetic data generation ────────────────────────────────────

    def _generate_synthetic_data(self, n_samples: int = 3000) -> pd.DataFrame:
        """
        Generate a mix of 95% normal + 5% anomalous entries.
        Anomalies have exaggerated amounts, locations, and timing.
        """
        np.random.seed(42)
        n_normal = int(n_samples * 0.95)
        n_anomaly = n_samples - n_normal

        normal = pd.DataFrame({
            "amount": np.clip(
                np.random.lognormal(6.5, 0.5, n_normal), 100, 5000
            ),
            "entries_per_day": np.clip(
                np.random.poisson(1.5, n_normal), 0, 5
            ),
            "hour_of_entry": np.clip(
                np.random.normal(18, 3, n_normal), 6, 23
            ),
            "location_distance_km": np.clip(
                np.random.exponential(2, n_normal), 0, 30
            ),
            "employer_ratio": np.random.beta(2, 5, n_normal),
            "amount_uniqueness": np.random.uniform(0.3, 1, n_normal),
            "entry_gap_hours": np.clip(
                np.random.lognormal(3, 0.5, n_normal), 1, 72
            ),
        })

        anomaly = pd.DataFrame({
            "amount": np.clip(
                np.random.lognormal(9, 1, n_anomaly), 5000, 500000
            ),
            "entries_per_day": np.random.poisson(8, n_anomaly),
            "hour_of_entry": np.random.uniform(0, 24, n_anomaly),
            "location_distance_km": np.random.uniform(50, 500, n_anomaly),
            "employer_ratio": np.random.uniform(0.9, 1, n_anomaly),
            "amount_uniqueness": np.random.uniform(0, 0.1, n_anomaly),
            "entry_gap_hours": np.random.uniform(0, 0.5, n_anomaly),
        })

        return pd.concat([normal, anomaly], ignore_index=True)

    # ── Training ─────────────────────────────────────────────────────

    def train(self) -> dict:
        """Train Isolation Forest on synthetic data and persist."""
        df = self._generate_synthetic_data(3000)
        X_scaled = self.scaler.fit_transform(df[self.FEATURE_NAMES].values)

        self.model = IsolationForest(
            n_estimators=100,
            contamination=0.05,
            random_state=42,
            n_jobs=-1,
        )
        self.model.fit(X_scaled)

        # Save model + scaler together
        os.makedirs(MODELS_DIR, exist_ok=True)
        joblib.dump({"model": self.model, "scaler": self.scaler}, self.model_path)
        self.is_trained = True

        logger.info("Fraud model trained — contamination=0.05, n_samples=3000")
        return {
            "model": "IsolationForest",
            "contamination": 0.05,
            "n_samples": 3000,
        }

    # ── Loading ──────────────────────────────────────────────────────

    def load(self) -> bool:
        """Load a previously trained model from disk."""
        try:
            if os.path.exists(self.model_path):
                data = joblib.load(self.model_path)
                self.model = data["model"]
                self.scaler = data["scaler"]
                self.is_trained = True
                return True
        except Exception as e:
            logger.error(f"Failed to load fraud model: {e}")
        return False

    def _ensure_model(self):
        """Lazy-load or train on first use."""
        if not self.is_trained:
            if not self.load():
                self.train()

    # ── Detection ────────────────────────────────────────────────────

    def detect(self, features: dict) -> dict:
        """
        Score a single income entry for fraud.

        Args:
            features: dict mapping FEATURE_NAMES → numeric values

        Returns:
            dict with fraud_score, is_flagged, flags, recommendation
        """
        self._ensure_model()

        X = np.array([[features.get(f, 0) for f in self.FEATURE_NAMES]])
        X_scaled = self.scaler.transform(X)

        # Isolation Forest: -1 = anomaly, 1 = normal
        prediction = self.model.predict(X_scaled)[0]
        # score_samples returns negative anomaly scores; flip & clip to 0–1
        fraud_score = float(np.clip(-self.model.score_samples(X_scaled)[0], 0, 1))

        # Rule-based flags (complement the statistical model)
        flags = []
        if features.get("amount", 0) > 5000:
            flags.append("unusually_high_amount")
        if features.get("entries_per_day", 0) > 5:
            flags.append("too_many_entries_today")
        if features.get("location_distance_km", 0) > 50:
            flags.append("location_mismatch")
        if features.get("amount_uniqueness", 1) < 0.1:
            flags.append("repetitive_amounts")
        if features.get("entry_gap_hours", 24) < 0.5:
            flags.append("rapid_successive_entries")

        hour = features.get("hour_of_entry", 12)
        if hour < 5 or hour > 23:
            flags.append("unusual_time")

        # Combined decision
        is_flagged = prediction == -1 or fraud_score > 0.6 or len(flags) >= 3

        if fraud_score > 0.8 or len(flags) >= 4:
            recommendation = "reject"
        elif fraud_score > 0.5 or len(flags) >= 2:
            recommendation = "review"
        else:
            recommendation = "approve"

        return {
            "fraud_score": round(fraud_score, 3),
            "is_flagged": is_flagged,
            "flags": flags,
            "recommendation": recommendation,
        }


# Module-level singleton
fraud_model = FraudDetectionModel()
