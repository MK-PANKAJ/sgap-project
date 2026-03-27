"""
SGAP Backend — FastAPI Application Entry Point
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.config import settings
from app.database import init_db

# Import routers
from app.api.v1.auth import router as auth_router
from app.api.v1.income import router as income_router
from app.api.v1.trust_score import router as trust_score_router
from app.api.v1.loans import router as loans_router
from app.api.v1.employers import router as employers_router
from app.api.v1.schemes import router as schemes_router
from app.api.v1.verification import router as verification_router
from app.api.v1.admin import router as admin_router
from app.api.v1.workers import router as workers_router
from app.api.v1.future_endpoints import router as future_router

app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    description="S-GAP: Smart Gig-worker Assistance Platform API",
)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS.split(","),
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register routers
app.include_router(auth_router, prefix="/api/v1/auth", tags=["Auth"])
app.include_router(income_router, prefix="/api/v1/income", tags=["Income"])
app.include_router(trust_score_router, prefix="/api/v1/trust-score", tags=["Trust Score"])
app.include_router(loans_router, prefix="/api/v1/loans", tags=["Loans"])
app.include_router(employers_router, prefix="/api/v1/employers", tags=["Employers"])
app.include_router(schemes_router, prefix="/api/v1/schemes", tags=["Schemes"])
app.include_router(verification_router, prefix="/api/v1/verification", tags=["Verification"])
app.include_router(admin_router, prefix="/api/v1/admin", tags=["Admin"])
app.include_router(workers_router, prefix="/api/v1/workers", tags=["Workers"])
app.include_router(future_router, prefix="/api/v1/future", tags=["Future"])


@app.on_event("startup")
def on_startup():
    """Create all database tables on first run."""
    init_db()


@app.get("/")
def read_root():
    return {
        "message": "Welcome to the SGAP Backend!",
        "version": settings.APP_VERSION,
        "docs": "/docs",
    }


@app.get("/health")
def health_check():
    return {"status": "healthy"}
