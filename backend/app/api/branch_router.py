from uuid import UUID

from fastapi import APIRouter, Depends, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import require_admin
from app.db.session import get_db
from app.schemas.auth import UserResponse
from app.schemas.branch import (
    BranchCreate,
    BranchResponse,
    BranchUpdate,
)
from app.services.branch_service import branch_service

router = APIRouter(
    prefix="/branches",
    tags=["Branches"],
)


@router.post(
    "",
    response_model=BranchResponse,
    status_code=status.HTTP_201_CREATED,
)
async def create_branch(
    branch_data: BranchCreate,
    db: AsyncSession = Depends(get_db),
    admin: UserResponse = Depends(require_admin),
):
    return await branch_service.create_branch(
        db,
        branch_data,
    )


@router.get(
    "",
    response_model=list[BranchResponse],
)
async def get_all_branches(
    is_active: bool | None = None,
    db: AsyncSession = Depends(get_db),
):
    return await branch_service.get_all_branches(
        db,
        is_active=is_active,
    )


@router.get(
    "/{branch_id}",
    response_model=BranchResponse,
)
async def get_branch(
    branch_id: UUID,
    db: AsyncSession = Depends(get_db),
):
    return await branch_service.get_branch_by_id(
        db,
        branch_id,
    )


@router.put(
    "/{branch_id}",
    response_model=BranchResponse,
)
async def update_branch(
    branch_id: UUID,
    branch_data: BranchUpdate,
    db: AsyncSession = Depends(get_db),
    admin: UserResponse = Depends(require_admin),
):
    return await branch_service.update_branch(
        db,
        branch_id,
        branch_data,
    )


@router.delete(
    "/{branch_id}",
    status_code=status.HTTP_204_NO_CONTENT,
)
async def delete_branch(
    branch_id: UUID,
    db: AsyncSession = Depends(get_db),
    admin: UserResponse = Depends(require_admin),
):
    await branch_service.delete_branch(
        db,
        branch_id,
    )

    return None