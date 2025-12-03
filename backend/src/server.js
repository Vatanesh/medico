require('dotenv').config();
const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const mongoose = require('mongoose');

const authController = require('./controllers/authController');
const patientController = require('./controllers/patientController');
const sessionController = require('./controllers/sessionController');
const storageController = require('./controllers/storageController');
const templateController = require('./controllers/templateController');
const authMiddleware = require('./middleware/auth');
const errorHandler = require('./middleware/errorHandler');
const storageService = require('./services/storageService');

const http = require('http');
const { Server } = require('socket.io');
const { spawn } = require('child_process');

const app = express();
const httpServer = http.createServer(app);
const io = new Server(httpServer, {
    cors: {
        origin: "*", // Allow all origins for dev
        methods: ["GET", "POST"]
    }
});

const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors({
    origin: process.env.ALLOWED_ORIGINS === '*' ? '*' : process.env.ALLOWED_ORIGINS.split(','),
    credentials: true
}));

app.use(morgan('dev'));

// Socket.IO Logic for Transcription
// Socket.IO Logic (Placeholder for future real-time features)
io.on('connection', (socket) => {
    console.log(`🔌 Client connected: ${socket.id}`);

    socket.on('disconnect', () => {
        console.log(`🔌 Client disconnected: ${socket.id}`);
    });
});

// JSON body parser for most routes (except file uploads)
app.use((req, res, next) => {
    if (req.path.startsWith('/v1/storage/upload/')) {
        // Skip JSON parsing for binary uploads
        next();
    } else {
        express.json()(req, res, next);
    }
});

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// ==================== PUBLIC ROUTES (No Auth) ====================

// Authentication
app.post('/auth/register', authController.register.bind(authController));
app.post('/auth/login', authController.login.bind(authController));

// User lookup by email (backend endpoint)
app.get('/users/asd3fd2faec', authController.getUserByEmail.bind(authController));

// Storage - Public file access
app.get('/v1/storage/public/:sessionId/:filename', storageController.getPublicFile.bind(storageController));

// Storage - Presigned URL upload (uses token auth, not JWT)
app.put('/v1/storage/upload/:uploadToken', storageController.uploadChunk.bind(storageController));

// ==================== PROTECTED ROUTES (Require Auth) ====================
// Apply auth middleware to all /v1/* routes except storage
app.use('/v1', (req, res, next) => {
    if (req.path.startsWith('/storage/')) {
        next();
    } else {
        authMiddleware(req, res, next);
    }
});

// Patient Management
app.get('/v1/patients', patientController.getPatients.bind(patientController));
app.post('/v1/add-patient-ext', patientController.addPatient.bind(patientController));
app.get('/v1/patient-details/:patientId', patientController.getPatientDetails.bind(patientController));

// Session Management
app.post('/v1/upload-session', sessionController.createSession.bind(sessionController));
app.post('/v1/get-presigned-url', sessionController.getPresignedUrl.bind(sessionController));
app.post('/v1/notify-chunk-uploaded', sessionController.notifyChunkUploaded.bind(sessionController));
app.get('/v1/fetch-session-by-patient/:patientId', sessionController.getSessionsByPatient.bind(sessionController));
app.get('/v1/all-session', sessionController.getAllSessions.bind(sessionController));

// Template Management
app.get('/v1/fetch-default-template-ext', templateController.getDefaultTemplates.bind(templateController));

// 404 handler
app.use('*', (req, res) => {
    res.status(404).json({
        error: 'Not Found',
        details: `Endpoint ${req.method} ${req.originalUrl} not found`
    });
});

// Error handler (must be last)
app.use(errorHandler);

// Database connection and server startup
async function start() {
    try {
        // Initialize storage service
        await storageService.initialize();

        // Connect to MongoDB
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('✅ Connected to MongoDB');

        // Seed default templates
        await templateController.seedDefaultTemplates();

        // Start server
        httpServer.listen(PORT, () => {
            console.log(`🚀 MediNote API Server running on port ${PORT}`);
            console.log(`📊 Environment: ${process.env.NODE_ENV}`);
            console.log(`🗄️  Database: ${process.env.MONGODB_URI}`);
            console.log(`📁 Storage: ${process.env.STORAGE_PATH}`);
            console.log(`🔌 Socket.IO: Enabled`);
            console.log(`\n📚 API Endpoints:`);
            console.log(`   POST  /auth/register`);
            console.log(`   POST  /auth/login`);
            console.log(`   GET   /users/asd3fd2faec?email={email}`);
            console.log(`   GET   /v1/patients?userId={userId}`);
            console.log(`   POST  /v1/add-patient-ext`);
            console.log(`   GET   /v1/patient-details/:patientId`);
            console.log(`   POST  /v1/upload-session`);
            console.log(`   POST  /v1/get-presigned-url`);
            console.log(`   POST  /v1/notify-chunk-uploaded`);
            console.log(`   GET   /v1/fetch-session-by-patient/:patientId`);
            console.log(`   GET   /v1/all-session?userId={userId}`);
            console.log(`   GET   /v1/fetch-default-template-ext?userId={userId}`);
            console.log(`\n🎯 Ready to accept requests!`);
        });
    } catch (error) {
        console.error('❌ Failed to start server:', error);
        process.exit(1);
    }
}

start();

module.exports = app;
