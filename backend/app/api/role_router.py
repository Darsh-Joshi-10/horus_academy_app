from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user
from app.db.session import get_db
from app.models.role import Role
from app.schemas.auth import UserResponse
from app.schemas.role import RoleResponse

router = APIRouter(
    prefix="/roles",
    tags=["Roles"],
)


@router.get(
    "",
    response_model=list[RoleResponse],
)
async def get_all_roles(
    db: AsyncSession = Depends(get_db),
    current_user: UserResponse = Depends(get_current_user),
):
    result = await db.execute(
        select(Role).where(Role.is_active.is_(True)).order_by(Role.id.asc())
    )
    roles = result.scalars().all()
    return roles
