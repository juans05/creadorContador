const { authenticateSocket, optionalAuthSocket } = require('./middleware/socketAuth');
const { pool } = require('./config/db');

class SocketService {
  constructor(io) {
    this.io = io;
    this.userSockets = new Map();
    this.socketUsers = new Map();
  }

  initialize() {
    this.io.use((socket, next) => {
      optionalAuthSocket(socket, next);
    });

    this.io.on('connection', (socket) => this.handleConnection(socket));
  }

  async handleConnection(socket) {
    const userId = socket.userId;

    if (userId) {
      this.userSockets.set(userId, socket.id);
      this.socketUsers.set(socket.id, userId);
      console.log(`User ${userId} connected: ${socket.id}`);
    }

    socket.on('message:send', (data) => this.handleMessage(socket, data));
    socket.on('typing:start', (data) => this.handleTypingStart(socket, data));
    socket.on('typing:stop', (data) => this.handleTypingStop(socket, data));
    socket.on('disconnect', (reason) => this.handleDisconnect(socket, reason));
  }

  async handleMessage(socket, data) {
    const { receiverId, content } = data;
    const senderId = socket.userId;

    if (!senderId || !receiverId || !content) {
      socket.emit('message:error', { error: 'Datos inválidos' });
      return;
    }

    if (content.trim().length === 0) {
      socket.emit('message:error', { error: 'Mensaje vacío' });
      return;
    }

    try {
      const canChat = await this.checkChatPermission(senderId, receiverId);
      if (!canChat) {
        socket.emit('message:error', { error: 'No puedes chatear con este usuario' });
        return;
      }

      const message = await this.saveMessage({
        senderId,
        receiverId,
        content: content.trim()
      });

      const receiverSocketId = this.userSockets.get(receiverId);
      if (receiverSocketId) {
        this.io.to(receiverSocketId).emit('message:receive', {
          id: message.id,
          senderId,
          content: message.content,
          createdAt: message.created_at
        });
      }

      socket.emit('message:sent', {
        id: message.id,
        receiverId,
        status: 'delivered'
      });
    } catch (error) {
      console.error('Error sending message:', error);
      socket.emit('message:error', { error: 'Error al enviar mensaje' });
    }
  }

  async handleTypingStart(socket, data) {
    const { receiverId } = data;
    const senderId = socket.userId;

    if (!receiverId || !senderId) return;

    const receiverSocketId = this.userSockets.get(receiverId);
    if (receiverSocketId) {
      this.io.to(receiverSocketId).emit('typing:receive', {
        senderId,
        isTyping: true
      });
    }
  }

  async handleTypingStop(socket, data) {
    const { receiverId } = data;
    const senderId = socket.userId;

    if (!receiverId || !senderId) return;

    const receiverSocketId = this.userSockets.get(receiverId);
    if (receiverSocketId) {
      this.io.to(receiverSocketId).emit('typing:receive', {
        senderId,
        isTyping: false
      });
    }
  }

  handleDisconnect(socket, reason) {
    const userId = this.socketUsers.get(socket.id);
    if (userId) {
      this.userSockets.delete(userId);
      this.socketUsers.delete(socket.id);
      console.log(`User ${userId} disconnected: ${reason}`);
    }
  }

  async checkChatPermission(senderId, receiverId) {
    const subQuery = `
      SELECT id FROM subscriptions 
      WHERE user_id = $1 AND influencer_id = (
        SELECT id FROM influencers WHERE user_id = $2
      ) AND active = true
    `;
    const result = await pool.query(subQuery, [senderId, receiverId]);
    return result.rows.length > 0;
  }

  async saveMessage({ senderId, receiverId, content }) {
    const result = await pool.query(
      `INSERT INTO messages (sender_id, receiver_id, content)
       VALUES ($1, $2, $3)
       RETURNING id, content, created_at`,
      [senderId, receiverId, content]
    );
    return result.rows[0];
  }

  async getConversation(userId1, userId2, limit = 50, offset = 0) {
    const result = await pool.query(
      `(SELECT id, sender_id as "from", receiver_id as "to", content, created_at as "createdAt"
       FROM messages 
       WHERE sender_id = $1 AND receiver_id = $2)
       UNION ALL
       (SELECT id, sender_id as "from", receiver_id as "to", content, created_at as "createdAt"
       FROM messages 
       WHERE sender_id = $3 AND receiver_id = $4)
       ORDER BY "createdAt" DESC
       LIMIT $5 OFFSET $6`,
      [userId1, userId2, userId2, userId1, limit, offset]
    );
    return result.rows;
  }
}

module.exports = SocketService;