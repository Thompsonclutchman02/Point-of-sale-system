from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from app.database import Base
import datetime

# -----------------
# Product Model
# -----------------
class Product(Base):
    __tablename__ = "products"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False, index=True)
    sku = Column(String, unique=True, index=True)
    price = Column(Float, nullable=False)
    stock_quantity = Column(Integer, default=0)
    discount_allowed = Column(Integer, default=1)  # 1 = true, 0 = false
    expiry_date = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.datetime.utcnow, onupdate=datetime.datetime.utcnow)

# -----------------
# Sale Model
# -----------------
class Sale(Base):
    __tablename__ = "sales"
    id = Column(Integer, primary_key=True, index=True)
    total_before_tax = Column(Float, nullable=False)
    tax_amount = Column(Float, nullable=False)
    total_amount = Column(Float, nullable=False)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

    items = relationship("SaleItem", back_populates="sale", cascade="all, delete-orphan")

# -----------------
# SaleItem Model
# -----------------
class SaleItem(Base):
    __tablename__ = "sale_items"
    id = Column(Integer, primary_key=True, index=True)
    sale_id = Column(Integer, ForeignKey("sales.id"))
    product_id = Column(Integer, ForeignKey("products.id"))
    quantity = Column(Integer, nullable=False)
    price = Column(Float, nullable=False)
    subtotal = Column(Float, nullable=False)

    sale = relationship("Sale", back_populates="items")
    product = relationship("Product")

# -----------------
# Invoice Submission Model
# -----------------
class InvoiceSubmission(Base):
    __tablename__ = "invoice_submissions"
    id = Column(Integer, primary_key=True, index=True)
    sale_id = Column(Integer, ForeignKey("sales.id"))
    status = Column(String, default="PENDING")   # PENDING, APPROVED, REJECTED
    authority_ref = Column(String, nullable=True)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

    sale = relationship("Sale")
