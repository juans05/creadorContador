const express = require('express');
const router = express.Router();
const homeController = require('../controllers/homeController');
const { optionalAuth } = require('../middleware/authMiddleware');

router.get('/feed', optionalAuth, homeController.getFeed);
router.get('/search', optionalAuth, homeController.search);

module.exports = router;
