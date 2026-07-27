from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.models.user import User


class UserRepository:

    @staticmethod
    async def get_by_email(
        db: AsyncSession,
        email: str,
    ) -> User | None:

        result = await db.execute(
            select(User)
            .options(selectinload(User.role))
            .where(User.email == email)
        )

        return result.scalar_one_or_none()

    @staticmethod
    async def get_by_id(
        db: AsyncSession,
        user_id: UUID,
    ) -> User | None:

        result = await db.execute(
            select(User)
            .options(selectinload(User.role))
            .where(User.id == user_id)
        )

        return result.scalar_one_or_none()

    @staticmethod
    async def create(
        db: AsyncSession,
        user: User,
    ) -> User:

        db.add(user)

        await db.commit()

        await db.refresh(user)

        return user

    @staticmethod
    async def get_all_users(
        db: AsyncSession,
    ) -> list[User]:
        result = await db.execute(
            select(User)
            .options(selectinload(User.role))
            .order_by(User.created_at.desc())
        )

        return list(result.scalars().all())

    @staticmethod
    async def get_pending_users(
        db: AsyncSession,
    ) -> list[User]:
        result = await db.execute(
            select(User)
            .options(selectinload(User.role))
            .where(User.status == "PENDING")
            .order_by(User.created_at.desc())
        )

        return list(result.scalars().all())

    @staticmethod
    async def update_status(
        db: AsyncSession,
        user_id: UUID,
        new_status: str,
        role_id: int | None = None,
    ) -> User | None:
        user = await UserRepository.get_by_id(db, user_id)

        if user is None:
            return None

        user.status = new_status

        if role_id is not None:
            user.role_id = role_id

        await db.commit()
        await db.refresh(user)

        return user

