from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.database import engine, Base
from app.routes import products, sales

# Initialize FastAPI app
app = FastAPI(title="Smart POS Backend")

# Create database tables
Base.metadata.create_all(bind=engine)

# Allow frontend requests (Flutter)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # you can later restrict this to ["http://localhost:3000"] or device IP
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Root route
@app.get("/")
def read_root():
    return {"message": "Smart POS Backend is running 🚀"}

# Register routes
app.include_router(products.router, prefix="/products", tags=["Products"])
app.include_router(sales.router, prefix="/sales", tags=["Sales"])
