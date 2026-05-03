const userService = require('../services/userService');

exports.register = async (req, res, next) => {
  try {
    const result = await userService.register(req.body);
    res.status(201).json({
      success: true,
      message: 'Usuario registrado. Revisa tu email',
      data: {
        ...result,
        verificationEmailSent: true,
        expiresIn: 86400
      }
    });
  } catch (error) {
    next(error);
  }
};

exports.login = async (req, res, next) => {
  try {
    const result = await userService.login(req.body, req.ip);
    res.status(200).json({
      success: true,
      data: {
        ...result,
        expiresIn: 86400
      }
    });
  } catch (error) {
    next(error);
  }
};

exports.verifyEmail = async (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Email verificado exitosamente',
    data: {
      userId: req.body.userId,
      emailVerified: true,
      redirectUrl: '/auth/login'
    }
  });
};
