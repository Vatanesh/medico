const mongoose = require('mongoose');

const sessionSchema = new mongoose.Schema({
    user_id: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    patient_id: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Patient',
        required: true
    },
    patientName: {
        type: String,
        required: true
    },
    session_title: {
        type: String,
        default: 'Medical Consultation'
    },
    session_summary: {
        type: String,
        default: null
    },
    status: {
        type: String,
        enum: ['recording', 'processing', 'completed', 'failed'],
        default: 'recording'
    },
    transcript_status: {
        type: String,
        enum: ['pending', 'processing', 'completed', 'failed'],
        default: 'pending'
    },
    transcript: {
        type: String,
        default: null
    },
    start_time: {
        type: Date,
        required: true
    },
    end_time: {
        type: Date,
        default: null
    },
    date: {
        type: String,
        default: function () {
            return this.start_time ? this.start_time.toISOString().split('T')[0] : new Date().toISOString().split('T')[0];
        }
    },
    duration: {
        type: String,
        default: null
    },
    templateId: {
        type: String,
        default: null
    },
    chunks: [{
        chunkNumber: Number,
        gcsPath: String,
        publicUrl: String,
        mimeType: String,
        uploadedAt: Date,
        size: Number
    }],
    totalChunks: {
        type: Number,
        default: 0
    },
    isComplete: {
        type: Boolean,
        default: false
    },
    clinical_notes: {
        type: Array,
        default: []
    },
    createdAt: {
        type: Date,
        default: Date.now
    },
    updatedAt: {
        type: Date,
        default: Date.now
    }
});

// Update the updatedAt timestamp before saving
sessionSchema.pre('save', function (next) {
    this.updatedAt = new Date();
    next();
});

module.exports = mongoose.model('Session', sessionSchema);
