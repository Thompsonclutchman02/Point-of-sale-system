from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import SessionLocal
from app import models, schemas
from typing import List
from reportlab.lib.pagesizes import A4
from reportlab.pdfgen import canvas
import os, random

router = APIRouter()
TAX_RATE = 0.16  # 16% VAT

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# -----------------
# Helper: Generate PDF Receipt
# -----------------
def generate_receipt_pdf(sale: models.Sale):
    folder = "receipts"
    os.makedirs(folder, exist_ok=True)

    file_path = os.path.join(folder, f"receipt_{sale.id}.pdf")
    c = canvas.Canvas(file_path, pagesize=A4)
    width, height = A4

    y = height - 50
    c.setFont("Helvetica-Bold", 16)
    c.drawString(200, y, "Cartgo POS Receipt")
    y -= 30

    c.setFont("Helvetica", 10)
    c.drawString(50, y, f"Sale ID: {sale.id}")
    y -= 15
    c.drawString(50, y, f"Date: {sale.created_at.strftime('%Y-%m-%d %H:%M:%S')}")
    y -= 30

    # Table header
    c.setFont("Helvetica-Bold", 10)
    c.drawString(50, y, "Product")
    c.drawString(200, y, "Qty")
    c.drawString(250, y, "Price")
    c.drawString(320, y, "Subtotal")
    y -= 20

    c.setFont("Helvetica", 10)
    for item in sale.items:
        c.drawString(50, y, item.product.name)
        c.drawString(200, y, str(item.quantity))
        c.drawString(250, y, f"{item.price:.2f}")
        c.drawString(320, y, f"{item.subtotal:.2f}")
        y -= 20

    y -= 20
    c.setFont("Helvetica-Bold", 12)
    c.drawString(250, y, f"Subtotal: {sale.total_before_tax:.2f}")
    y -= 20
    c.drawString(250, y, f"Tax (16%): {sale.tax_amount:.2f}")
    y -= 20
    c.drawString(250, y, f"Total: {sale.total_amount:.2f}")

    c.save()
    return file_path

# -----------------
# Checkout - Create Sale
# -----------------
@router.post("/checkout", response_model=schemas.SaleResponse)
def checkout(sale_data: schemas.SaleCreate, db: Session = Depends(get_db)):
    if not sale_data.items or len(sale_data.items) == 0:
        raise HTTPException(status_code=400, detail="Cart is empty")

    sale_items = []
    total_before_tax = 0.0

    for item in sale_data.items:
        product = db.query(models.Product).filter(models.Product.id == item.product_id).first()
        if not product:
            raise HTTPException(status_code=404, detail=f"Product ID {item.product_id} not found")

        if product.stock_quantity < item.quantity:
            raise HTTPException(status_code=400, detail=f"Insufficient stock for {product.name}")

        used_price = item.price if item.price is not None else product.price

        if product.discount_allowed == 1 and item.discount_rate > 0:
            discount = used_price * item.quantity * item.discount_rate
        else:
            discount = 0.0

        subtotal = (used_price * item.quantity) - discount
        total_before_tax += subtotal
        product.stock_quantity -= item.quantity

        sale_item = models.SaleItem(
            product_id=product.id,
            quantity=item.quantity,
            price=used_price,
            subtotal=subtotal
        )
        sale_items.append(sale_item)

    tax_amount = total_before_tax * TAX_RATE
    total_amount = total_before_tax + tax_amount

    sale = models.Sale(
        total_before_tax=total_before_tax,
        tax_amount=tax_amount,
        total_amount=total_amount,
        items=sale_items
    )

    db.add(sale)
    db.commit()
    db.refresh(sale)

    # Generate receipt PDF
    generate_receipt_pdf(sale)

    return sale

# -----------------
# Get all sales
# -----------------
@router.get("/", response_model=List[schemas.SaleResponse])
def get_sales(db: Session = Depends(get_db)):
    return db.query(models.Sale).all()

# -----------------
# Get a single sale (receipt)
# -----------------
@router.get("/{sale_id}", response_model=schemas.SaleResponse)
def get_sale(sale_id: int, db: Session = Depends(get_db)):
    sale = db.query(models.Sale).filter(models.Sale.id == sale_id).first()
    if not sale:
        raise HTTPException(status_code=404, detail="Sale not found")
    return sale

# -----------------
# Submit Invoice to Mock Tax Authority
# -----------------
@router.post("/{sale_id}/submit_invoice", response_model=schemas.InvoiceSubmissionResponse)
def submit_invoice(sale_id: int, db: Session = Depends(get_db)):
    sale = db.query(models.Sale).filter(models.Sale.id == sale_id).first()
    if not sale:
        raise HTTPException(status_code=404, detail="Sale not found")

    existing = db.query(models.InvoiceSubmission).filter(models.InvoiceSubmission.sale_id == sale_id).first()
    if existing:
        return existing

    status = random.choice(["APPROVED", "REJECTED"])
    authority_ref = f"TAX-{random.randint(10000, 99999)}"

    invoice = models.InvoiceSubmission(
        sale_id=sale_id,
        status=status,
        authority_ref=authority_ref
    )
    db.add(invoice)
    db.commit()
    db.refresh(invoice)

    return invoice

# -----------------
# Get Invoice Status
# -----------------
@router.get("/{sale_id}/invoice_status", response_model=schemas.InvoiceSubmissionResponse)
def get_invoice_status(sale_id: int, db: Session = Depends(get_db)):
    invoice = db.query(models.InvoiceSubmission).filter(models.InvoiceSubmission.sale_id == sale_id).first()
    if not invoice:
        raise HTTPException(status_code=404, detail="Invoice not found for this sale")
    return invoice
