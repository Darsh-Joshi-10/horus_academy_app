from sqlalchemy.ext.asyncio import AsyncEngine

from app.core.config import settings
from app.db.session import engine
from app.models import branch, role, user  # noqa: F401
from app.models.base import Base


async def initialize_database(*, drop_existing: bool = False) -> None:
    """Create database tables if they do not exist."""
    async with engine.begin() as connection:
        if drop_existing:
            await connection.run_sync(Base.metadata.drop_all)

        await connection.run_sync(Base.metadata.create_all)
