<div align="center">

<img src="https://img.shields.io/badge/Gromuse-Grocery%20Delivery-2E7D32?style=for-the-badge&logoColor=white" alt="Gromuse" />

# Gromuse — Grocery Delivery Platform

A full-stack grocery delivery application with a customer-facing shopping app, a dedicated admin portal, and a production-ready REST API.

[![Python](https://img.shields.io/badge/Python-3.11+-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://python.org)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.109+-009688?style=for-the-badge&logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com)
[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Supabase](https://img.shields.io/badge/Supabase-PostgreSQL-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.com)

</div>

---

## Live Deployments

| App | URL | Description |
|---|---|---|
| Customer App | [gromuse-customer.vercel.app](https://gromuse-customer.vercel.app) | Shopping app for customers |
| Admin Portal | [web-six-mauve-jq4hzgblkq.vercel.app](https://web-six-mauve-jq4hzgblkq.vercel.app) | Store management dashboard |
| Backend API | [gromuse-backend.onrender.com/docs](https://gromuse-backend.onrender.com/docs) | Interactive API docs |

---

## Overview

Gromuse is a production-deployed grocery delivery platform. Customers can browse products, add to cart, and place orders with cash-on-delivery. Store admins manage the product catalog and update order statuses through a dedicated portal.

---

## Features

**Customer App**
- Browse products by category with real product images
- Search and filter by category
- Add to cart, adjust quantities, checkout with address + phone
- View full order history with status tracking
- Cash on delivery with free delivery above ₹499

**Admin Portal**
- Secure admin login
- Add, edit, hide/show products with image URL support
- View and manage all customer orders
- Update order status (Pending → Confirmed → Shipped → Delivered)

**Backend API**
- FastAPI with async endpoints
- JWT authentication (custom, not Supabase Auth)
- Supabase PostgreSQL database with Row Level Security
- Role-based access control (user / admin)
- Full order lifecycle management

---

## Tech Stack

| Layer | Technology |
|---|---|
| Backend | FastAPI, Python 3.11, Uvicorn |
| Database | Supabase (PostgreSQL) |
| Auth | Custom JWT via python-jose + Supabase Auth |
| Customer App | Flutter (Web + Android) |
| Admin Portal | Flutter Web |
| Hosting | Render (API), Vercel (Flutter Web) |

---

## Project Structure

```
ecommerce/
├── backend/
│   ├── app/
│   │   ├── api/            # Route handlers (auth, products, orders)
│   │   ├── core/           # Config, Supabase client
│   │   ├── schemas/        # Pydantic models
│   │   └── services/       # Auth logic, database service
│   ├── Procfile            # Render/Railway deployment
│   ├── runtime.txt         # Python version pin
│   └── requirements.txt
├── frontend/
│   ├── customer_app/       # Flutter customer shopping app
│   └── admin_portal/       # Flutter admin dashboard
└── README.md
```

---

## API Reference

Full interactive docs available at [`/docs`](https://gromuse-backend.onrender.com/docs).

| Endpoint | Method | Auth | Description |
|---|---|---|---|
| `/health` | GET | — | Health check |
| `/auth/signup` | POST | — | Register new customer |
| `/auth/login` | POST | — | Login, returns JWT |
| `/auth/me` | GET | User | Get current user info |
| `/products` | GET | — | List products (filterable) |
| `/products/{id}` | GET | — | Get single product |
| `/products` | POST | Admin | Create product |
| `/products/{id}` | PUT | Admin | Update product |
| `/products/{id}` | DELETE | Admin | Delete product |
| `/orders` | POST | User | Place order |
| `/orders` | GET | User | Get my orders |
| `/orders/{id}` | GET | User | Get order detail |
| `/orders/{id}/status` | PUT | Admin | Update order status |

---

## Order Lifecycle

```
Pending → Confirmed → Shipped → Delivered
    └──────────────────────────→ Cancelled
```

---

## Local Development

### Prerequisites
- Python 3.11+
- Flutter SDK
- Supabase project

### Backend

```bash
cd backend
python -m venv venv
venv\Scripts\activate        # Windows
pip install -r requirements.txt
copy .env.example .env       # Fill in your Supabase credentials
uvicorn app.main:app --reload --port 8000
```

`.env` variables required:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-anon-key
SUPABASE_SERVICE_KEY=your-service-role-key
JWT_SECRET=your-long-random-secret
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=60
ALLOWED_ORIGINS=*
```

### Flutter Apps

```bash
# Customer App
cd frontend/customer_app
flutter pub get
flutter run -d chrome --dart-define=API_URL=http://localhost:8000

# Admin Portal
cd frontend/admin_portal
flutter pub get
flutter run -d chrome --dart-define=API_URL=http://localhost:8000
```

---

## Deployment

### Backend → Render
- Root Directory: `backend`
- Build Command: `pip install -r requirements.txt`
- Start Command: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
- Add all `.env` variables in Render's Environment tab

### Flutter Web → Vercel

```bash
flutter build web --dart-define=API_URL=https://your-backend.onrender.com
cd build/web
vercel --prod
```

### Android APK

```bash
cd frontend/customer_app
flutter build apk --split-per-abi --dart-define=API_URL=https://your-backend.onrender.com
# Output: build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

---

## Troubleshooting

<details>
<summary>Users can't register — "email rate limit exceeded"</summary>

Go to **Supabase → Authentication → Providers → Email** and disable **"Confirm email"**. The free tier limits confirmation emails to 3/hour.
</details>

<details>
<summary>Backend cold start delay on first request</summary>

Render's free tier spins down after 15 minutes of inactivity. The first request after idle takes ~30 seconds to wake up. This is expected on the free plan.
</details>

<details>
<summary>Flutter app shows wrong API URL</summary>

The API URL is baked in at build time via `--dart-define=API_URL=...`. Rebuild and redeploy both Flutter apps whenever the backend URL changes.
</details>

<details>
<summary>Admin can't see all products</summary>

The admin portal calls `/products` with no filter so all products (including hidden ones) are visible. The customer app calls `/products?is_active=true` to show only active products.
</details>

---

<div align="center">
  <sub>Built with FastAPI · Flutter · Supabase</sub>
</div>
