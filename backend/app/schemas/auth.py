from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict, EmailStr, field_validator


# -----------------------------
# Register
# -----------------------------

class RegisterRequest(BaseModel):

    first_name: str
    last_name: str
    email: EmailStr
    phone: str
    password: str

    branch_id: UUID | None = None

    @field_validator("branch_id", mode="before")
    @classmethod
    def normalize_branch_id(cls, value):
        if value is None:
            return None

        if isinstance(value, str) and value.strip() == "":
            return None

        return value


class ApproveUserRequest(BaseModel):

    role_id: int | None = None


# -----------------------------
# Login
# -----------------------------

class LoginRequest(BaseModel):

    email: EmailStr
    password: str


# -----------------------------
# User Response
# -----------------------------

class UserResponse(BaseModel):

    model_config = ConfigDict(from_attributes=True)

    id: UUID

    first_name: str
    last_name: str

    email: str
    phone: str

    role_id: int
    branch_id: UUID | None

    status: str

    email_verified: bool
    phone_verified: bool
    is_active: bool

    approved_by: UUID | None = None
    approved_at: datetime | None = None
    created_at: datetime | None = None
    updated_at: datetime | None = None


# -----------------------------
# Login Response
# -----------------------------

class LoginResponse(BaseModel):

    access_token: str
    token_type: str

    user: UserResponse