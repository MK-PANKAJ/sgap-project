"""
Voice Income Processing Pipeline
=================================
1. Receive audio → send to Bhashini for transcription
2. Parse transcribed text → extract amount, employer, work type
3. Return structured data for user confirmation

Supports: Hindi, English, Hinglish, Hindi number words (aath sau = 800)
"""

import re
import logging
from app.services.bhashini_service import bhashini

logger = logging.getLogger(__name__)


class VoiceService:
    """
    Parses voice-transcribed Hindi/English text to extract structured
    income data: amount (₹), employer name, and work type.
    """

    # ── Hindi number words (Romanised + Devanagari) ──────────────────

    HINDI_NUMBERS = {
        # Units
        "ek": 1, "एक": 1,
        "do": 2, "दो": 2,
        "teen": 3, "तीन": 3,
        "chaar": 4, "चार": 4,
        "paanch": 5, "पांच": 5,
        "chhe": 6, "छह": 6,
        "saat": 7, "सात": 7,
        "aath": 8, "आठ": 8,
        "nau": 9, "नौ": 9,
        # Tens
        "das": 10, "दस": 10,
        "gyarah": 11, "ग्यारह": 11,
        "barah": 12, "बारह": 12,
        "terah": 13, "तेरह": 13,
        "chaudah": 14, "चौदह": 14,
        "pandrah": 15, "पंद्रह": 15,
        "solah": 16, "सोलह": 16,
        "satrah": 17, "सत्रह": 17,
        "atharah": 18, "अठारह": 18,
        "unees": 19, "उन्नीस": 19,
        "bees": 20, "बीस": 20,
        "tees": 30, "तीस": 30,
        "chalees": 40, "चालीस": 40,
        "pachaas": 50, "पचास": 50,
        "saath": 60, "साठ": 60,
        "sattar": 70, "सत्तर": 70,
        "assi": 80, "अस्सी": 80,
        "nabbe": 90, "नब्बे": 90,
    }

    MULTIPLIERS = {
        "sau": 100, "सौ": 100, "hundred": 100,
        "hazaar": 1000, "हजार": 1000, "hazar": 1000, "thousand": 1000,
        "lakh": 100000, "लाख": 100000,
    }

    # ── Work type keyword mapping ────────────────────────────────────

    WORK_TYPE_KEYWORDS = {
        "Construction": [
            "mistri", "building", "cement", "eent", "mazdoor",
            "construction", "plaster", "rajgir",
            "मिस्त्री", "मजदूर", "सीमेंट", "राजगीर",
        ],
        "Domestic": [
            "safai", "bartan", "jhadu", "cooking", "ghar",
            "domestic", "maid",
            "सफाई", "बर्तन", "झाड़ू",
        ],
        "Delivery": [
            "delivery", "zomato", "swiggy", "order", "parcel",
            "dunzo", "blinkit",
            "डिलीवरी",
        ],
        "Driver": [
            "gaadi", "auto", "taxi", "uber", "ola", "rapido",
            "driver", "sawari",
            "गाड़ी", "ड्राइवर",
        ],
        "Factory": [
            "factory", "mill", "karkhana", "machine",
            "फैक्ट्री", "कारखाना",
        ],
        "Shop": [
            "dukaan", "shop", "counter", "bechna",
            "दुकान", "बेचना",
        ],
        "Repair": [
            "repair", "theek", "plumber", "electrician", "mechanic",
            "मरम्मत",
        ],
        "Agriculture": [
            "kheti", "fasal", "kisan", "buwai",
            "खेती", "फसल", "किसान",
        ],
    }

    # ── Public API ───────────────────────────────────────────────────

    async def process_voice(
        self,
        audio_base64: str,
        language: str = "hi",
    ) -> dict:
        """
        End-to-end pipeline: audio → transcription → structured income data.

        Returns dict with keys:
          success, text, amount, employer_name, work_type,
          bhashini_model, language, [error]
        """
        transcription = await bhashini.speech_to_text(audio_base64, language)
        text = transcription.get("text", "")

        if not text:
            return {
                "success": False,
                "error": "आवाज़ समझ नहीं आई। फिर से बोलो।",
                "text": "",
                "amount": 0,
                "employer_name": "",
                "work_type": "Other",
            }

        parsed = self.parse_income_text(text)
        return {
            "success": True,
            "text": text,
            "amount": parsed["amount"],
            "employer_name": parsed["employer_name"],
            "work_type": parsed["work_type"],
            "bhashini_model": transcription.get("model_used", ""),
            "language": language,
        }

    def parse_income_text(self, text: str) -> dict:
        """
        Parse a Hindi/English/Hinglish sentence into structured income data.

        Works on raw transcription output (no pre-processing needed).
        """
        text_lower = text.lower().strip()
        return {
            "amount": self._extract_amount(text_lower),
            "employer_name": self._extract_employer(text, text_lower),
            "work_type": self._extract_work_type(text_lower),
        }

    # ── Amount extraction ────────────────────────────────────────────

    def _extract_amount(self, text: str) -> float:
        """
        Extract a rupee amount from text using three strategies:
          1. Explicit patterns (₹500, 500 rupaye, 500 ka)
          2. Standalone digits in a reasonable range (50 – 5,00,000)
          3. Hindi number words (aath sau → 800, paanch hazaar → 5000)
        """
        # Strategy 1: explicit currency patterns
        digit_patterns = [
            r"₹\s*(\d+)",
            r"(\d+)\s*(?:rupaye|rupee|rs|रुपये|रुपए)",
            r"(\d+)\s*(?:ka|ke|ki)",
        ]
        for pattern in digit_patterns:
            match = re.search(pattern, text, re.IGNORECASE)
            if match:
                amount = int(match.group(1))
                if amount >= 10:
                    return float(amount)

        # Strategy 2: any standalone digit in a reasonable daily-wage range
        all_digits = re.findall(r"\b(\d+)\b", text)
        reasonable = [int(d) for d in all_digits if 50 <= int(d) <= 500000]
        if reasonable:
            return float(max(reasonable))

        # Strategy 3: Hindi/Hinglish number words
        words = text.split()
        total = 0
        current = 0
        for word in words:
            word_clean = word.strip(",.!?।")
            if word_clean in self.HINDI_NUMBERS:
                current = self.HINDI_NUMBERS[word_clean]
            elif word_clean in self.MULTIPLIERS:
                multiplier = self.MULTIPLIERS[word_clean]
                if current == 0:
                    current = 1
                current *= multiplier
                total += current
                current = 0
        total += current

        return float(total) if total >= 10 else 0.0

    # ── Work type extraction ─────────────────────────────────────────

    def _extract_work_type(self, text: str) -> str:
        """Match keywords against known work categories. 'Other' if none match."""
        max_matches = 0
        best_type = "Other"
        for work_type, keywords in self.WORK_TYPE_KEYWORDS.items():
            matches = sum(1 for kw in keywords if kw in text)
            if matches > max_matches:
                max_matches = matches
                best_type = work_type
        return best_type

    # ── Employer name extraction ─────────────────────────────────────

    def _extract_employer(self, original_text: str, text_lower: str) -> str:
        """
        Extract a likely employer name using Hindi/English honorific and
        contextual patterns (e.g. "Sharma bhai", "Gupta seth se 500").
        """
        patterns = [
            r"(\w+)\s+(?:bhai|भाई)",
            r"(\w+)\s+(?:seth|सेठ|साहब)",
            r"(\w+)\s+(?:ji|जी|madam|मैडम)",
            r"(\w+)\s+se\s+\d+",
            r"(\w+)\s+ने\s+दि",
            r"(\w+)\s+से\s+(?:\d+|पैसे|रुपये)",
        ]
        skip_words = {
            "aaj", "kal", "mujhe", "mera", "rupaye", "paise", "kaam",
            "आज", "कल", "मुझे", "मेरा",
        }

        for pattern in patterns:
            match = re.search(pattern, text_lower, re.IGNORECASE)
            if match:
                name = match.group(1).strip()
                if name.lower() not in skip_words and len(name) > 1:
                    # Recover original casing from the input
                    start = text_lower.find(name)
                    if start >= 0:
                        return original_text[start : start + len(name)].strip().capitalize()
                    return name.capitalize()
        return ""


# Module-level singleton
voice_service = VoiceService()
