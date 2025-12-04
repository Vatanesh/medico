const Session = require('../models/Session');
const Patient = require('../models/Patient');
const storageService = require('../services/storageService');

class SessionController {
    /**
     * Create a new recording session
     * POST /v1/upload-session
     */
    async createSession(req, res, next) {
        try {
            const { patientId, userId, patientName, status, startTime, templateId } = req.body;

            if (!patientId || !userId || !patientName) {
                return res.status(400).json({
                    error: 'Missing required fields',
                    details: 'patientId, userId, and patientName are required'
                });
            }

            const session = new Session({
                user_id: userId,
                patient_id: patientId,
                patientName,
                status: status || 'recording',
                start_time: startTime ? new Date(startTime) : new Date(),
                templateId: templateId || null,
                chunks: [],
                totalChunks: 0,
                isComplete: false
            });

            await session.save();

            res.status(201).json({
                id: session._id
            });
        } catch (error) {
            next(error);
        }
    }

    /**
     * Get presigned URL for chunk upload
     * POST /v1/get-presigned-url
     */
    async getPresignedUrl(req, res, next) {
        try {
            const { sessionId, chunkNumber, mimeType } = req.body;

            if (!sessionId || chunkNumber === undefined) {
                return res.status(400).json({
                    error: 'Missing required fields',
                    details: 'sessionId and chunkNumber are required'
                });
            }

            // Verify session exists
            const session = await Session.findById(sessionId);
            if (!session) {
                return res.status(404).json({
                    error: 'Session not found',
                    details: 'No session found with this ID'
                });
            }

            // Generate presigned URL
            const { url, gcsPath, publicUrl } = storageService.generatePresignedUrl(
                sessionId,
                chunkNumber,
                mimeType || 'audio/wav'
            );

            res.json({
                url,
                gcsPath,
                publicUrl
            });
        } catch (error) {
            next(error);
        }
    }

    /**
     * Notify that a chunk has been uploaded
     * POST /v1/notify-chunk-uploaded
     */
    async notifyChunkUploaded(req, res, next) {
        try {
            const {
                sessionId,
                gcsPath,
                chunkNumber,
                isLast,
                totalChunksClient,
                publicUrl,
                mimeType,
                selectedTemplate,
                selectedTemplateId,
                model
            } = req.body;

            if (!sessionId || !gcsPath || chunkNumber === undefined) {
                return res.status(400).json({
                    error: 'Missing required fields',
                    details: 'sessionId, gcsPath, and chunkNumber are required'
                });
            }

            // Find and update session
            const session = await Session.findById(sessionId);
            if (!session) {
                return res.status(404).json({
                    error: 'Session not found',
                    details: 'No session found with this ID'
                });
            }

            // Add chunk info
            session.chunks.push({
                chunkNumber,
                gcsPath,
                publicUrl: publicUrl || null,
                mimeType: mimeType || 'audio/wav',
                uploadedAt: new Date(),
                size: 0 // Will be calculated if needed
            });

            session.totalChunks = Math.max(session.totalChunks, chunkNumber + 1);

            // Update session if this is the last chunk
            if (isLast) {
                session.isComplete = true;
                session.status = 'processing';
                session.end_time = new Date();

                // Calculate duration
                const durationMs = session.end_time - session.start_time;
                const durationMinutes = Math.floor(durationMs / 1000 / 60);
                const durationSeconds = Math.floor((durationMs / 1000) % 60);
                session.duration = `${durationMinutes}:${durationSeconds.toString().padStart(2, '0')}`;

                // Update template if provided
                if (selectedTemplateId) {
                    session.templateId = selectedTemplateId;
                    session.session_title = selectedTemplate || 'Medical Consultation';
                }

                // In a real implementation, trigger transcription processing here
                // For now, just set it to completed after a delay
                const sessionIdForUpdate = sessionId;
                setTimeout(async () => {
                    try {
                        // Fetch fresh session from database
                        const sessionToUpdate = await Session.findById(sessionIdForUpdate);
                        if (sessionToUpdate) {
                            sessionToUpdate.status = 'completed';
                            sessionToUpdate.transcript_status = 'completed';
                            sessionToUpdate.transcript = `[Simulated transcript for session ${sessionIdForUpdate}]`;
                            await sessionToUpdate.save();
                            console.log(`[STATUS UPDATE] Session ${sessionIdForUpdate} status updated to completed`);
                        }
                    } catch (err) {
                        console.error('Error updating session:', err);
                    }
                }, 2000);
            }

            await session.save();

            res.json({});
        } catch (error) {
            next(error);
        }
    }

    /**
     * Get all sessions for a patient
     * GET /v1/fetch-session-by-patient/{patientId}
     */
    async getSessionsByPatient(req, res, next) {
        try {
            const { patientId } = req.params;

            const sessions = await Session.find({ patient_id: patientId })
                .sort({ start_time: -1 });

            res.json({
                sessions: sessions.map(s => ({
                    id: s._id,
                    user_id: s.user_id,
                    patient_id: s.patient_id,
                    patientName: s.patientName,
                    date: s.date,
                    session_title: s.session_title,
                    session_summary: s.session_summary,
                    start_time: s.start_time,
                    end_time: s.end_time,
                    duration: s.duration,
                    status: s.status,
                    transcript_status: s.transcript_status,
                    transcript: s.transcript,
                    chunks: s.chunks,
                    totalChunks: s.totalChunks,
                    isComplete: s.isComplete,
                    templateId: s.templateId
                }))
            });
        } catch (error) {
            next(error);
        }
    }

    /**
     * Get all sessions for a user with patient details
     * GET /v1/all-session?userId={userId}
     */
    async getAllSessions(req, res, next) {
        try {
            const { userId } = req.query;

            if (!userId) {
                return res.status(400).json({
                    error: 'Missing userId parameter',
                    details: 'userId query parameter is required'
                });
            }

            // Get all sessions for user
            const sessions = await Session.find({ user_id: userId })
                .populate('patient_id')
                .sort({ start_time: -1 });

            // Build patient map
            const patientMap = {};
            sessions.forEach(session => {
                if (session.patient_id) {
                    patientMap[session.patient_id._id] = {
                        name: session.patient_id.name,
                        pronouns: session.patient_id.pronouns
                    };
                }
            });

            // Format sessions with patient details
            const formattedSessions = sessions.map(s => ({
                id: s._id,
                user_id: s.user_id,
                patient_id: s.patient_id?._id,
                session_title: s.session_title,
                session_summary: s.session_summary,
                transcript_status: s.transcript_status,
                transcript: s.transcript,
                status: s.status,
                date: s.date,
                start_time: s.start_time,
                end_time: s.end_time,
                patient_name: s.patient_id?.name,
                pronouns: s.patient_id?.pronouns,
                email: s.patient_id?.email,
                background: s.patient_id?.background,
                duration: s.duration,
                medical_history: s.patient_id?.medical_history,
                family_history: s.patient_id?.family_history,
                social_history: s.patient_id?.social_history,
                previous_treatment: s.patient_id?.previous_treatment,
                patient_pronouns: s.patient_id?.pronouns,
                clinical_notes: s.clinical_notes || []
            }));

            res.json({
                sessions: formattedSessions,
                patientMap
            });
        } catch (error) {
            next(error);
        }
    }
}

module.exports = new SessionController();
