"""
SGAP General Helper Utilities
Phone validation, city-to-state mapping, and currency formatting.
"""

import re
from datetime import datetime


def validate_indian_phone(phone: str) -> bool:
    """Check if a string is a valid 10-digit Indian mobile number."""
    return bool(
        re.match(
            r"^[6-9]\d{9}$",
            phone.replace("+91", "").replace(" ", "").replace("-", ""),
        )
    )


def clean_phone(phone: str) -> str:
    """Strip country code, spaces, and dashes from a phone string."""
    return phone.replace("+91", "").replace(" ", "").replace("-", "").strip()


def get_state_from_city(city: str) -> str:
    """Look up the state for a known Indian city. Returns '' if unknown."""
    city_state_map = {
        "Delhi": "Delhi",
        "Mumbai": "Maharashtra",
        "Bangalore": "Karnataka",
        "Bengaluru": "Karnataka",
        "Chennai": "Tamil Nadu",
        "Kolkata": "West Bengal",
        "Hyderabad": "Telangana",
        "Pune": "Maharashtra",
        "Ahmedabad": "Gujarat",
        "Jaipur": "Rajasthan",
        "Lucknow": "Uttar Pradesh",
        "Patna": "Bihar",
        "Bhopal": "Madhya Pradesh",
        "Chandigarh": "Punjab",
        "Indore": "Madhya Pradesh",
        "Nagpur": "Maharashtra",
        "Surat": "Gujarat",
        "Kanpur": "Uttar Pradesh",
        "Varanasi": "Uttar Pradesh",
        "Agra": "Uttar Pradesh",
    }
    return city_state_map.get(city, "")


def format_currency(amount: float) -> str:
    """Format a rupee amount with Hindi unit suffixes (लाख / हज़ार)."""
    if amount >= 100000:
        return f"₹{amount / 100000:.1f} लाख"
    elif amount >= 1000:
        return f"₹{amount / 1000:.1f} हज़ार"
    else:
        return f"₹{int(amount)}"
