const express = require('express');
const router = express.Router();
const subscriptionController = require('../controllers/subscriptionController');
const { protect } = require('../middleware/authMiddleware');

router.post('/', protect, subscriptionController.createSubscription);

module.exports = router;
