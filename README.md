# Medico - Medical Transcription App

**Production-Grade Flutter + Node.js Application**

## 🔗 Quick Links

| Resource | Link |
|----------|------|
| 📱 **Android APK** | [Download from GitHub Releases](https://github.com/Vatanesh/medico/releases/download/demo/app-release.apk) |
| 🎥 **iOS Loom Video** | [Watch Feature Walkthrough](https://www.loom.com/YOUR_VIDEO_LINK) |
| 📚 **API Documentation** | [View API Docs](https://drive.google.com/file/d/1d4Y4bbCVqfuqiHQVxA-2nZytBk3x0wua/view?usp=sharing) |
| 🔧 **Postman Collection** | [View Postman Collection](https://drive.google.com/file/d/13H5GPdzgAHpR_9sluQxNTnUnuYu5rg02/view?usp=sharing) |
| 🚀 **Backend URL** | `https://medico-zbsf.onrender.com` (Live) |

---

## 🛠️ Tech Stack & Version

-   **Flutter:** `3.32.5` (Stable)
-   **Dart:** `3.8.1`
-   **Backend:** Node.js + Express + MongoDB + Socket.IO
-   **Architecture:** Provider (Flutter) / MVC (Backend)

---

## 🚀 Quick Start

### 1. Backend Setup (One-Command)
Run the entire backend stack (API + Database) with Docker (from the project root):
```bash
docker-compose up --build
```
*Server runs on port 3000.*

### 2. Mobile App Setup
```bash
# Get dependencies
flutter pub get

# Generate localization files
flutter gen-l10n

# Run the app
flutter run
```

*Note: Ensure `lib/core/constants/api_endpoints.dart` points to your backend IP.*

---

## 📱 Features

### ✅ Implemented (100%)

**Native & Core**
- 🎤 **Real-time Audio Streaming:** 15-second chunking with parallel uploads.
- 🔄 **Offline Resilience:** Queues uploads when offline and auto-retries.
- 🛡️ **Interruption Handling:** Auto-pauses on phone calls (Native Android Receiver).
- 🔊 **Background Recording:** Continues recording when app is minimized (Foreground Service).

**UI & UX**
- 🎨 **Material Design 3:** Fully adaptive UI with light/dark modes.
- 🌈 **Dynamic Colors:** "Material You" support (adapts to wallpaper).
- 🌊 **Visualizer:** Custom real-time audio waveform.
- 🌍 **Localization:** English & Hindi support.

**Backend**
- 🔐 **Security:** JWT Authentication.
- 📦 **Storage:** Presigned URL workflow for secure file uploads.
- 🐳 **Docker:** Full containerization for easy deployment.

---

## 🏗️ Architecture

### Backend Stack
- **Framework:** Express.js
- **Database:** MongoDB + Mongoose
- **Auth:** JWT Bearer tokens
- **Storage:** Local filesystem (simulating Cloud Storage)
- **Deployment:** Docker + Docker Compose

### Flutter Stack
- **State:** Provider
- **HTTP:** Dio + HTTP
- **Audio:** `record` package (Raw Stream)
- **Storage:** Hive (Offline Queue) + SharedPreferences
- **Localization:** flutter_localizations

---

## 🎯 API Endpoints

### Authentication
```
POST /auth/register
POST /auth/login
GET  /users/asd3fd2faec?email={email}
```

### Patients
```
GET  /v1/patients?userId={userId}
POST /v1/add-patient-ext
GET  /v1/patient-details/{patientId}
```

### Recording Sessions
```
POST /v1/upload-session
POST /v1/get-presigned-url
PUT  /v1/storage/upload/{token}
POST /v1/notify-chunk-uploaded
GET  /v1/fetch-session-by-patient/{patientId}
GET  /v1/all-session?userId={userId}
```

---

## 🔐 Environment Variables

**Backend (`docker-compose.yml`):**
```yaml
environment:
  - MONGODB_URI=mongodb://mongodb:27017/medinote
  - JWT_SECRET=your_secret_key
  - BASE_URL=http://YOUR_IP:3000
```

---

## 👤 Author

**Built for Attack Capital Mobile Engineering Challenge**

**Status:** Production-Ready MVP
