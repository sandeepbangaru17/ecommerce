from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime
from enum import Enum


class OrderStatus(str, Enum):
    PENDING = "pending"
    CONFIRMED = "confirmed"
    SHIPPED = "shipped"
    DELIVERED = "delivered"
    CANCELLED = "cancelled"


ORDER_STATUS_FLOW = {
    OrderStatus.PENDING: [OrderStatus.CONFIRMED, OrderStatus.CANCELLED],
    OrderStatus.CONFIRMED: [OrderStatus.SHIPPED, OrderStatus.CANCELLED],
    OrderStatus.SHIPPED: [OrderStatus.DELIVERED, OrderStatus.CANCELLED],
    OrderStatus.DELIVERED: [],
    OrderStatus.CANCELLED: [],
}


class OrderItemBase(BaseModel):
    product_id: str
    quantity: int = Field(..., gt=0)
    unit_price: float = Field(..., gt=0)


class OrderItemCreate(OrderItemBase):
    pass


class OrderItemResponse(OrderItemBase):
    id: str
    order_id: str
    product_name: Optional[str] = None
    product_image_url: Optional[str] = None
    created_at: datetime


class OrderBase(BaseModel):
    shipping_address: str = Field(..., min_length=1)
    contact_phone: str = Field(..., min_length=5)
    notes: Optional[str] = None


class OrderCreate(OrderBase):
    items: List[OrderItemCreate] = Field(..., min_length=1)


class OrderUpdateStatus(BaseModel):
    status: OrderStatus


class OrderInDB(BaseModel):
    id: str
    user_id: str
    status: OrderStatus
    total_amount: float
    created_at: datetime
    updated_at: Optional[datetime] = None


class OrderResponse(OrderInDB):
    items: List[OrderItemResponse] = []


class OrderListResponse(BaseModel):
    id: str
    user_id: str
    status: OrderStatus
    total_amount: float
    created_at: datetime
    item_count: int
