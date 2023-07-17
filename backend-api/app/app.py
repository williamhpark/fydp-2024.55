from fastapi import FastAPI

from .dependencies import create_db_and_tables
from .routes import auth, users

app = FastAPI()

app.include_router(
    auth.router,
    prefix="/auth",
    tags=["auth"],
)

app.include_router(
    users.router,
    prefix="/users",
    tags=["users"],
)


@app.on_event("startup")
async def startup():
    await create_db_and_tables()
