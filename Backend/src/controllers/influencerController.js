const influencerService = require('../services/influencerService');

exports.register = async (req, res, next) => {
  try {
    const userId = req.user?.userId;
    if (!userId) {
      return res.status(401).json({ success: false, message: 'No autenticado' });
    }
    const result = await influencerService.register({ userId, ...req.body });
    res.status(201).json({ success: true, data: result });
  } catch (error) {
    if (error.code === '23505') {
      return res.status(400).json({ success: false, message: 'El usuario ya está registrado como creadora' });
    }
    next(error);
  }
};

exports.getProfile = async (req, res, next) => {
  try {
    const { username } = req.params;
    const userId = req.user?.userId;
    const result = await influencerService.getProfile(username, userId);
    res.status(200).json({ success: true, data: result });
  } catch (error) {
    next(error);
  }
};

exports.getDashboardStats = async (req, res, next) => {
  try {
    const userId = req.user.userId;
    const result = await influencerService.getDashboardStats(userId);
    res.status(200).json({ success: true, data: result });
  } catch (error) {
    next(error);
  }
};
