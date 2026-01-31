# database.py
from sqlalchemy import create_engine
from load_env import db_url

# url = "postgresql+psycopg2://inventory_user:sunu@localhost:5432/invebtory_db"
engine = create_engine(db_url)
