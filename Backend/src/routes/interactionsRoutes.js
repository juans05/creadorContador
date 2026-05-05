const express = require('express');
const router = express.Router();
const interactionsController = require('../controllers/interactionsController');
const { protect, optionalAuth } = require('../middleware/authMiddleware');

router.post('/like', protect, interactionsController.likeContent);
router.delete('/like', protect, interactionsController.unlikeContent);
router.get('/like/:contentId', optionalAuth, interactionsController.getLikeStatus);

router.post('/comment', protect, interactionsController.addComment);
router.get('/comments', interactionsController.getComments);

router.post('/follow', protect, interactionsController.followInfluencer);
router.delete('/follow', protect, interactionsController.unfollowInfluencer);
router.get('/follow/:influencerId', optionalAuth, interactionsController.getFollowStatus);

module.exports = router;