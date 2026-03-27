"""
SGAP Encryption Utilities
AES-256 symmetric encryption using Fernet (PBKDF2-derived key).
Used for encrypting PII like Aadhaar numbers at rest.
"""

from cryptography.fernet import Fernet
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
import base64
from app.config import settings


def _get_fernet() -> Fernet:
    """Derive a Fernet key from the application encryption secret."""
    kdf = PBKDF2HMAC(
        algorithm=hashes.SHA256(),
        length=32,
        salt=b"sgap-encryption-salt-2025",
        iterations=100000,
    )
    key = base64.urlsafe_b64encode(kdf.derive(settings.AES_ENCRYPTION_KEY.encode()))
    return Fernet(key)


def encrypt_data(plain_text: str) -> str:
    """Encrypt a plaintext string and return the ciphertext as a string."""
    f = _get_fernet()
    return f.encrypt(plain_text.encode()).decode()


def decrypt_data(encrypted_text: str) -> str:
    """Decrypt a ciphertext string back to plaintext."""
    f = _get_fernet()
    return f.decrypt(encrypted_text.encode()).decode()
