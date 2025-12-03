const Patient = require('../models/Patient');
const Session = require('../models/Session');

class PatientController {
    /**
     * Get all patients for a user
     * GET /v1/patients?userId={userId}
     */
    async getPatients(req, res, next) {
        try {
            const { userId } = req.query;

            if (!userId) {
                return res.status(400).json({
                    error: 'Missing userId parameter',
                    details: 'userId query parameter is required'
                });
            }

            const patients = await Patient.find({ user_id: userId })
                .select('_id name')
                .sort({ createdAt: -1 });

            res.json({
                patients: patients.map(p => ({
                    id: p._id,
                    name: p.name
                }))
            });
        } catch (error) {
            next(error);
        }
    }

    /**
     * Add a new patient
     * POST /v1/add-patient-ext
     */
    async addPatient(req, res, next) {
        try {
            const { name, userId, email, pronouns, background, medical_history, family_history, social_history, previous_treatment } = req.body;

            if (!name || !userId) {
                return res.status(400).json({
                    error: 'Missing required fields',
                    details: 'name and userId are required'
                });
            }

            const patient = new Patient({
                name,
                user_id: userId,
                email: email || null,
                pronouns: pronouns || null,
                background: background || null,
                medical_history: medical_history || null,
                family_history: family_history || null,
                social_history: social_history || null,
                previous_treatment: previous_treatment || null
            });

            await patient.save();

            res.status(201).json({
                patient: {
                    id: patient._id,
                    name: patient.name,
                    user_id: patient.user_id,
                    pronouns: patient.pronouns,
                    email: patient.email,
                    background: patient.background,
                    medical_history: patient.medical_history,
                    family_history: patient.family_history,
                    social_history: patient.social_history,
                    previous_treatment: patient.previous_treatment
                }
            });
        } catch (error) {
            next(error);
        }
    }

    /**
     * Get patient details
     * GET /v1/patient-details/{patientId}
     */
    async getPatientDetails(req, res, next) {
        try {
            const { patientId } = req.params;

            const patient = await Patient.findById(patientId);

            if (!patient) {
                return res.status(404).json({
                    error: 'Patient not found',
                    details: 'No patient found with this ID'
                });
            }

            res.json({
                id: patient._id,
                name: patient.name,
                pronouns: patient.pronouns,
                email: patient.email,
                background: patient.background,
                medical_history: patient.medical_history,
                family_history: patient.family_history,
                social_history: patient.social_history,
                previous_treatment: patient.previous_treatment
            });
        } catch (error) {
            next(error);
        }
    }
}

module.exports = new PatientController();
