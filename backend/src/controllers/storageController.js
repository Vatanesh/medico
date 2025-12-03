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

            const data = await storageService.getChunk(sessionId, filename);

            // Set appropriate content type
            const ext = filename.split('.').pop();
            const contentTypes = {
                'wav': 'audio/wav',
                'mp3': 'audio/mpeg',
                'm4a': 'audio/mp4',
                'aac': 'audio/aac'
            };

            res.set('Content-Type', contentTypes[ext] || 'audio/wav');
            res.send(data);
        } catch (error) {
            next(error);
        }
    }
}

module.exports = new StorageController();
