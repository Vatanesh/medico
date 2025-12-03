# MediNote Backend API

Production-grade Node.js backend for the MediNote medical transcription application.

## Features

- ✅ JWT Authentication
- ✅ Patient Management
- ✅ Recording Session Management
- ✅ Real-time Audio Chunk Upload with Presigned URLs
- ✅ MongoDB Data Persistence
- ✅ Template System
- ✅ Docker Deployment

## Quick Start

### Prerequisites

- Node.js 18+
- MongoDB 6+
- Docker & Docker Compose (for containerized deployment)

### Development Setup

1. **Install dependencies:**
```bash
npm install
```

2. **Configure environment:**
```bash
cp .env.example .env
# Edit .env with your configuration
```

3. **Start MongoDB** (if not using Docker):
```bash
# Install and start MongoDB locally
```

4. **Run development server:**
```bash
npm run dev
```

Server will start on `http://localhost:3000`

### Docker Deployment (ONE COMMAND!)

```bash
docker-compose up
```

This will:
- Start MongoDB with persistent storage
- Build and start the backend API
- Configure networking between services

## API Endpoints

### Authentication
- `POST /auth/register` - Register new user
- `POST /auth/login` - Login user
- `GET /users/asd3fd2faec?email={email}` - Get user ID by email

### Patient Management
- `GET /v1/patients?userId={userId}` - List all patients
- `POST /v1/add-patient-ext` - Add new patient
- `GET /v1/patient-details/{patientId}` - Get patient details

### Session Management
- `POST /v1/upload-session` - Create recording session
- `POST /v1/get-presigned-url` - Get presigned URL for chunk upload
- `POST /v1/notify-chunk-uploaded` - Notify chunk uploaded
- `GET /v1/fetch-session-by-patient/{patientId}` - Get patient sessions
- `GET /v1/all-session?userId={userId}` - Get all user sessions

### Template Management
- `GET /v1/fetch-default-template-ext?userId={userId}` - Get templates

### Storage
- `PUT /v1/storage/upload/{uploadToken}` - Upload audio chunk
- `GET /v1/storage/public/{sessionId}/{filename}` - Get public audio file

## Authentication

All `/v1/*` endpoints require JWT Bearer token:

```
Authorization: Bearer <your_jwt_token>
```

## Environment Variables

```env
PORT=3000
MONGODB_URI=mongodb://mongodb:27017/medinote
JWT_SECRET=your-secret-key
JWT_EXPIRES_IN=7d
STORAGE_PATH=./uploads
ALLOWED_ORIGINS=*
```

## Tech Stack

- **Framework:** Express.js
- **Database:** MongoDB + Mongoose
- **Authentication:** JWT
- **File Upload:** Multer
- **Storage:** Local filesystem (simulating GCS)

## Project Structure

```
backend/
├── src/
│   ├── controllers/       # Request handlers
│   ├── middleware/        # Auth, error handling
│   ├── models/           # MongoDB schemas
│   ├── services/         # Business logic
│   └── server.js         # Express app setup
├── uploads/              # Audio file storage
├── Dockerfile
├── docker-compose.yml
└── package.json
```

## License

MIT
