from fastapi import APIRouter

from ..dependencies import fastapi_users
from ..schemas.users import UserRead, UserUpdate

router = APIRouter()

router.include_router(
    fastapi_users.get_users_router(
        user_schema=UserRead, user_update_schema=UserUpdate, requires_verification=False
    ),
)
