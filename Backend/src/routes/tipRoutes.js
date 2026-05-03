const express = require('express');
const router = express.Router();
const tipController = require('../controllers/tipController');
const { protect } = require('../middleware/authMiddleware');

router.post('/', protect, tipController.sendTip);

module.exports = router;
