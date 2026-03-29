"""
S-GAP Credit Scoring Model
============================
Algorithm: Gradient Boosting Regressor (scikit-learn)
Output:    Credit score 300 – 1000

Features (10):
  income_consistency, avg_monthly_income, income_variance,
  verification_rate, employer_diversity, platform_tenure_days,
  total_entries, avg_daily_income, dispute_rate, repayment_ratio

Score Bands:
  300-500  : building  (बन रहा है)
  501-650  : fair      (ठीक है)
  651-800  : good      (अच्छा है)
  801-1000 : excellent (बहुत अच्छा)
"""

import numpy as np
import pandas as pd
from sklearn.ensemble import GradientBoostingRegressor
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split
import joblib
import os
import logging

logger = logging.getLogger(__name__)

MODELS_DIR = os.path.join(os.path.dirname(__file__), "models")


class CreditScoringModel:
    """
    Gradient Boosting credit scorer.

    Auto-trains on synthetic data the first time a prediction is requested
    (if no saved model exists).  Models are persisted to disk via joblib.
    """

    FEATURE_NAMES = [
        "income_consistency",
        "avg_monthly_income",
        "income_variance",
        "verification_rate",
        "employer_diversity",
        "platform_tenure_days",
        "total_entries",
        "avg_daily_income",
        "dispute_rate",
        "repayment_ratio",
    ]

    def __init__(self):
        self.model = None
        self.scaler = StandardScaler()
        self.model_path = os.path.join(MODELS_DIR, "credit_model.pkl")
        self.scaler_path = os.path.join(MODELS_DIR, "credit_scaler.pkl")
        self.version = "1.0.0"
        self.is_trained = False

    # ── Synthetic data generation ────────────────────────────────────

    def _generate_synthetic_data(self, n_samples: int = 5000) -> pd.DataFrame:
        """
        Create realistic synthetic gig-worker data for model training.
        Score formula weights income consistency & verification most heavily.
        """
        np.random.seed(42)

        data = {
            "income_consistency": np.random.beta(2, 3, n_samples),
            "avg_monthly_income": np.clip(
                np.random.lognormal(9.5, 0.8, n_samples), 1000, 100000
            ),
            "income_variance": np.clip(
                np.random.exponential(0.3, n_samples), 0, 2
            ),
            "verification_rate": np.random.beta(3, 2, n_samples),
            "employer_diversity": np.clip(
                np.random.poisson(3, n_samples) + 1, 1, 20
            ),
            "platform_tenure_days": np.random.uniform(1, 365, n_samples),
            "total_entries": np.clip(
                np.random.poisson(20, n_samples) + 1, 1, 200
            ),
            "avg_daily_income": np.clip(
                np.random.lognormal(6.5, 0.5, n_samples), 100, 5000
            ),
            "dispute_rate": np.random.beta(1, 10, n_samples),
            "repayment_ratio": np.random.beta(5, 1, n_samples),
        }
        df = pd.DataFrame(data)

        # Composite score formula (mirrors real credit-scoring logic)
        score = (
            df["income_consistency"] * 200
            + np.log1p(df["avg_monthly_income"]) * 30
            + (1 - df["income_variance"].clip(0, 1)) * 100
            + df["verification_rate"] * 150
            + np.sqrt(df["employer_diversity"]) * 30
            + np.log1p(df["platform_tenure_days"]) * 15
            + np.log1p(df["total_entries"]) * 20
            + (1 - df["dispute_rate"]) * 50
            + df["repayment_ratio"] * 100
            + np.random.normal(0, 20, n_samples)
        )

        # Normalise into 300–1000 band
        score_min, score_max = score.min(), score.max()
        df["credit_score"] = (
            np.clip(
                300 + (score - score_min) / (score_max - score_min) * 700,
                300,
                1000,
            )
            .round()
            .astype(int)
        )
        return df

    # ── Training ─────────────────────────────────────────────────────

    def train(self) -> dict:
        """Train the model on synthetic data and persist to disk."""
        df = self._generate_synthetic_data(5000)
        X = df[self.FEATURE_NAMES]
        y = df["credit_score"]

        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=0.2, random_state=42
        )
        X_train_scaled = self.scaler.fit_transform(X_train)
        X_test_scaled = self.scaler.transform(X_test)

        self.model = GradientBoostingRegressor(
            n_estimators=200,
            max_depth=5,
            learning_rate=0.1,
            random_state=42,
        )
        self.model.fit(X_train_scaled, y_train)

        # Save
        os.makedirs(MODELS_DIR, exist_ok=True)
        joblib.dump(self.model, self.model_path)
        joblib.dump(self.scaler, self.scaler_path)
        self.is_trained = True

        train_r2 = round(self.model.score(X_train_scaled, y_train), 4)
        test_r2 = round(self.model.score(X_test_scaled, y_test), 4)
        logger.info("Credit model trained — train R²=%s, test R²=%s", train_r2, test_r2)

        return {
            "model": "GradientBoostingRegressor",
            "train_r2": train_r2,
            "test_r2": test_r2,
        }

    # ── Loading ──────────────────────────────────────────────────────

    def load(self) -> bool:
        """Load a previously trained model from disk."""
        try:
            if os.path.exists(self.model_path) and os.path.exists(self.scaler_path):
                self.model = joblib.load(self.model_path)
                self.scaler = joblib.load(self.scaler_path)
                self.is_trained = True
                return True
        except Exception as e:
            logger.error(f"Failed to load credit model: {e}")
        return False

    def _ensure_model(self):
        """Lazy-load or train on first use."""
        if not self.is_trained:
            if not self.load():
                self.train()

    # ── Prediction ───────────────────────────────────────────────────

    def predict(self, features: dict) -> dict:
        """
        Predict a credit score and return rich result.

        Args:
            features: dict mapping FEATURE_NAMES → float values

        Returns:
            dict with score, band, band_hindi, component_scores, improvement_tips
        """
        self._ensure_model()

        X = pd.DataFrame([[features.get(f, 0) for f in self.FEATURE_NAMES]], columns=self.FEATURE_NAMES)
        raw_score = self.model.predict(self.scaler.transform(X))[0]
        score = int(np.clip(raw_score, 300, 1000))

        # Band classification
        if score >= 800:
            band, band_hindi = "excellent", "बहुत अच्छा ⭐⭐⭐"
        elif score >= 650:
            band, band_hindi = "good", "अच्छा है ⭐⭐"
        elif score >= 500:
            band, band_hindi = "fair", "ठीक है ⭐"
        else:
            band, band_hindi = "building", "बन रहा है 🔨"

        # Per-component breakdown (0–100 sub-scores for the dashboard)
        component_scores = {
            "income_consistency": round(
                features.get("income_consistency", 0) * 100
            ),
            "verification_rate": round(
                features.get("verification_rate", 0) * 100
            ),
            "income_stability": round(
                (1 - min(features.get("income_variance", 0), 1)) * 100
            ),
            "platform_tenure": min(
                round(features.get("platform_tenure_days", 0) / 365 * 100), 100
            ),
            "employer_diversity": min(
                round(features.get("employer_diversity", 0) / 5 * 100), 100
            ),
            "repayment_history": round(
                features.get("repayment_ratio", 0.5) * 100
            ),
        }

        # Actionable improvement tips (Hindi + English)
        tips = []
        if features.get("income_consistency", 0) < 0.7:
            tips.append({
                "tip_hindi": "रोज़ कमाई रिकॉर्ड करो",
                "tip_en": "Log income daily",
                "potential_increase": 15,
            })
        if features.get("verification_rate", 0) < 0.8:
            tips.append({
                "tip_hindi": "मालिक से कन्फर्म करवाओ",
                "tip_en": "Get employer confirmation",
                "potential_increase": 20,
            })
        if features.get("employer_diversity", 0) < 3:
            tips.append({
                "tip_hindi": "और मालिकों के साथ काम करो",
                "tip_en": "Work with more employers",
                "potential_increase": 10,
            })

        return {
            "score": score,
            "band": band,
            "band_hindi": band_hindi,
            "model_version": self.version,
            "component_scores": component_scores,
            "improvement_tips": tips,
        }


# Module-level singleton
credit_model = CreditScoringModel()
