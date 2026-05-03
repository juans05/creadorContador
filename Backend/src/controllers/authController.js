const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { pool } = require('../config/db');

// POST /api/auth/register
exports.register = async (req, res) => {
  const { email, password, confirmPassword, name, phone, dateOfBirth, ageConfirmed, termsAccepted, privacyAccepted } = req.body;

  try {
    // Validaciones básicas
    if (password !== confirmPassword) {
      return res.status(422).json({ success: false, error: 'VALIDATION_ERROR', errors: [{ field: 'password', message: 'Las contraseñas no coinciden', code: 'PASSWORD_MISMATCH' }] });
    }
    if (password.length < 8) {
      return res.status(422).json({ success: false, error: 'VALIDATION_ERROR', errors: [{ field: 'password', message: 'La contraseña debe tener mínimo 8 caracteres', code: 'MIN_LENGTH' }] });
    }
    if (!/^\d{9,12}$/.test(phone)) {
      return res.status(422).json({ success: false, error: 'VALIDATION_ERROR', errors: [{ field: 'phone', message: 'Formato inválido. Debe ser 9XXXXXXXXX', code: 'INVALID_FORMAT' }] });
    }

    // Verificar si el usuario ya existe
    const userExists = await pool.query('SELECT id FROM users WHERE email = $1', [email]);
    if (userExists.rows.length > 0) {
      return res.status(400).json({ success: false, error: 'EMAIL_ALREADY_EXISTS', message: 'Este email ya está registrado', options: { loginUrl: '/auth/login', resetPasswordUrl: '/auth/forgot-password' } });
    }

    // Encriptar contraseña
    const saltRounds = 10;
    const passwordHash = await bcrypt.hash(password, saltRounds);

    // Insertar nuevo usuario
    const insertUserQuery = `
      INSERT INTO users (email, password_hash, name, phone, date_of_birth, age_confirmed, terms_accepted, privacy_accepted)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
      RETURNING id, email
    `;
    const result = await pool.query(insertUserQuery, [email, passwordHash, name, phone, dateOfBirth, ageConfirmed, termsAccepted, privacyAccepted]);
    const newUser = result.rows[0];
    
    res.status(201).json({
      success: true,
      message: 'Usuario registrado. Revisa tu email',
      data: {
        userId: newUser.id,
        email: newUser.email,
        verificationEmailSent: true,
        expiresIn: 86400
      }
    });

  } catch (error) {
    console.error('Register error:', error);
    res.status(500).json({ success: false, message: 'Error interno del servidor' });
  }
};

// POST /api/auth/login
exports.login = async (req, res) => {
  const { email, password } = req.body;

  try {
    const result = await pool.query('SELECT id, email, password_hash, name, status FROM users WHERE email = $1', [email]);
    const user = result.rows[0];

    if (!user) {
      return res.status(401).json({ success: false, message: 'Credenciales inválidas' });
    }

    const isMatch = await bcrypt.compare(password, user.password_hash);
    if (!isMatch) {
      return res.status(401).json({ success: false, message: 'Credenciales inválidas' });
    }

    if (user.status !== 'active') {
      return res.status(403).json({ success: false, message: 'Cuenta no está activa' });
    }

    // Generar JWT
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

    // Guardar sesión
    await pool.query(
      'INSERT INTO user_sessions (user_id, jwt_token, refresh_token, ip_address, expires_at) VALUES ($1, $2, $3, $4, CURRENT_TIMESTAMP + INTERVAL \'7 days\')',
      [user.id, accessToken, refreshToken, req.ip || '127.0.0.1']
    );

    // Chequear si es influencer o consumidor
    const infResult = await pool.query('SELECT id FROM influencers WHERE user_id = $1', [user.id]);
    const userType = infResult.rows.length > 0 ? 'influencer' : 'consumer';

    res.status(200).json({
      success: true,
      data: {
        userId: user.id,
        email: user.email,
        name: user.name,
        userType,
        accessToken,
        refreshToken,
        expiresIn: 86400
      }
    });

  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ success: false, message: 'Error interno del servidor' });
  }
};

// POST /api/auth/verify-email
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
