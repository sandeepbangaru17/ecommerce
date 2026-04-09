# Deployment Update Guide

This guide explains what to do after making changes to any part of the project.

---

## Project URLs

| App | Platform | URL |
|---|---|---|
| Backend API | Render | `https://gromuse-backend.onrender.com` |
| Customer App | Vercel | `https://gromuse-customer.vercel.app` |
| Admin Portal | Vercel | `https://web-six-mauve-jq4hzgblkq.vercel.app` |

---

## 1. If you change Backend code (FastAPI)

Render is connected to your GitHub `main` branch and **auto-deploys on every push**.

```bash
git add .
git commit -m "your message"
git push origin main
```

Render will automatically detect the push and redeploy. You can monitor the build at:
**render.com → gromuse-backend → Logs**

> Wait 1-2 minutes after push for the redeploy to complete.

---

## 2. If you change Customer App (Flutter)

Vercel is NOT connected to GitHub for Flutter apps. You must rebuild and redeploy manually.

**Step 1 — Make your code changes**

**Step 2 — Rebuild the web app**
```bash
cd frontend/customer_app
flutter build web --dart-define=API_URL=https://gromuse-backend.onrender.com
```

**Step 3 — Redeploy to Vercel**
```bash
cd build/web
vercel --prod
```

Live at: `https://gromuse-customer.vercel.app`

---

## 3. If you change Admin Portal (Flutter)

Same process as the customer app.

**Step 1 — Make your code changes**

**Step 2 — Rebuild the web app**
```bash
cd frontend/admin_portal
flutter build web --dart-define=API_URL=https://gromuse-backend.onrender.com
```

**Step 3 — Redeploy to Vercel**
```bash
cd build/web
vercel --prod
```

Live at: `https://web-six-mauve-jq4hzgblkq.vercel.app`

---

## 4. If you change both Frontend apps at once

Run all steps sequentially:

```bash
# Build and deploy Customer App
cd frontend/customer_app
flutter build web --dart-define=API_URL=https://gromuse-backend.onrender.com
cd build/web
vercel --prod

# Build and deploy Admin Portal
cd "C:\Users\LENOVO\Desktop\task-mtouchlabs\ecommerce\frontend\admin_portal"
flutter build web --dart-define=API_URL=https://gromuse-backend.onrender.com
cd build/web
vercel --prod
```

---

## 5. If you change Backend environment variables

Go to **render.com → gromuse-backend → Environment** → update the variable → click **Save Changes**.

Render redeploys automatically.

---

## 6. If you change the Backend API URL

If your Render URL ever changes, you must rebuild and redeploy **both** Flutter apps with the new URL:

```bash
# Customer App
cd frontend/customer_app
flutter build web --dart-define=API_URL=https://NEW-BACKEND-URL.onrender.com
cd build/web
vercel --prod

# Admin Portal
cd "C:\Users\LENOVO\Desktop\task-mtouchlabs\ecommerce\frontend\admin_portal"
flutter build web --dart-define=API_URL=https://NEW-BACKEND-URL.onrender.com
cd build/web
vercel --prod
```

Also rebuild the APK:
```bash
cd frontend/customer_app
flutter build apk --split-per-abi --dart-define=API_URL=https://NEW-BACKEND-URL.onrender.com
```

---

## 7. If you rebuild the APK

Any time you change customer app code, rebuild the APK too:

```bash
cd frontend/customer_app
flutter build apk --split-per-abi --dart-define=API_URL=https://gromuse-backend.onrender.com
```

APK location:
```
frontend/customer_app/build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

---

## Quick Reference

| Changed | Action needed |
|---|---|
| Backend code | `git push` only — Render auto-deploys |
| Backend env variables | Update in Render dashboard |
| Customer App code | Rebuild + `vercel --prod` from `build/web` |
| Admin Portal code | Rebuild + `vercel --prod` from `build/web` |
| Backend URL changed | Rebuild both Flutter apps + APK with new URL |
| Both apps changed | Rebuild + deploy both separately |
