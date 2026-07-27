from uuid import UUID

from fastapi import HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.branch import Branch
from app.repositories.branch_repository import branch_repository
from app.schemas.branch import BranchCreate, BranchUpdate


class BranchService:

    async def create_branch(
        self,
        db: AsyncSession,
        branch_data: BranchCreate,
    ) -> Branch:

        existing_branch = await branch_repository.get_by_branch_code(
            db,
            branch_data.branch_code,
        )

        if existing_branch:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Branch code already exists.",
            )

        return await branch_repository.create(db, branch_data)

    async def get_all_branches(
        self,
        db: AsyncSession,
    ) -> list[Branch]:

        return await branch_repository.get_all(db)

    async def get_branch_by_id(
        self,
        db: AsyncSession,
        branch_id: UUID,
    ) -> Branch:

        branch = await branch_repository.get_by_id(
            db,
            branch_id,
        )

        if not branch:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Branch not found.",
            )

        return branch

    async def update_branch(
        self,
        db: AsyncSession,
        branch_id: UUID,
        branch_data: BranchUpdate,
    ) -> Branch:

        branch = await self.get_branch_by_id(
            db,
            branch_id,
        )

        return await branch_repository.update(
            db,
            branch,
            branch_data,
        )

    async def delete_branch(
        self,
        db: AsyncSession,
        branch_id: UUID,
    ) -> None:

        branch = await self.get_branch_by_id(
            db,
            branch_id,
        )

        await branch_repository.delete(
            db,
            branch,
        )


branch_service = BranchService()