from fastapi import APIRouter, HTTPException, status, Depends, Query
from typing import List, Optional
from app.schemas.order import (
    OrderCreate,
    OrderUpdateStatus,
    OrderResponse,
    OrderListResponse,
    OrderStatus,
    ORDER_STATUS_FLOW,
)
from app.schemas.user import TokenData
from app.services.auth import get_current_user, get_current_admin
from app.services.database import db_service, DatabaseService

router = APIRouter(prefix="/orders", tags=["Orders"])


def enrich_order_items(items: List[dict], db: DatabaseService) -> List[dict]:
    enriched_items = []
    for item in items:
        enriched_item = dict(item)
        product = db.service_get_by_id("products", item["product_id"])
        enriched_item["product_name"] = product.get("name") if product else None
        enriched_item["product_image_url"] = product.get("image_url") if product else None
        enriched_items.append(enriched_item)
    return enriched_items



@router.post("", response_model=OrderResponse, status_code=status.HTTP_201_CREATED)
async def create_order(
    order_data: OrderCreate,
    current_user: TokenData = Depends(get_current_user),
    db: DatabaseService = Depends(lambda: db_service),
):
    if not order_data.items:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Order must have at least one item",
        )

    for item in order_data.items:
        product = db.service_get_by_id("products", item.product_id)
        if not product:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Product {item.product_id} not found",
            )
        if not product.get("is_active", True):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Product {item.product_id} not available",
            )
        if product.get("stock", 0) < item.quantity:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Insufficient stock for product {product['name']}",
            )

    total = sum(item.unit_price * item.quantity for item in order_data.items)

    order_record = {
        "user_id": current_user.user_id,
        "shipping_address": order_data.shipping_address,
        "contact_phone": order_data.contact_phone,
        "notes": order_data.notes,
        "status": OrderStatus.PENDING.value,
        "total_amount": total,
    }

    try:
        order = db.service_insert("orders", order_record)
        order_id = order["id"]

        for item in order_data.items:
            item_record = {
                "order_id": order_id,
                "product_id": item.product_id,
                "quantity": item.quantity,
                "unit_price": item.unit_price,
            }
            db.service_insert("order_items", item_record)

            product = db.service_get_by_id("products", item.product_id)
            if product:
                new_stock = product["stock"] - item.quantity
                db.service_update("products", item.product_id, {"stock": new_stock})

        items_result = db.service_select("order_items", filters={"order_id": order_id})
        order["items"] = enrich_order_items(items_result, db)

        return order

    except Exception as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.get("", response_model=List[OrderListResponse])
async def list_orders(
    status_filter: Optional[str] = None,
    limit: int = Query(default=50, le=100),
    offset: int = Query(default=0),
    current_user: TokenData = Depends(get_current_user),
    db: DatabaseService = Depends(lambda: db_service),
):
    filters = {}
    if current_user.role != "admin":
        filters["user_id"] = current_user.user_id
    if status_filter:
        filters["status"] = status_filter

    orders = db.service_select(
        "orders", filters=filters, order="created_at", limit=limit, offset=offset
    )

    result = []
    for order in orders:
        items_count = len(
            db.service_select("order_items", filters={"order_id": order["id"]})
        )
        result.append(
            {
                "id": order["id"],
                "user_id": order["user_id"],
                "status": order["status"],
                "total_amount": order["total_amount"],
                "created_at": order["created_at"],
                "item_count": items_count,
            }
        )

    return result


@router.get("/{order_id}", response_model=OrderResponse)
async def get_order(
    order_id: str,
    current_user: TokenData = Depends(get_current_user),
    db: DatabaseService = Depends(lambda: db_service),
):
    order = db.service_get_by_id("orders", order_id)

    if not order:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Order not found"
        )

    if current_user.role != "admin" and order["user_id"] != current_user.user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized to view this order",
        )

    items = db.service_select("order_items", filters={"order_id": order_id})
    order["items"] = enrich_order_items(items, db)

    return order


@router.put("/{order_id}/status", response_model=OrderResponse)
async def update_order_status(
    order_id: str,
    status_update: OrderUpdateStatus,
    current_user: TokenData = Depends(get_current_admin),
    db: DatabaseService = Depends(lambda: db_service),
):
    order = db.service_get_by_id("orders", order_id)
    if not order:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Order not found"
        )

    current_status = OrderStatus(order["status"])
    new_status = status_update.status

    if new_status not in ORDER_STATUS_FLOW.get(current_status, []):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Cannot change status from {current_status.value} to {new_status.value}",
        )

    try:
        updated_order = db.service_update(
            "orders", order_id, {"status": new_status.value}
        )
        items = db.service_select("order_items", filters={"order_id": order_id})
        updated_order["items"] = enrich_order_items(items, db)

        if new_status == OrderStatus.CANCELLED:
            for item in items:
                product = db.service_get_by_id("products", item["product_id"])
                if product:
                    new_stock = product["stock"] + item["quantity"]
                    db.service_update(
                        "products", item["product_id"], {"stock": new_stock}
                    )

        return updated_order

    except Exception as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
