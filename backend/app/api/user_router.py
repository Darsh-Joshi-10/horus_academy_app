from uuid import UUID

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import require_admin
from app.db.session import get_db
from app.schemas.auth import ApproveUserRequest, UserResponse
from app.services.user_service import UserService

router = APIRouter(
    prefix="/users",
    tags=["User Management"],
)


@router.get(
    "/",
    response_model=list[UserResponse],
)
async def get_all_users(
    db: AsyncSession = Depends(get_db),
    admin: UserResponse = Depends(require_admin),
):
    return await UserService.get_all_users(db)


@router.get(
    "/pending",
    response_model=list[UserResponse],
)
async def get_pending_users(
    db: AsyncSession = Depends(get_db),
    admin: UserResponse = Depends(require_admin),
):
    return await UserService.get_pending_users(db)


@router.patch(
    "/{user_id}/approve",
    response_model=UserResponse,
)
async def approve_user(
    user_id: UUID,
    request: ApproveUserRequest | None = None,
    db: AsyncSession = Depends(get_db),
    admin: UserResponse = Depends(require_admin),
):
    return await UserService.approve_user(
        db,
        user_id,
        role_id=request.role_id if request else None,
    )


@router.patch(
    "/{user_id}/reject",
    response_model=UserResponse,
)
async def reject_user(
    user_id: UUID,
    db: AsyncSession = Depends(get_db),
    admin: UserResponse = Depends(require_admin),
):
    return await UserService.reject_user(db, user_id)


@router.patch(
    "/{user_id}/suspend",
    response_model=UserResponse,
)
async def suspend_user(
    user_id: UUID,
    db: AsyncSession = Depends(get_db),
    admin: UserResponse = Depends(require_admin),
):
    return await UserService.suspend_user(db, user_id)
