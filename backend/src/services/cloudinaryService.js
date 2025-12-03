const cloudinary = require('cloudinary').v2;

class CloudinaryService {
    constructor() {
        // Initialize Cloudinary with credentials from environment
        const config = {
            cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
            api_key: process.env.CLOUDINARY_API_KEY,
            api_secret: process.env.CLOUDINARY_API_SECRET
        };

        cloudinary.config(config);

        console.log('☁️  Cloudinary initialized:');
        console.log('   Cloud name:', config.cloud_name);
        console.log('   API key:', config.api_key ? '***' + config.api_key.slice(-4) : 'NOT SET');
    }

    /**
     * Upload audio chunk to Cloudinary
     * @param {Buffer} buffer - Audio file buffer
     * @param {string} sessionId - Session ID
     * @param {number} chunkNumber - Chunk number
     * @param {string} mimeType - MIME type of audio
     * @returns {Promise<Object>} Upload result with URL
     */
    async uploadChunk(buffer, sessionId, chunkNumber, mimeType = 'audio/wav') {
        try {
            const ext = this.getExtension(mimeType);
            const publicId = `medico/sessions/${sessionId}/chunk_${chunkNumber}`;

            // Convert buffer to base64 for upload
            const base64Buffer = `data:${mimeType};base64,${buffer.toString('base64')}`;

            // Upload to Cloudinary
            const result = await cloudinary.uploader.upload(base64Buffer, {
                public_id: publicId,
                resource_type: 'video', // Use 'video' for audio to enable streaming
                folder: 'medico/sessions',
                format: ext,
                overwrite: true
            });

            return {
                publicUrl: result.secure_url,
                gcsPath: `sessions/${sessionId}/chunk_${chunkNumber}.${ext}`,
                cloudinaryId: result.public_id,
                size: buffer.length
            };
        } catch (error) {
            console.error('Cloudinary upload error:', error);
            throw new Error(`Failed to upload to Cloudinary: ${error.message}`);
        }
    }

    /**
     * Get audio chunk URL from Cloudinary
     * @param {string} sessionId - Session ID
     * @param {string} filename - Filename
     * @returns {string} Public URL
     */
    getChunkUrl(sessionId, filename) {
        const publicId = `medico/sessions/${sessionId}/${filename.replace(/\.\w+$/, '')}`;
        return cloudinary.url(publicId, {
            resource_type: 'video', // Use 'video' for audio streaming
            secure: true
        });
    }

    /**
     * Delete session files from Cloudinary
     * @param {string} sessionId - Session ID
     */
    async deleteSession(sessionId) {
        try {
            const prefix = `medico/sessions/${sessionId}`;
            await cloudinary.api.delete_resources_by_prefix(prefix, {
                resource_type: 'video' // Use 'video' for audio files
            });
            console.log(`Deleted Cloudinary resources for session: ${sessionId}`);
        } catch (error) {
            console.error('Failed to delete session from Cloudinary:', error);
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

module.exports = new CloudinaryService();
