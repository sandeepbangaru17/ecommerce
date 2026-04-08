from fastapi import APIRouter, HTTPException, status, Depends, Query
from typing import List, Optional
from datetime import datetime
from app.schemas.product import ProductCreate, ProductUpdate, ProductResponse
from app.schemas.user import TokenData
from app.services.auth import get_current_user, get_current_admin
from app.services.database import db_service, DatabaseService
from app.core.supabase import get_supabase_service_client

router = APIRouter(prefix="/products", tags=["Products"])


@router.get("", response_model=List[ProductResponse])
async def list_products(
    category: Optional[str] = None,
    is_active: Optional[bool] = None,
    limit: int = Query(default=50, le=100),
    offset: int = Query(default=0),
    db: DatabaseService = Depends(lambda: db_service),
):
    products = db.supabase.table("products").select("*")

    if is_active is not None:
        products = products.eq("is_active", is_active)

    if category:
        products = products.eq("category", category)

    products = products.range(offset, offset + limit - 1)
    result = products.execute()

    return result.data or []


@router.get("/{product_id}", response_model=ProductResponse)
async def get_product(
    product_id: str, db: DatabaseService = Depends(lambda: db_service)
):
    try:
        result = (
            db.supabase.table("products").select("*").eq("id", product_id).execute()
        )

        if not result.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND, detail="Product not found"
            )

        product = result.data[0]
        if not product.get("is_active", True):
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND, detail="Product not found"
            )

        return product
    except HTTPException:
        raise
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Product not found"
        )


@router.post("", response_model=ProductResponse, status_code=status.HTTP_201_CREATED)
async def create_product(
    product_data: ProductCreate,
    current_admin: TokenData = Depends(get_current_admin),
    db: DatabaseService = Depends(lambda: db_service),
):
    product_dict = product_data.model_dump()
    product_dict["created_by"] = current_admin.user_id

    product = db.service_insert("products", product_dict)
    return product


@router.put("/{product_id}", response_model=ProductResponse)
async def update_product(
    product_id: str,
    product_data: ProductUpdate,
    current_admin: TokenData = Depends(get_current_admin),
    db: DatabaseService = Depends(lambda: db_service),
):
    result = db.supabase.table("products").select("*").eq("id", product_id).execute()
    if not result.data:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Product not found"
        )

    update_dict = {k: v for k, v in product_data.model_dump().items() if v is not None}
    update_dict["updated_at"] = datetime.utcnow().isoformat()

    product = db.service_update("products", product_id, update_dict)
    return product


@router.delete("/{product_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_product(
    product_id: str,
    current_admin: TokenData = Depends(get_current_admin),
    db: DatabaseService = Depends(lambda: db_service),
):
    result = db.supabase.table("products").select("*").eq("id", product_id).execute()
    if not result.data:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Product not found"
        )

    db.service_delete("products", product_id)
