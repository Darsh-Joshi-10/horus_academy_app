"""Create a demo user for local development."""

import asyncio
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from sqlalchemy import select

from app.core.security import hash_password
from app.db.session import AsyncSessionLocal
from app.models.branch import Branch  # noqa: F401 - register models
from app.models.role import Role
from app.models.user import User, UserStatus

DEMO_EMAIL = "demo@horus.com"
DEMO_PASSWORD = "password123"


async def create_demo_user() -> None:
    async with AsyncSessionLocal() as session:
        role = await session.get(Role, 1)

        if role is None:
            session.add(
                Role(
                    id=1,
                    name="Admin",
                    description="Administrator",
                    is_active=True,
                )
            )
            await session.flush()

        existing = await session.execute(
            select(User).where(User.email == DEMO_EMAIL)
        )
        user = existing.scalar_one_or_none()

        if user is not None:
            print(f"Demo user already exists: {DEMO_EMAIL}")
            return

        session.add(
            User(
                first_name="Demo",
                last_name="User",
                email=DEMO_EMAIL,
                phone="5550001111",
                password_hash=hash_password(DEMO_PASSWORD),
                role_id=1,
                status=UserStatus.APPROVED,
                is_active=True,
            )
        )

        await session.commit()
        print(f"Created demo user: {DEMO_EMAIL} / {DEMO_PASSWORD}")


if __name__ == "__main__":
    asyncio.run(create_demo_user())
