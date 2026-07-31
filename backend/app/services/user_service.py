from uuid import UUID

from fastapi import HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.branch import Branch
from app.models.role import Role
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
    async def approve_user(
        db: AsyncSession,
        user_id: UUID,
        role_id: int | None = None,
        branch_id: UUID | None = None,
        approved_by: UUID | None = None,
    ):
        existing = await UserRepository.get_by_id(db, user_id)

        if existing is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found",
            )

        if existing.status != UserStatus.PENDING:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Only pending users can be approved.",
            )

        if role_id is not None:
            role = await db.get(Role, role_id)
            if role is None:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"Role with ID {role_id} does not exist.",
                )

            if "admin" in role.name.lower():
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Admin roles cannot be assigned during approval.",
                )

        if branch_id is not None:
            branch = await db.get(Branch, branch_id)

            if branch is None:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Selected branch does not exist.",
                )

            if not branch.is_active:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Selected branch is not active.",
                )

        user = await UserRepository.update_status(
            db=db,
            user_id=user_id,
            new_status=UserStatus.APPROVED,
            approved_by=approved_by,
            role_id=role_id,
            branch_id=branch_id,
        )

        if user is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found",
            )

        return user

    @staticmethod
    async def reject_user(db: AsyncSession, user_id: UUID):
        existing = await UserRepository.get_by_id(db, user_id)

        if existing is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found",
            )

        if existing.status != UserStatus.PENDING:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Only pending users can be rejected.",
            )

        user = await UserRepository.update_status(
            db, user_id, UserStatus.REJECTED
        )
        if user is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found",
            )
        return user

    @staticmethod
    async def suspend_user(db: AsyncSession, user_id: UUID):
        user = await UserRepository.update_status(
            db, user_id, UserStatus.SUSPENDED
        )
        if user is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found",
            )
        return user
