from fastapi import FastAPI, Request, status
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from fastapi.exceptions import RequestValidationError
from app.api import auth, products, orders
from app.core.config import get_settings

settings = get_settings()

_origins = (
    [o.strip() for o in settings.ALLOWED_ORIGINS.split(",")]
    if settings.ALLOWED_ORIGINS != "*"
    else ["*"]
)

app = FastAPI(
    title="Ecommerce API",
    description="Production-ready Ecommerce Backend with Supabase",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=_origins,
    allow_credentials=_origins != ["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    return JSONResponse(
        status_code=status.HTTP_400_BAD_REQUEST,
        content={"detail": "Validation error", "errors": exc.errors()},
    )


@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={"detail": "Internal server error"},
    )


app.include_router(auth.router)
app.include_router(products.router)
app.include_router(orders.router)


@app.get("/health")
async def health_check():
    settings = get_settings()
    return {
        "status": "healthy",
        "supabase_configured": bool(settings.SUPABASE_URL and settings.SUPABASE_KEY),
    }


@app.get("/")
async def root():
    return {"message": "Ecommerce API", "version": "1.0.0"}
