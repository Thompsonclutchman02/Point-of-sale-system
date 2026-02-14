from pydantic import BaseModel
from datetime import datetime
from typing import Optional, List

# -----------------
# Product Schemas
# -----------------
class ProductBase(BaseModel):
    name: str = ""
    sku: str = ""
    price: float = 0.0
    stock_quantity: int = 0
    discount_allowed: int = 0
    expiry_date: Optional[datetime] = None  # keep optional

class ProductCreate(ProductBase):
    pass

class ProductResponse(ProductBase):
    id: int = 0
    created_at: datetime = datetime.utcnow()
    updated_at: datetime = datetime.utcnow()

    class Config:
        orm_mode = True

# -----------------
# SaleItem Schemas
# -----------------
class SaleItemBase(BaseModel):
    product_id: int = 0
    quantity: int = 0
    price: float = 0.0
    discount_rate: float = 0.0

class SaleItemResponse(BaseModel):
    id: int = 0
    product_id: int = 0
    quantity: int = 0
    price: float = 0.0
    subtotal: float = 0.0
    product: ProductResponse = ProductResponse()

    class Config:
        orm_mode = True

# -----------------
# Sale Schemas
# -----------------
class SaleCreate(BaseModel):
    items: List[SaleItemBase] = []

class SaleResponse(BaseModel):
    id: int = 0
    created_at: datetime = datetime.utcnow()
    total_before_tax: float = 0.0
    tax_amount: float = 0.0
    total_amount: float = 0.0
    items: List[SaleItemResponse] = []

    class Config:
        orm_mode = True

# -----------------
# Invoice Submission Schemas
# -----------------
class InvoiceSubmissionResponse(BaseModel):
    id: int = 0
    sale_id: int = 0
    status: str = "pending"
    authority_ref: Optional[str] = None
    created_at: datetime = datetime.utcnow()

    class Config:
        orm_mode = True
