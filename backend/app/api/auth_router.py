from fastapi import APIRouter, Depends, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user
from app.db.session import get_db
from app.schemas.auth import (
    LoginRequest,
    LoginResponse,
    RegisterRequest,
    UserResponse,
    build_user_response,
)
from app.services.auth_service import AuthService

router = APIRouter()


@router.post(
    "/register",
    response_model=UserResponse,
    status_code=status.HTTP_201_CREATED,
)
async def register(
    request: RegisterRequest,
    db: AsyncSession = Depends(get_db),
):

    user = await AuthService.register(
        db=db,
        request=request,
    )

    return build_user_response(user)


@router.post(
    "/login",
    response_model=LoginResponse,
)
async def login(
    request: LoginRequest,
    db: AsyncSession = Depends(get_db),
):

    result = await AuthService.login(
        db=db,
        request=request,
    )

    return {
        "access_token": result["access_token"],
        "token_type": result["token_type"],
        "user": build_user_response(result["user"]),
    }


@router.get(
    "/me",
    response_model=UserResponse,
)
async def get_me(
    current_user: UserResponse = Depends(get_current_user),
):

    return current_user