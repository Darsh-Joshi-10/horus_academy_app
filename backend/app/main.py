from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import text

from app.api.auth_router import router as auth_router
from app.api.branch_router import router as branch_router
from app.api.role_router import router as role_router
from app.api.user_router import router as user_router
from app.core.config import settings
from app.db.init_db import initialize_database
from app.db.session import AsyncSessionLocal

app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    description="Backend API for Horus Academy Management System",
    redirect_slashes=False,
)


@app.on_event("startup")
async def startup_event() -> None:
    await initialize_database()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(
    branch_router,
    prefix="/api",
)

app.include_router(
    role_router,
    prefix="/api",
)

app.include_router(
    user_router,
    prefix="/api",
)

app.include_router(
    auth_router,
    prefix="/api/auth",
    tags=["Authentication"],
)

@app.get("/")
async def root():
    return {
        "success": True,
        "message": f"{settings.APP_NAME} is running 🚀",
        "version": settings.APP_VERSION,
    }


@app.get("/health")
async def health_check():
    try:
        async with AsyncSessionLocal() as session:
            await session.execute(text("SELECT 1"))

        return {
            "success": True,
            "database": "Connected ✅",
            "message": "Server is healthy",
        }

    except Exception as e:
        return {
            "success": False,
            "database": "Disconnected ❌",
            "error": str(e),
        }


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(
        "app.main:app",
        host=settings.HOST,
        port=settings.PORT,
        reload=settings.DEBUG,
    )
