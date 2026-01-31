# load_env.py
from dotenv import load_dotenv
import os

load_dotenv()

driver = os.getenv("DB_DRIVER")
user = os.getenv("DB_USER")
password = os.getenv("DB_PASSWORD")
server = os.getenv("DB_SERVER")
port = os.getenv("DB_PORT")
db_name = os.getenv("DB_NAME")

db_url = f"{driver}://{user}:{password}@{server}/{db_name}"