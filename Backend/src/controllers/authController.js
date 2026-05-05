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

exports.getMe = async (req, res, next) => {
  try {
    const userId = req.user.userId;
    const { pool } = require('../config/db');

    const result = await pool.query(
      `SELECT id, email, name, phone, profile_picture_url as "profilePicture", bio, created_at as "createdAt"
       FROM users WHERE id = $1`,
      [userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Usuario no encontrado' });
    }

    const user = result.rows[0];

    const influencerResult = await pool.query(
      `SELECT id, username FROM influencers WHERE user_id = $1`,
      [userId]
    );

    const isInfluencer = influencerResult.rows.length > 0;

    res.status(200).json({
      success: true,
      data: {
        ...user,
        isInfluencer,
        influencerId: isInfluencer ? influencerResult.rows[0].id : null,
        username: isInfluencer ? influencerResult.rows[0].username : null
      }
    });
  } catch (error) {
    next(error);
  }
};

exports.updateProfile = async (req, res, next) => {
  try {
    const userId = req.user.userId;
    const { name, bio, profilePictureUrl } = req.body;
    const { pool } = require('../config/db');

    if (!name && !bio && !profilePictureUrl) {
      return res.status(400).json({ success: false, message: 'Ningún campo para actualizar' });
    }

    const updates = [];
    const params = [];
    let paramIndex = 1;

    if (name) {
      updates.push(`name = $${paramIndex++}`);
      params.push(name);
    }
    if (bio !== undefined) {
      updates.push(`bio = $${paramIndex++}`);
      params.push(bio);
    }
    if (profilePictureUrl) {
      updates.push(`profile_picture_url = $${paramIndex++}`);
      params.push(profilePictureUrl);
    }

    updates.push(`updated_at = CURRENT_TIMESTAMP`);
    params.push(userId);

    const query = `UPDATE users SET ${updates.join(', ')} WHERE id = $${paramIndex} RETURNING id, email, name, phone, profile_picture_url as "profilePicture", bio`;

    const result = await pool.query(query, params);

    res.status(200).json({
      success: true,
      data: result.rows[0]
    });
  } catch (error) {
    next(error);
  }
};
