# Backend API

## How to setup

1. Install python 3.11.
2. Run `python -m venv env` to create a virtual environment.
3. Run `source ./env/Scripts/activate` to active the virtual environment.
4. Run `pip install -r requirements.txt` to install packages.
5. Run `alembic upgrade head` to migrate revisions to the database.

## How to run

1. Run `python main.py` to run the server with auto-reloading.
2. Go to [127.0.0.1:8000/docs]() for the Swagger UI page.
3. Make API calls within the page.

## How to manage migrations

1. Import all model classes into alembic/env.py with `from app.models.<file> import *`
2. Run `alembic revision --autogenerate -m "<revision message>"` to create a new revision.
3. Run `alembic current` to get the current revision.
4. Run `alembic history --verbose` to get the revision history.
5. Run `alembic upgrade <revision id | +<number of steps>>` to move forward in the revision history.
6. Run `alembic downgrade <revision id | -<number of steps>>` to move backward in the revision history.

## How to test

## How to deploy
