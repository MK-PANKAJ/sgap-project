"""
SGAP Database Engine and Session Management
Supports both SQLite (dev) and PostgreSQL (prod).
"""

from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from app.config import settings

# Handle SQLite-specific connect args
connect_args = {}
if settings.DATABASE_URL.startswith("sqlite"):
    connect_args = {"check_same_thread": False}

engine = create_engine(
    settings.DATABASE_URL,
    connect_args=connect_args,
    echo=settings.DEBUG,
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()


def get_db():
    """FastAPI dependency that yields a database session."""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def init_db():
    """Create all tables. Called on app startup."""
    # Import all models so Base.metadata knows about them
    import app.models.user  # noqa: F401
    import app.models.income_record  # noqa: F401
    import app.models.trust_score  # noqa: F401
    import app.models.loan  # noqa: F401
    import app.models.scheme  # noqa: F401

    Base.metadata.create_all(bind=engine)
