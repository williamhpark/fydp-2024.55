import uuid
from typing import AsyncGenerator

from fastapi.params import Depends
from fastapi_users import FastAPIUsers
from fastapi_users_db_sqlalchemy import SQLAlchemyUserDatabase
from sqlalchemy.ext.asyncio import AsyncSession

from .auth import jwt_bearer_backend
from .database import async_session_maker
from .managers import UserManager
from .models.users import User


async def get_async_session() -> AsyncGenerator[AsyncSession, None]:
    async with async_session_maker() as session:
        yield session


async def get_user_db(
    session: AsyncSession = Depends(get_async_session),
) -> AsyncGenerator[SQLAlchemyUserDatabase[AsyncSession, User], None]:
    yield SQLAlchemyUserDatabase(session, User)


async def get_user_manager(user_db=Depends(get_user_db)):
    yield UserManager(user_db)


fastapi_users = FastAPIUsers[User, uuid.UUID](
    get_user_manager=get_user_manager, auth_backends=[jwt_bearer_backend]
)

get_current_active_user = fastapi_users.current_user(active=True)
