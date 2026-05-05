const express = require('express');
const router = express.Router();
const messagesController = require('../controllers/messagesController');
const { protect } = require('../middleware/authMiddleware');

router.get('/conversation/:userId', protect, messagesController.getConversation);
router.post('/', protect, messagesController.sendMessage);
router.put('/:messageId/read', protect, messagesController.markAsRead);

module.exports = router;