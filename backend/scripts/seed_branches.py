"""Seed default branches for development and testing."""

import asyncio
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from sqlalchemy import select

from app.db.session import AsyncSessionLocal
from app.models.branch import Branch
from app.models.role import Role  # noqa: F401 - register models
from app.models.user import User  # noqa: F401 - register models

DEFAULT_BRANCHES = [
    {
        "branch_code": "HQ001",
        "name": "Horus Academy Headquarters",
        "address": "123 Education Lane",
        "city": "Mumbai",
        "state": "Maharashtra",
        "phone": "9876543210",
        "email": "hq@horusacademy.com",
        "is_active": True,
    },
    {
        "branch_code": "BR002",
        "name": "Horus Academy Pune",
        "address": "45 Knowledge Park Road",
        "city": "Pune",
        "state": "Maharashtra",
        "phone": "9876543211",
        "email": "pune@horusacademy.com",
        "is_active": True,
    },
]


async def seed_branches() -> None:
    async with AsyncSessionLocal() as session:
        for branch_data in DEFAULT_BRANCHES:
            result = await session.execute(
                select(Branch).where(
                    Branch.branch_code == branch_data["branch_code"]
                )
            )
            existing = result.scalar_one_or_none()

            if existing is None:
                session.add(Branch(**branch_data))

        await session.commit()

        result = await session.execute(
            select(Branch.branch_code, Branch.name, Branch.is_active)
        )
        branches = result.all()
        print(f"Seeded branches: {len(branches)} total")
        for branch_code, name, is_active in branches:
            status = "active" if is_active else "inactive"
            print(f"  - {branch_code}: {name} ({status})")


if __name__ == "__main__":
    asyncio.run(seed_branches())
