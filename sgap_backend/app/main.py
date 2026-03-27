"""
SGAP Backend — FastAPI Application Entry Point
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.config import settings
from app.database import init_db

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


@app.on_event("startup")
def on_startup():
    """Create all database tables on first run."""
    init_db()


@app.get("/")
def read_root():
    return {"message": "Welcome to the SGAP Backend!", "version": settings.APP_VERSION}


@app.get("/health")
def health_check():
    return {"status": "healthy"}
