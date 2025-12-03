const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');

class AuthController {
    /**
     * Register a new user
     */
    async register(req, res, next) {
        try {
            const { email, password, name } = req.body;

            if (!email || !password || !name) {
                return res.status(400).json({
                    error: 'Missing required fields',
                    details: 'Email, password, and name are required'
                });
            }

            // Check if user already exists
            const existingUser = await User.findOne({ email });
            if (existingUser) {
                return res.status(400).json({
                    error: 'User already exists',
                    details: 'An account with this email already exists'
                });
            }

            // Hash password
            const hashedPassword = await bcrypt.hash(password, 10);

            // Create user
            const user = new User({
                email,
                password: hashedPassword,
                name
            });

            await user.save();

            // Generate token
            const token = jwt.sign(
                { userId: user._id, email: user.email },
                process.env.JWT_SECRET,
                { expiresIn: process.env.JWT_EXPIRES_IN }
            );

            res.status(201).json({
                token,
                user: {
                    id: user._id,
                    email: user.email,
                    name: user.name
                }
            });
        } catch (error) {
            next(error);
        }
    }

    /**
     * Login user
     */
    async login(req, res, next) {
        try {
            const { email, password } = req.body;

            if (!email || !password) {
                return res.status(400).json({
                    error: 'Missing required fields',
                    details: 'Email and password are required'
                });
            }

            // Find user
            const user = await User.findOne({ email });
            if (!user) {
                return res.status(401).json({
                    error: 'Invalid credentials',
                    details: 'Email or password is incorrect'
                });
            }

            // Check password
            const isValidPassword = await bcrypt.compare(password, user.password);
            if (!isValidPassword) {
                return res.status(401).json({
                    error: 'Invalid credentials',
                    details: 'Email or password is incorrect'
                });
            }

            // Generate token
            const token = jwt.sign(
                { userId: user._id, email: user.email },
                process.env.JWT_SECRET,
                { expiresIn: process.env.JWT_EXPIRES_IN }
            );

            res.json({
                token,
                user: {
                    id: user._id,
                    email: user.email,
                    name: user.name
                }
            });
        } catch (error) {
            next(error);
        }
    }

    /**
     * Get user by email (backend endpoint for email -> ID mapping)
     * GET /users/asd3fd2faec?email=test@example.com
     */
    async getUserByEmail(req, res, next) {
        try {
            const { email } = req.query;

            if (!email) {
                return res.status(400).json({
                    error: 'Missing email parameter',
                    details: 'Email query parameter is required'
                });
            }

            const user = await User.findOne({ email });

            if (!user) {
                return res.status(404).json({
                    error: 'User not found',
                    details: 'No user found with this email'
                });
            }

            res.json({
                id: user._id
            });
        } catch (error) {
            next(error);
        }
    }
}

module.exports = new AuthController();
