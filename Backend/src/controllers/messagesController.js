const { pool } = require('../config/db');

exports.getConversation = async (req, res, next) => {
  try {
    const { userId } = req.params;
    const currentUserId = req.user.userId;
    const { limit = 50, offset = 0 } = req.query;

    if (!userId) {
      return res.status(400).json({ success: false, message: 'userId requerido' });
    }

    if (userId === currentUserId) {
      return res.status(400).json({ success: false, message: 'No puedes ver tus propios mensajes' });
    }

    const hasSubscription = await checkSubscription(currentUserId, userId);
    if (!hasSubscription) {
      return res.status(403).json({ success: false, message: 'Se requiere suscripción para chatear' });
    }

    const result = await pool.query(
      `(SELECT id, sender_id as "from", receiver_id as "to", content, is_read as "isRead", created_at as "createdAt"
       FROM messages 
       WHERE sender_id = $1 AND receiver_id = $2)
       UNION ALL
       (SELECT id, sender_id as "from", receiver_id as "to", content, is_read as "isRead", created_at as "createdAt"
       FROM messages 
       WHERE sender_id = $3 AND receiver_id = $4)
       ORDER BY "createdAt" DESC
       LIMIT $5 OFFSET $6`,
      [currentUserId, userId, userId, currentUserId, limit, offset]
    );

    const markAsRead = await pool.query(
      `UPDATE messages 
       SET is_read = true, read_at = CURRENT_TIMESTAMP
       WHERE sender_id = $1 AND receiver_id = $2 AND is_read = false`,
      [userId, currentUserId]
    );

    res.status(200).json({
      success: true,
      data: {
        conversation: result.rows,
        total: result.rows.length
      }
    });
  } catch (error) {
    next(error);
  }
};

exports.sendMessage = async (req, res, next) => {
  try {
    const { receiverId, content } = req.body;
    const senderId = req.user.userId;

    if (!receiverId || !content) {
      return res.status(400).json({ success: false, message: 'receiverId y content requeridos' });
    }

    if (content.trim().length === 0) {
      return res.status(400).json({ success: false, message: 'Mensaje vacío' });
    }

    const hasSubscription = await checkSubscription(senderId, receiverId);
    if (!hasSubscription) {
      return res.status(403).json({ success: false, message: 'Se requiere suscripción para chatear' });
    }

    const result = await pool.query(
      `INSERT INTO messages (sender_id, receiver_id, content)
       VALUES ($1, $2, $3)
       RETURNING id, content, created_at as "createdAt"`,
      [senderId, receiverId, content.trim()]
    );

    res.status(201).json({
      success: true,
      data: result.rows[0]
    });
  } catch (error) {
    next(error);
  }
};

exports.markAsRead = async (req, res, next) => {
  try {
    const { messageId } = req.params;
    const userId = req.user.userId;

    await pool.query(
      `UPDATE messages 
       SET is_read = true, read_at = CURRENT_TIMESTAMP
       WHERE id = $1 AND receiver_id = $2`,
      [messageId, userId]
    );

    res.status(200).json({ success: true });
  } catch (error) {
    next(error);
  }
};

async function checkSubscription(userId, influencerUserId) {
  const result = await pool.query(
    `SELECT id FROM subscriptions 
     WHERE user_id = $1 AND influencer_id = (
       SELECT id FROM influencers WHERE user_id = $2
     ) AND active = true`,
    [userId, influencerUserId]
  );
  return result.rows.length > 0;
}