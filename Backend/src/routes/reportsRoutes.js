const express = require('express');
const router = express.Router();
const reportsController = require('../controllers/reportsController');
const { protect } = require('../middleware/authMiddleware');

router.post('/', protect, reportsController.reportUser);

module.exports = router;