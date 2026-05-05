const express = require('express');
const router = express.Router();
const diamondController = require('../controllers/diamondController');
const { protect } = require('../middleware/authMiddleware');

router.get('/balance', protect, diamondController.getBalance);
router.post('/purchase', protect, diamondController.purchaseDiamonds);
router.post('/spend', protect, diamondController.spendDiamonds);
router.post('/convert', protect, diamondController.convertDiamonds);

module.exports = router;
