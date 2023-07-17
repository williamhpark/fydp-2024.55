from fastapi import APIRouter

from ..auth import jwt_bearer_backend
from ..dependencies import fastapi_users
from ..schemas.users import UserCreate, UserRead

router = APIRouter()

router.include_router(
    fastapi_users.get_auth_router(jwt_bearer_backend, requires_verification=False),
    prefix="/jwt",
)

router.include_router(
    fastapi_users.get_register_router(
        user_schema=UserRead, user_create_schema=UserCreate
    ),
)

router.include_router(
    fastapi_users.get_verify_router(user_schema=UserRead),
)

router.include_router(
    fastapi_users.get_reset_password_router(),
)
