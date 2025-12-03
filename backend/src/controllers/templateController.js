const Template = require('../models/Template');

class TemplateController {
    /**
     * Get default templates for a user
     * GET /v1/fetch-default-template-ext?userId={userId}
     */
    async getDefaultTemplates(req, res, next) {
        try {
            const { userId } = req.query;

            if (!userId) {
                return res.status(400).json({
                    error: 'Missing userId parameter',
                    details: 'userId query parameter is required'
                });
            }

            // Get user-specific templates and default templates
            const templates = await Template.find({
                $or: [
                    { user_id: userId },
                    { type: 'default' },
                    { type: 'predefined' }
                ]
            }).sort({ type: 1, title: 1 });

            res.json({
                success: true,
                data: templates.map(t => ({
                    id: t._id,
                    title: t.title,
                    type: t.type
                }))
            });
        } catch (error) {
            next(error);
        }
    }

    /**
     * Seed default templates (utility function)
     */
    async seedDefaultTemplates() {
        try {
            const existingTemplates = await Template.countDocuments({ type: 'default' });

            if (existingTemplates === 0) {
                const defaultTemplates = [
                    {
                        title: 'New Patient Visit',
                        type: 'default',
                        content: 'Template for new patient consultations'
                    },
                    {
                        title: 'Follow-up Visit',
                        type: 'predefined',
                        content: 'Template for follow-up appointments'
                    },
                    {
                        title: 'Annual Physical',
                        type: 'predefined',
                        content: 'Template for annual physical examinations'
                    },
                    {
                        title: 'Specialist Referral',
                        type: 'predefined',
                        content: 'Template for specialist referrals'
                    }
                ];

                await Template.insertMany(defaultTemplates);
                console.log('Default templates seeded successfully');
            }
        } catch (error) {
            console.error('Error seeding templates:', error);
        }
    }
}

module.exports = new TemplateController();
