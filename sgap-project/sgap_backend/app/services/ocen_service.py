"""
OCEN 4.0 Loan Offer Generation Service
========================================
Generates realistic micro-loan offers from simulated NBFC/MFI lenders
based on a worker's trust score.

Score-based tiers:
  500-600  → higher rates (20-24%), smaller amounts
  601-750  → medium rates (14-18%)
  751+     → best rates (8-12%), larger amounts
"""

import uuid
import math
import random
from datetime import datetime, timedelta
from typing import List


def _calculate_emi(principal: float, annual_rate: float, tenure_months: int) -> float:
    """
    Standard EMI formula:
        EMI = P × r × (1+r)^n / ((1+r)^n − 1)
    where r = monthly rate, n = tenure in months.
    """
    if annual_rate == 0:
        return round(principal / tenure_months, 2)
    r = annual_rate / 100 / 12  # monthly interest rate
    n = tenure_months
    emi = principal * r * math.pow(1 + r, n) / (math.pow(1 + r, n) - 1)
    return round(emi, 2)


# Simulated lender pool
LENDER_POOL = [
    {"name": "JanSeva MicroFin", "type": "mfi"},
    {"name": "GigCredit NBFC", "type": "nbfc"},
    {"name": "NanoPay Finance", "type": "fintech"},
    {"name": "Sahara Micro Loans", "type": "mfi"},
    {"name": "UrbanLend Capital", "type": "nbfc"},
]


def generate_offers(
    worker_id: str,
    amount_requested: float,
    trust_score: int,
    tenure_months: int = 6,
) -> List[dict]:
    """
    Generate 3-5 realistic loan offers based on the worker's trust score.

    Returns a list of offer dicts, with the best offer marked `is_best=True`.
    """
    random.seed(hash(worker_id) % 2**32)

    # Determine tier
    if trust_score >= 751:
        rate_range = (8.0, 12.0)
        amount_multiplier = (0.9, 1.2)
        num_offers = random.randint(3, 5)
    elif trust_score >= 601:
        rate_range = (14.0, 18.0)
        amount_multiplier = (0.6, 0.9)
        num_offers = random.randint(3, 4)
    else:
        rate_range = (20.0, 24.0)
        amount_multiplier = (0.3, 0.6)
        num_offers = random.randint(2, 3)

    offers = []
    selected_lenders = random.sample(LENDER_POOL, min(num_offers, len(LENDER_POOL)))

    for lender in selected_lenders:
        rate = round(random.uniform(*rate_range), 1)
        offered_amount = round(
            amount_requested * random.uniform(*amount_multiplier) / 100
        ) * 100  # round to nearest 100
        offered_amount = max(offered_amount, 1000)

        tenure = random.choice([3, 6, 9, 12]) if tenure_months == 6 else tenure_months
        emi = _calculate_emi(offered_amount, rate, tenure)
        total_repayable = round(emi * tenure, 2)
        processing_fee = round(offered_amount * random.uniform(0.01, 0.03), 2)

        offers.append({
            "offer_id": str(uuid.uuid4()),
            "lender_name": lender["name"],
            "lender_type": lender["type"],
            "amount_offered": offered_amount,
            "interest_rate": rate,
            "tenure_months": tenure,
            "emi_amount": emi,
            "total_repayable": total_repayable,
            "processing_fee": processing_fee,
            "is_best": False,
            "expires_at": (datetime.utcnow() + timedelta(hours=48)).isoformat(),
            "conditions": f"Minimum trust score {trust_score - 50} required",
        })

    # Mark the offer with lowest total repayable as best
    if offers:
        best = min(offers, key=lambda o: o["total_repayable"])
        best["is_best"] = True

    return offers
