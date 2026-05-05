const express = require('express');
const router = express.Router();
const notificationsController = require('../controllers/notificationsController');
const { protect } = require('../middleware/authMiddleware');

router.get('/', protect, notificationsController.getNotifications);
router.get('/unread-count', protect, notificationsController.getUnreadCount);
router.put('/:id/read', protect, notificationsController.markAsRead);
router.put('/read-all', protect, notificationsController.markAllAsRead);

module.exports = router;