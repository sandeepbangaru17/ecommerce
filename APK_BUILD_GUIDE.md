# Building Customer App as APK

The admin portal is web-only (for store management), so only the **customer app** needs an APK.

---

## Prerequisites

You need these installed:

1. **Android Studio** — download from developer.android.com/studio
2. **Android SDK** — installed automatically with Android Studio
3. **Java JDK 17** — comes with Android Studio
4. **Flutter** — already installed

Run this to check everything is ready:
```bash
flutter doctor
```
All items should show a green checkmark. Fix any that don't before proceeding.

---

## Step 1 — Build the APK

```bash
cd frontend/customer_app

flutter build apk --dart-define=API_URL=https://gromuse-backend.onrender.com
```

For a smaller APK split by CPU architecture (recommended):
```bash
flutter build apk --split-per-abi --dart-define=API_URL=https://gromuse-backend.onrender.com
```

---

## Step 2 — Find the APK

After build completes, the APK is at:
```
frontend/customer_app/build/app/outputs/flutter-apk/app-release.apk
```

Or if split per ABI:
```
build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk   ← older devices
build/app/outputs/flutter-apk/app-arm64-v8a-release.apk     ← most modern phones
build/app/outputs/flutter-apk/app-x86_64-release.apk        ← emulators
```

For sharing/installing on most modern Android phones, use **`app-arm64-v8a-release.apk`**.

---

## Step 3 — Install on a device (optional)

Connect your Android phone via USB and run:
```bash
flutter install
```

Or simply copy the APK file to your phone and open it to install.
> Enable "Install from unknown sources" in phone settings first.

---

## Notes

- This is a **debug-signed** APK — fine for testing and sharing directly
- For **Google Play Store** upload, you need to create a keystore and sign it with `--release`
