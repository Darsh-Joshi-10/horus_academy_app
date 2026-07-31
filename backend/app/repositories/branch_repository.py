from uuid import UUID

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.branch import Branch
from app.models.user import User
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
        is_active: bool | None = None,
    ) -> list[Branch]:

        query = select(Branch)

        if is_active is not None:
            query = query.where(Branch.is_active == is_active)

        result = await db.execute(query.order_by(Branch.name))

        return result.scalars().all()

    async def count_users(
        self,
        db: AsyncSession,
        branch_id: UUID,
    ) -> int:

        result = await db.execute(
            select(func.count())
            .select_from(User)
            .where(User.branch_id == branch_id)
        )

        return result.scalar_one()

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