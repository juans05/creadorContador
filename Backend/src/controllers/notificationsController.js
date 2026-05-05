const { pool } = require('../config/db');

exports.getNotifications = async (req, res) => {
  const userId = req.user.userId;
  const { limit = 20, offset = 0 } = req.query;

  try {
    const result = await pool.query(
      `SELECT id, type, title, body, data, is_read as "isRead", created_at as "createdAt"
       FROM notifications 
       WHERE user_id = $1
       ORDER BY created_at DESC
       LIMIT $2 OFFSET $3`,
      [userId, limit, offset]
    );

    const unreadCount = await pool.query(
      'SELECT COUNT(*) FROM notifications WHERE user_id = $1 AND is_read = false',
      [userId]
    );

    res.status(200).json({
      success: true,
      data: {
        notifications: result.rows,
        unreadCount: parseInt(unreadCount.rows[0].count, 10),
        total: result.rows.length
      }
    });
  } catch (error) {
    console.error('Get notifications error:', error);
    res.status(500).json({ success: false, message: 'Error al obtener notificaciones' });
  }
};

exports.markAsRead = async (req, res) => {
  const { id } = req.params;
  const userId = req.user.userId;

  try {
    await pool.query(
      `UPDATE notifications 
       SET is_read = true, read_at = CURRENT_TIMESTAMP
       WHERE id = $1 AND user_id = $2`,
      [id, userId]
    );

    res.status(200).json({ success: true });
  } catch (error) {
    console.error('Mark read error:', error);
    res.status(500).json({ success: false, message: 'Error al marcar como leída' });
  }
};

exports.markAllAsRead = async (req, res) => {
  const userId = req.user.userId;

  try {
    await pool.query(
      `UPDATE notifications 
       SET is_read = true, read_at = CURRENT_TIMESTAMP
       WHERE user_id = $1 AND is_read = false`,
      [userId]
    );

    res.status(200).json({ success: true });
  } catch (error) {
    console.error('Mark all read error:', error);
    res.status(500).json({ success: false, message: 'Error al marcar todas como leídas' });
  }
};

exports.getUnreadCount = async (req, res) => {
  const userId = req.user.userId;

  try {
    const result = await pool.query(
      'SELECT COUNT(*) FROM notifications WHERE user_id = $1 AND is_read = false',
      [userId]
    );

    res.status(200).json({
      success: true,
      data: { unreadCount: parseInt(result.rows[0].count, 10) }
    });
  } catch (error) {
    console.error('Get unread count error:', error);
    res.status(500).json({ success: false, message: 'Error al obtener conteo' });
  }
};