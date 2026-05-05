const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'tu_super_secreto_aqui';

exports.authenticateSocket = (socket, next) => {
  const token = socket.handshake.auth.token || socket.handshake.query.token;

  if (!token) {
    return next(new Error('Authentication error: No token provided'));
  }

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    socket.user = decoded;
    socket.userId = decoded.userId;
    next();
  } catch (error) {
    next(new Error('Authentication error: Invalid token'));
  }
};

exports.optionalAuthSocket = (socket, next) => {
  const token = socket.handshake.auth.token || socket.handshake.query.token;

  if (token) {
    try {
      const decoded = jwt.verify(token, JWT_SECRET);
      socket.user = decoded;
      socket.userId = decoded.userId;
    } catch (error) {
      // Token inválido pero es opcional
    }
  }
  next();
};