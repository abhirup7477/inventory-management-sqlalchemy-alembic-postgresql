from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship
from sqlalchemy import ForeignKey, Text, INTEGER, DECIMAL, TIMESTAMP, CheckConstraint, func, text
from typing import List
from uuid import UUID
from decimal import Decimal
from sqlalchemy.dialects.postgresql import UUID as PG_UUID
from datetime import datetime

class Base(DeclarativeBase):
    pass

class Categories(Base):
    __tablename__ = "categories"

    id: Mapped[UUID] = mapped_column(PG_UUID(as_uuid=True), primary_key=True, server_default=func.gen_random_uuid())
    name: Mapped[str] = mapped_column(Text, unique=True, nullable=False)

    products: Mapped[List["Products"]] = relationship(back_populates="category", cascade="all, delete-orphan")

class Products(Base):
    __tablename__ = "products"

    id: Mapped[UUID] = mapped_column(PG_UUID(as_uuid=True), primary_key=True, server_default=func.gen_random_uuid())
    product_name: Mapped[str] = mapped_column(Text, nullable=False)
    category_id: Mapped[UUID] = mapped_column(ForeignKey("categories.id", ondelete="CASCADE"))
    cost: Mapped[Decimal] = mapped_column(DECIMAL(10, 2), nullable=False)
    quantity: Mapped[int] = mapped_column(INTEGER, nullable=False)
    status: Mapped[str] = mapped_column(Text, server_default=text("In stock"))
    description: Mapped[str] = mapped_column(Text, nullable=True)

    category: Mapped[Categories] = relationship(back_populates="products")
    orders: Mapped[List["Orders"]] = relationship(back_populates="products", cascade="all, delete-orphan")

    __table_args__ = (
        CheckConstraint(
            sqltext="quantity >= 0",
            name = "quantity_check_constraint"
        ),
    )

class Orders(Base):
    __tablename__ = "orders"

    order_id: Mapped[UUID] = mapped_column(PG_UUID(as_uuid=True), primary_key=True, server_default=func.gen_random_uuid())
    prod_id: Mapped[UUID] = mapped_column(ForeignKey("products.id", ondelete="CASCADE"))
    quantity: Mapped[int] = mapped_column(INTEGER, nullable=False, server_default=text("1"))
    order_date: Mapped[datetime] = mapped_column(TIMESTAMP, server_default=func.now())

    products: Mapped[Products] = relationship(back_populates="orders")
