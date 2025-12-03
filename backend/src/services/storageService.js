const fs = require('fs').promises;
const path = require('path');
const crypto = require('crypto');
const { v4: uuidv4 } = require('uuid');
const cloudinaryService = require('./cloudinaryService');

class StorageService {
    constructor() {
        this.storagePath = process.env.STORAGE_PATH || './uploads';
        this.baseUrl = process.env.BASE_URL || 'http://localhost:3000';
        this.presignedUrls = new Map(); // Store presigned URL mappings
        this.useCloudinary = process.env.USE_CLOUDINARY === 'true' || process.env.NODE_ENV === 'production';
    }

    async initialize() {
        // Create storage directory if it doesn't exist
        try {
            await fs.mkdir(this.storagePath, { recursive: true });
            console.log('Storage directory initialized:', this.storagePath);
        } catch (error) {
            console.error('Failed to create storage directory:', error);
        }
    }

    /**
     * Generate a presigned URL for uploading a chunk
     * Simulates GCS presigned URL functionality
     */
    generatePresignedUrl(sessionId, chunkNumber, mimeType = 'audio/wav') {
        // Generate GCS-style path
        const filename = `chunk_${chunkNumber}.${this.getExtension(mimeType)}`;
        const gcsPath = `sessions/${sessionId}/${filename}`;

        // Generate a unique upload token
        const uploadToken = crypto.randomBytes(32).toString('hex');

        // Create presigned URL (our API endpoint with token)
        const presignedUrl = `${this.baseUrl}/v1/storage/upload/${uploadToken}`;

        // Store mapping for validation during upload
        this.presignedUrls.set(uploadToken, {
            sessionId,
            chunkNumber,
            gcsPath,
            mimeType,
            expiresAt: Date.now() + (15 * 60 * 1000) // 15 minutes
        });

        // Generate public URL (for accessing the file later)
        const publicUrl = `${this.baseUrl}/v1/storage/public/${sessionId}/${filename}`;

        return {
            url: presignedUrl,
            gcsPath,
            publicUrl
        };
    }

    /**
     * Validate and retrieve presigned URL info
     */
    validatePresignedUrl(uploadToken) {
        const urlInfo = this.presignedUrls.get(uploadToken);

        if (!urlInfo) {
            throw new Error('Invalid or expired presigned URL');
        }

        if (Date.now() > urlInfo.expiresAt) {
            this.presignedUrls.delete(uploadToken);
            throw new Error('Presigned URL has expired');
        }

        return urlInfo;
    }

    /**
     * Upload chunk using presigned URL
     */
    async uploadChunk(uploadToken, buffer) {
        const urlInfo = this.validatePresignedUrl(uploadToken);

        // Use Cloudinary if enabled
        if (this.useCloudinary) {
            try {
                const result = await cloudinaryService.uploadChunk(
                    buffer,
                    urlInfo.sessionId,
                    urlInfo.chunkNumber,
                    urlInfo.mimeType
                );

                // Clean up used token
                this.presignedUrls.delete(uploadToken);

                return {
                    gcsPath: result.gcsPath,
                    publicUrl: result.publicUrl,
                    size: result.size,
                    mimeType: urlInfo.mimeType
                };
            } catch (error) {
                console.error('Cloudinary upload failed:', error);
                throw error;
            }
        }

        // Fallback to local storage
        const sessionDir = path.join(this.storagePath, 'sessions', urlInfo.sessionId);
        await fs.mkdir(sessionDir, { recursive: true });

        // Save file
        const filePath = path.join(this.storagePath, urlInfo.gcsPath);
        await fs.writeFile(filePath, buffer);

        // Clean up used token
        this.presignedUrls.delete(uploadToken);

        return {
            gcsPath: urlInfo.gcsPath,
            size: buffer.length,
            mimeType: urlInfo.mimeType
        };
    }

    /**
     * Get chunk file for public access
     */
    async getChunk(sessionId, filename) {
        // If using Cloudinary, return URL instead of file data
        if (this.useCloudinary) {
            const url = cloudinaryService.getChunkUrl(sessionId, filename);
            return { url, isCloudinary: true };
        }

        // Local storage fallback
        const filePath = path.join(this.storagePath, 'sessions', sessionId, filename);

        try {
            const data = await fs.readFile(filePath);
            return { data, isCloudinary: false };
        } catch (error) {
            throw new Error('Chunk not found');
        }
    }

    /**
     * Assemble all chunks into a complete audio file
     */
    async assembleChunks(sessionId, chunks) {
        const sessionDir = path.join(this.storagePath, 'sessions', sessionId);
        const outputPath = path.join(sessionDir, 'complete.wav');

        // Sort chunks by chunkNumber
        const sortedChunks = chunks.sort((a, b) => a.chunkNumber - b.chunkNumber);

        // Read and concatenate all chunks
        const buffers = [];
        for (const chunk of sortedChunks) {
            const chunkPath = path.join(this.storagePath, chunk.gcsPath);
            const data = await fs.readFile(chunkPath);
            buffers.push(data);
        }

        const combined = Buffer.concat(buffers);
        await fs.writeFile(outputPath, combined);

        return {
            path: `sessions/${sessionId}/complete.wav`,
            size: combined.length,
            publicUrl: `${this.baseUrl}/v1/storage/public/${sessionId}/complete.wav`
        };
    }

    /**
     * Delete session files
     */
    async deleteSession(sessionId) {
        const sessionDir = path.join(this.storagePath, 'sessions', sessionId);

        try {
            await fs.rm(sessionDir, { recursive: true, force: true });
        } catch (error) {
            console.error('Failed to delete session files:', error);
        }
    }

    /**
     * Get file extension from MIME type
     */
    getExtension(mimeType) {
        const map = {
            'audio/wav': 'wav',
            'audio/wave': 'wav',
            'audio/mpeg': 'mp3',
            'audio/mp3': 'mp3',
            'audio/mp4': 'm4a',
            'audio/x-m4a': 'm4a',
            'audio/aac': 'aac'
        };
        return map[mimeType] || 'wav';
    }
}

module.exports = new StorageService();
