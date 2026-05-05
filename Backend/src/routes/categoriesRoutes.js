const express = require('express');
const router = express.Router();
const categoriesController = require('../controllers/categoriesController');

router.get('/', categoriesController.getCategories);
router.get('/trending', categoriesController.getTrendingTags);
router.get('/:slug', categoriesController.getInfluencersByCategory);
router.post('/tag/use', categoriesController.useTag);

module.exports = router;