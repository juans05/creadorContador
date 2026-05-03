const express = require('express');
const router = express.Router();
const contentController = require('../controllers/contentController');
const { protect } = require('../middleware/authMiddleware');
const upload = require('../middleware/uploadMiddleware');

// El campo en el form-data debe llamarse 'media'
router.post('/upload', protect, upload.single('media'), contentController.uploadContent);
router.get('/my', protect, contentController.getMyContent);
router.delete('/:id', protect, contentController.deleteContent);

module.exports = router;
