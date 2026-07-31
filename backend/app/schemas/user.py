from datetime import datetime

from pydantic import BaseModel, EmailStr


class RoleResponse(BaseModel):
    id: int
    name: str


class UserResponse(BaseModel):
    id: str
    first_name: str
    last_name: str
    email: EmailStr
    phone: str

    status: str

    role: RoleResponse

    approved_at: datetime | None = None


class ApproveUserRequest(BaseModel):
    role_id: int