# Ecommerce API Documentation

## Base URL
```
http://localhost:8000
```

## Status Codes
- `200` - Success
- `201` - Created
- `400` - Bad Request (Validation Error)
- `401` - Unauthorized (Invalid/Missing Token)
- `403` - Forbidden (Insufficient permissions)
- `404` - Not Found
- `500` - Internal Server Error

---

## Authentication Endpoints

### POST /auth/signup
Create new user account.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123",
  "full_name": "John Doe"
}
```

**Response (201):**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "token_type": "bearer"
}
```

**Error Responses:**
- `400` - Email already exists or invalid input

---

### POST /auth/login
Authenticate user and get JWT token.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response (200):**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "token_type": "bearer"
}
```

**Error Responses:**
- `401` - Invalid credentials

---

### GET /auth/me
Get current user info.

**Headers:**
```
Authorization: Bearer <JWT_TOKEN>
```

**Response (200):**
```json
{
  "id": "user-uuid",
  "email": "user@example.com",
  "full_name": "John Doe",
  "created_at": "2024-01-01T00:00:00Z",
  "role": "user"
}
```

**Error Responses:**
- `401` - Invalid or missing token
- `404` - User not found

---

## Product Endpoints

### GET /products
List all active products.

**Query Parameters:**
- `category` (optional) - Filter by category
- `is_active` (optional) - Filter by active status (default: true)
- `limit` (optional) - Max results (default: 50, max: 100)
- `offset` (optional) - Pagination offset (default: 0)

**Response (200):**
```json
[
  {
    "id": "product-uuid",
    "name": "Product Name",
    "description": "Product description",
    "price": 99.99,
    "stock": 100,
    "image_url": "https://...",
    "category": "Electronics",
    "is_active": true,
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z"
  }
]
```

---

### GET /products/{product_id}
Get product details.

**Response (200):**
```json
{
  "id": "product-uuid",
  "name": "Product Name",
  "description": "Product description",
  "price": 99.99,
  "stock": 100,
  "image_url": "https://...",
  "category": "Electronics",
  "is_active": true,
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-01T00:00:00Z"
}
```

**Error Responses:**
- `404` - Product not found

---

### POST /products (Admin Only)
Create new product.

**Headers:**
```
Authorization: Bearer <ADMIN_JWT_TOKEN>
```

**Request Body:**
```json
{
  "name": "New Product",
  "description": "Product description",
  "price": 49.99,
  "stock": 50,
  "image_url": "https://...",
  "category": "Electronics",
  "is_active": true
}
```

**Response (201):**
```json
{
  "id": "product-uuid",
  "name": "New Product",
  ...
}
```

**Error Responses:**
- `401` - Invalid token
- `403` - Admin access required

---

### PUT /products/{product_id} (Admin Only)
Update product.

**Headers:**
```
Authorization: Bearer <ADMIN_JWT_TOKEN>
```

**Request Body:**
```json
{
  "price": 59.99,
  "stock": 75
}
```

**Response (200):** Updated product object

**Error Responses:**
- `401` - Invalid token
- `403` - Admin access required
- `404` - Product not found

---

### DELETE /products/{product_id} (Admin Only)
Delete product.

**Headers:**
```
Authorization: Bearer <ADMIN_JWT_TOKEN>
```

**Response (204):** No content

**Error Responses:**
- `401` - Invalid token
- `403` - Admin access required
- `404` - Product not found

---

## Order Endpoints

### POST /orders
Place new COD order.

**Headers:**
```
Authorization: Bearer <JWT_TOKEN>
```

**Request Body:**
```json
{
  "shipping_address": "123 Main St, City, Country",
  "contact_phone": "+1234567890",
  "notes": "Please deliver in the morning",
  "items": [
    {
      "product_id": "product-uuid",
      "quantity": 2,
      "unit_price": 99.99
    }
  ]
}
```

**Response (201):**
```json
{
  "id": "order-uuid",
  "user_id": "user-uuid",
  "status": "pending",
  "total_amount": 199.98,
  "shipping_address": "123 Main St, City, Country",
  "contact_phone": "+1234567890",
  "notes": "Please deliver in the morning",
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-01T00:00:00Z",
  "items": [
    {
      "id": "item-uuid",
      "order_id": "order-uuid",
      "product_id": "product-uuid",
      "quantity": 2,
      "unit_price": 99.99,
      "created_at": "2024-01-01T00:00:00Z"
    }
  ]
}
```

**Error Responses:**
- `400` - Validation error (empty items, invalid product, insufficient stock)
- `401` - Invalid token

---

### GET /orders
List orders (user sees own, admin sees all).

**Headers:**
```
Authorization: Bearer <JWT_TOKEN>
```

**Query Parameters:**
- `status_filter` (optional) - Filter by status
- `limit` (optional) - Max results (default: 50, max: 100)
- `offset` (optional) - Pagination offset (default: 0)

**Response (200):**
```json
[
  {
    "id": "order-uuid",
    "user_id": "user-uuid",
    "status": "pending",
    "total_amount": 199.98,
    "created_at": "2024-01-01T00:00:00Z",
    "item_count": 2
  }
]
```

---

### GET /orders/{order_id}
Get order details with items.

**Response (200):**
```json
{
  "id": "order-uuid",
  "user_id": "user-uuid",
  "status": "pending",
  "total_amount": 199.98,
  "shipping_address": "123 Main St, City, Country",
  "contact_phone": "+1234567890",
  "notes": "Please deliver in the morning",
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-01T00:00:00Z",
  "items": [...]
}
```

**Error Responses:**
- `401` - Invalid token
- `403` - Not authorized
- `404` - Order not found

---

### PUT /orders/{order_id}/status (Admin Only)
Update order status.

**Headers:**
```
Authorization: Bearer <ADMIN_JWT_TOKEN>
```

**Request Body:**
```json
{
  "status": "confirmed"
}
```

**Status Flow:**
```
pending → confirmed → shipped → delivered
         ↘ (cancelled)
```

**Response (200):** Updated order object

**Error Responses:**
- `400` - Invalid status transition
- `401` - Invalid token
- `403` - Admin access required
- `404` - Order not found

---

## System Endpoints

### GET /health
Health check.

**Response (200):**
```json
{
  "status": "healthy",
  "supabase_configured": true
}
```

---

### GET /
Root endpoint.

**Response (200):**
```json
{
  "message": "Ecommerce API",
  "version": "1.0.0"
}
```