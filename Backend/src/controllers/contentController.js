const contentService = require('../services/contentService');
const fs = require('fs');

exports.uploadContent = async (req, res, next) => {
  if (!req.file) {
    return res.status(400).json({ success: false, message: 'Ningún archivo enviado' });
  }

  try {
    const result = await contentService.uploadContent({
      userId: req.user.userId,
      file: req.file,
      ...req.body
    });
    res.status(201).json({ success: true, ...result });
  } catch (error) {
    if (req.file && fs.existsSync(req.file.path)) {
      fs.unlinkSync(req.file.path);
    }
    next(error);
  }
};

exports.getMyContent = async (req, res, next) => {
  try {
    const result = await contentService.getMyContent(req.user.userId);
    res.status(200).json({ success: true, data: result });
  } catch (error) {
    next(error);
  }
};

exports.deleteContent = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { type } = req.query;
    const result = await contentService.deleteContent({
      userId: req.user.userId,
      id,
      type
    });
    res.status(200).json({ success: true, ...result });
  } catch (error) {
    next(error);
  }
};