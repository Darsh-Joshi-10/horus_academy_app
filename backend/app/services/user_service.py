from uuid import UUID

from fastapi import HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.user import UserStatus
from app.repositories.user_repository import UserRepository


class UserService:

    @staticmethod
    async def get_all_users(db: AsyncSession):
        return await UserRepository.get_all_users(db)

    @staticmethod
    async def get_pending_users(db: AsyncSession):
        return await UserRepository.get_pending_users(db)

    @staticmethod
    async def approve_user(db: AsyncSession, user_id: UUID, role_id: int | None = None):
        user = await UserRepository.update_status(
            db,
            user_id,
            UserStatus.APPROVED,
            role_id=role_id,
        )
        if user is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found",
            )
        return user

    @staticmethod
    async def reject_user(db: AsyncSession, user_id: UUID):
        user = await UserRepository.update_status(db, user_id, UserStatus.REJECTED)
        if user is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found",
            )
        return user

    @staticmethod
    async def suspend_user(db: AsyncSession, user_id: UUID):
        user = await UserRepository.update_status(db, user_id, UserStatus.SUSPENDED)
        if user is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found",
            )
        return user
