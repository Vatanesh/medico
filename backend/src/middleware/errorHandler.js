const errorHandler = (err, req, res, next) => {
    console.error('Error:', err);

    // Default error response
    const error = {
        error: err.message || 'Internal server error',
        details: err.details || err.stack
    };

    // Mongoose validation error
    if (err.name === 'ValidationError') {
        return res.status(400).json({
            error: 'Validation failed',
            details: Object.values(err.errors).map(e => e.message).join(', ')
        });
    }

    // Mongoose duplicate key error
    if (err.code === 11000) {
        return res.status(400).json({
            error: 'Duplicate entry',
            details: 'A record with this value already exists'
        });
    }

    // Custom error with status code
    if (err.statusCode) {
        return res.status(err.statusCode).json(error);
    }

    // Default 500 error
    res.status(500).json(error);
};

module.exports = errorHandler;
