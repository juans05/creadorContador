const express = require('express');
const router = express.Router();
const influencerController = require('../controllers/influencerController');
const { protect, optionalAuth } = require('../middleware/authMiddleware');

router.post('/register', protect, influencerController.register);
router.get('/dashboard/stats', protect, influencerController.getDashboardStats);
router.get('/:username/grid', optionalAuth, influencerController.getGrid);
router.get('/:username', optionalAuth, influencerController.getProfile);

module.exports = router;
