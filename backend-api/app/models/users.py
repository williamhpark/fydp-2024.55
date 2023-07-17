from fastapi_users.db import SQLAlchemyBaseUserTableUUID

from ..database import Base


class User(SQLAlchemyBaseUserTableUUID, Base):
    pass
