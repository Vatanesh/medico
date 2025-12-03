const storageService = require('../services/storageService');

class StorageController {
    /**
     * Handle chunk upload to presigned URL
     * PUT /v1/storage/upload/{uploadToken}
     */
    async uploadChunk(req, res, next) {
        try {
            const { uploadToken } = req.params;

            // Validate presigned URL
            const urlInfo = storageService.validatePresignedUrl(uploadToken);

            // Get raw buffer from request
            const chunks = [];
            req.on('data', chunk => chunks.push(chunk));
            req.on('end', async () => {
                try {
                    const buffer = Buffer.concat(chunks);

                    // Upload chunk
                    await storageService.uploadChunk(uploadToken, buffer);

                    res.status(200).send();
                } catch (error) {
                    next(error);
                }
            });
        } catch (error) {
            next(error);
        }
    }

    /**
     * Serve public audio files
     * GET /v1/storage/public/{sessionId}/{filename}
     */
    async getPublicFile(req, res, next) {
        try {
            const { sessionId, filename } = req.params;

            const result = await storageService.getChunk(sessionId, filename);

            // If using Cloudinary, redirect to Cloudinary URL
            if (result.isCloudinary) {
                return res.redirect(result.url);
            }

            // Serve local file
            const ext = filename.split('.').pop();
            const contentTypes = {
                'wav': 'audio/wav',
                'mp3': 'audio/mpeg',
                'm4a': 'audio/mp4',
                'aac': 'audio/aac'
            };

            // Set CORS headers for audio playback
            res.set('Access-Control-Allow-Origin', '*');
            res.set('Access-Control-Allow-Methods', 'GET');
            res.set('Content-Type', contentTypes[ext] || 'audio/wav');
            res.set('Accept-Ranges', 'bytes');

            res.send(result.data);
        } catch (error) {
            console.error(`Error serving file ${req.params.filename}:`, error.message);
            res.status(404).json({
                error: 'File not found',
                details: error.message
            });
        }
    }
}

module.exports = new StorageController();
