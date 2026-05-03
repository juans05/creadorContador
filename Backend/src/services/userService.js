const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const userRepository = require('../repositories/userRepository');
const influencerRepository = require('../repositories/influencerRepository');
const db = require('../config/db');

class UserService {
  async register({ email, password, confirmPassword, name, phone, dateOfBirth, ageConfirmed, termsAccepted, privacyAccepted }) {
    if (password !== confirmPassword) {
      const error = new Error('Las contraseñas no coinciden');
      error.code = 'PASSWORD_MISMATCH';
      error.status = 422;
      throw error;
    }

    if (password.length < 8) {
      const error = new Error('La contraseña debe tener mínimo 8 caracteres');
      error.code = 'MIN_LENGTH';
      error.status = 422;
      throw error;
    }

    if (!/^\d{9,12}$/.test(phone)) {
      const error = new Error('Formato inválido. Debe ser 9XXXXXXXXX');
      error.code = 'INVALID_FORMAT';
      error.status = 422;
      throw error;
    }

    const exists = await userRepository.emailExists(email);
    if (exists) {
      const error = new Error('Este email ya está registrado');
      error.code = 'EMAIL_ALREADY_EXISTS';
      error.status = 400;
      throw error;
    }

    const saltRounds = 10;
    const passwordHash = await bcrypt.hash(password, saltRounds);

    const newUser = await userRepository.create({
      email,
      passwordHash,
      name,
      phone,
      dateOfBirth,
      ageConfirmed,
      termsAccepted,
      privacyAccepted
    });

    return {
      userId: newUser.id,
      email: newUser.email,
      verificationEmailSent: true
    };
  }

  async login({ email, password }, ipAddress) {
    const user = await userRepository.findByEmail(email);

    if (!user) {
      const error = new Error('Credenciales inválidas');
      error.status = 401;
      throw error;
    }

    const isMatch = await bcrypt.compare(password, user.password_hash);
    if (!isMatch) {
      const error = new Error('Credenciales inválidas');
      error.status = 401;
      throw error;
    }

    if (user.status !== 'active') {
      const error = new Error('Cuenta no está activa');
      error.status = 403;
      throw error;
    }

    const accessToken = jwt.sign(
      { userId: user.id, email: user.email },
      process.env.JWT_SECRET || 'tu_super_secreto_aqui',
      { expiresIn: '24h' }
    );

    const refreshToken = jwt.sign(
      { userId: user.id },
      process.env.JWT_SECRET || 'tu_super_secreto_aqui',
      { expiresIn: '7d' }
    );

    await db.query(
      'INSERT INTO user_sessions (user_id, jwt_token, refresh_token, ip_address, expires_at) VALUES ($1, $2, $3, $4, CURRENT_TIMESTAMP + INTERVAL \'7 days\')',
      [user.id, accessToken, refreshToken, ipAddress || '127.0.0.1']
    );

    const infResult = await influencerRepository.findByUserId(user.id);
    const userType = infResult ? 'influencer' : 'consumer';

    return {
      userId: user.id,
      email: user.email,
      name: user.name,
      userType,
      accessToken,
      refreshToken
    };
  }
}

module.exports = new UserService();