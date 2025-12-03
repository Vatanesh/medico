const mongoose = require('mongoose');

const patientSchema = new mongoose.Schema({
    name: {
        type: String,
        required: true
    },
    user_id: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    pronouns: {
        type: String,
        default: null
    },
    email: {
        type: String,
        default: null
    },
    background: {
        type: String,
        default: null
    },
    medical_history: {
        type: String,
        default: null
    },
    family_history: {
        type: String,
        default: null
    },
    social_history: {
        type: String,
        default: null
    },
    previous_treatment: {
        type: String,
        default: null
    },
    photoUrl: {
        type: String,
        default: null
    },
    createdAt: {
        type: Date,
        default: Date.now
    }
});

module.exports = mongoose.model('Patient', patientSchema);
