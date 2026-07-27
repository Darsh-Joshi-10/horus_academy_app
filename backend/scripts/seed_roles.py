"""Seed default roles required for user registration."""

import asyncio
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from sqlalchemy import select

from app.db.session import AsyncSessionLocal
from app.models.role import Role
from app.models.user import User  # noqa: F401 - register models

DEFAULT_ROLES = [
    {"id": 1, "name": "Admin", "description": "Administrator"},
    {"id": 2, "name": "Teacher", "description": "Teacher"},
    {"id": 3, "name": "Student", "description": "Student"},
]


async def seed_roles() -> None:
    async with AsyncSessionLocal() as session:
        for role_data in DEFAULT_ROLES:
            existing = await session.get(Role, role_data["id"])

            if existing is None:
                session.add(Role(**role_data, is_active=True))

        await session.commit()

        result = await session.execute(select(Role.id, Role.name))
        roles = result.all()
        print(f"Seeded roles: {len(roles)} total")
        for role_id, name in roles:
            print(f"  - {role_id}: {name}")


if __name__ == "__main__":
    asyncio.run(seed_roles())
