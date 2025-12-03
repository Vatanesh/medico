const mongoose = require('mongoose');

const templateSchema = new mongoose.Schema({
    user_id: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        default: null
    },
    title: {
        type: String,
        required: true
    },
    type: {
        type: String,
        enum: ['default', 'predefined', 'custom'],
        default: 'predefined'
    },
    content: {
        type: String,
        default: null
    },
    createdAt: {
        type: Date,
        default: Date.now
    }
});

module.exports = mongoose.model('Template', templateSchema);
