from fastapi import HTTPException, status
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import (
    create_access_token,
    hash_password,
    verify_password,
)
from app.models.branch import Branch
from app.models.role import Role
from app.models.user import User, UserStatus
from app.repositories.user_repository import UserRepository


class AuthService:

    @staticmethod
    async def register(
        db: AsyncSession,
        request,
    ):

        existing_user = await UserRepository.get_by_email(
            db,
            request.email,
        )

        if existing_user:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Email already registered.",
            )

        role_result = await db.execute(
            select(Role).where(Role.name == "Student")
        )
        role = role_result.scalar_one_or_none()

        if role is None:
            role_result = await db.execute(
                select(Role).order_by(Role.id.asc())
            )
            role = role_result.scalars().first()

        if role is None:
            role = Role(
                name="Student",
                description="Default student role",
                is_active=True,
            )
            db.add(role)
            await db.flush()

        if request.branch_id is not None:
            branch = await db.get(Branch, request.branch_id)

            if branch is None:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Selected branch does not exist.",
                )

        user = User(
            first_name=request.first_name,
            last_name=request.last_name,
            email=request.email,
            phone=request.phone,
            password_hash=hash_password(request.password),
            role_id=role.id,
            branch_id=request.branch_id,
            status=UserStatus.PENDING,
        )

        try:
            return await UserRepository.create(
                db,
                user,
            )
        except IntegrityError as exc:
            await db.rollback()
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Unable to create user. Please check the provided data.",
            ) from exc

    @staticmethod
    async def login(
        db: AsyncSession,
        request,
    ):

        user = await UserRepository.get_by_email(
            db,
            request.email,
        )

        if user is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid email or password.",
            )

        if not verify_password(
            request.password,
            user.password_hash,
        ):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid email or password.",
            )

        if not user.is_active:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Account has been disabled.",
            )

        if user.status == UserStatus.PENDING:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Your account is awaiting admin approval.",
            )

        if user.status != UserStatus.APPROVED:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Your account is not active.",
            )

        token = create_access_token(
            {
                "sub": str(user.id),
                "role": user.role.name,
            }
        )

        return {
            "access_token": token,
            "token_type": "bearer",
            "user": user,
        }