"""
SGAP Backend Configuration
Loads settings from environment variables with sensible defaults.
"""

from pydantic_settings import BaseSettings
from typing import Optional


class Settings(BaseSettings):
    # Application
    APP_NAME: str = "SGAP Backend"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = True
    DEMO_MODE: bool = True

    # Certificate verification
    CERTIFICATE_BASE_URL: str = "https://sgap.in/verify"

    # Database
    DATABASE_URL: str = "sqlite:///./sgap_dev.db"

    # JWT Authentication
    JWT_SECRET: str = "sgap-dev-jwt-secret-change-in-production-2025"
    JWT_ALGORITHM: str = "HS256"
    JWT_EXPIRY_HOURS: int = 72

    # Encryption
    AES_ENCRYPTION_KEY: str = "sgap-dev-encryption-key-change-in-production"

    # OTP
    OTP_EXPIRY_MINUTES: int = 10
    OTP_LENGTH: int = 6

    # External Services (optional)
    SMS_API_KEY: Optional[str] = None
    SMS_API_URL: Optional[str] = None

    # Bhashini AI Platform (Government of India — free for Indian languages)
    BHASHINI_PIPELINE_URL: str = "https://meity-auth.ulcacontrib.org/ulca/apis/v0/model/getModelsPipeline"
    BHASHINI_USER_ID: Optional[str] = None
    BHASHINI_API_KEY: Optional[str] = None

    # CORS
    ALLOWED_ORIGINS: str = "*"

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
        case_sensitive = True


settings = Settings()
