from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.branch import Branch
from app.schemas.branch import BranchCreate, BranchUpdate


class BranchRepository:

    async def create(
        self,
        db: AsyncSession,
        branch_data: BranchCreate,
    ) -> Branch:

        branch = Branch(**branch_data.model_dump())

        db.add(branch)

        await db.commit()
        await db.refresh(branch)

        return branch

    async def get_all(
        self,
        db: AsyncSession,
    ) -> list[Branch]:

        result = await db.execute(select(Branch))

        return result.scalars().all()

    async def get_by_id(
        self,
        db: AsyncSession,
        branch_id: UUID,
    ) -> Branch | None:

        result = await db.execute(
            select(Branch).where(Branch.id == branch_id)
        )

        return result.scalar_one_or_none()

    async def get_by_branch_code(
        self,
        db: AsyncSession,
        branch_code: str,
    ) -> Branch | None:

        result = await db.execute(
            select(Branch).where(
                Branch.branch_code == branch_code
            )
        )

        return result.scalar_one_or_none()

    async def update(
        self,
        db: AsyncSession,
        branch: Branch,
        branch_data: BranchUpdate,
    ) -> Branch:

        update_data = branch_data.model_dump(exclude_unset=True)

        for key, value in update_data.items():
            setattr(branch, key, value)

        await db.commit()
        await db.refresh(branch)

        return branch

    async def delete(
        self,
        db: AsyncSession,
        branch: Branch,
    ) -> None:

        await db.delete(branch)
        await db.commit()


branch_repository = BranchRepository()