from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict, EmailStr


class BranchBase(BaseModel):
    branch_code: str
    name: str
    address: str
    city: str
    state: str
    phone: str | None = None
    email: EmailStr | None = None


class BranchCreate(BranchBase):
    pass


class BranchUpdate(BaseModel):
    branch_code: str | None = None
    name: str | None = None
    address: str | None = None
    city: str | None = None
    state: str | None = None
    phone: str | None = None
    email: EmailStr | None = None
    is_active: bool | None = None


class BranchResponse(BranchBase):
    id: UUID
    is_active: bool
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)