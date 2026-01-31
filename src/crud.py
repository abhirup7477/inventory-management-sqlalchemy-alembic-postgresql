# crud.py
from sqlalchemy import select
from models import Products, Categories
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import Session
from database import engine
from decimal import Decimal

def fetch_all_products():
    session = Session(bind=engine)
    products = session.execute(select(Products)).scalars().all()
    print(f"{"id":^40}{"product_name":^15}{"category_id":^40}{"quantity":^15}  {"cost":<10}")
    print("-"*120)
    for prod in products:
        print(f"{str(prod.id):^40}{prod.product_name:^15}{str(prod.category_id):^40}{prod.quantity:^15}{prod.cost:^10}")
    session.close()

def bulk_update(category_name: str):
    try:
        session = Session(bind=engine)
        with session.begin():
            stmt = (
                select(Products)
                .join(Categories, Products.category_id == Categories.id)
                .where(Categories.name == category_name)
            )
            results = session.execute(stmt).scalars().all()
            for prod in results:
                prod.cost *= Decimal(1.1)
        print("Transaction successful!")
    except SQLAlchemyError as e:
        print(e._message)
        print("Transaction blocked: Rollback to previos save state")
    finally:
        session.close()
    

fetch_all_products()
print()
print()
bulk_update("Electronics")