const db = require('../config/db');

class InfluencerRepository {
  async findByUserId(userId) {
    const result = await db.query(
      'SELECT id, user_id, username, bio, profile_picture_url, rating, rating_count, suscriptores_count, total_earnings_soles, total_earnings_today, status FROM influencers WHERE user_id = $1',
      [userId]
    );
    return result.rows[0];
  }

  async findByUsername(username) {
    const result = await db.query(
      `SELECT i.id as influencer_id, i.username, i.bio, i.profile_picture_url as "profilePicture", 
              i.rating, i.rating_count as "ratingCount", i.suscriptores_count as "subscribersCount", u.name
       FROM influencers i
       JOIN users u ON i.user_id = u.id
       WHERE i.username = $1 AND i.status = 'active'`,
      [username]
    );
    return result.rows[0];
  }

  async findById(id) {
    const result = await db.query(
      'SELECT * FROM influencers WHERE id = $1',
      [id]
    );
    return result.rows[0];
  }

  async create({ userId, username, bio, yapeIdEncrypted }) {
    const result = await db.query(
      `INSERT INTO influencers (user_id, username, bio, yape_id_encrypted)
       VALUES ($1, $2, $3, $4)
       RETURNING id, username`,
      [userId, username, bio, yapeIdEncrypted]
    );
    return result.rows[0];
  }

  async usernameExists(username) {
    const result = await db.query('SELECT id FROM influencers WHERE username = $1', [username]);
    return result.rows.length > 0;
  }

  async getStats(userId) {
    const result = await db.query(
      `SELECT id, username, rating, suscriptores_count as "subscribersCount", 
              total_earnings_soles as "totalEarnings", total_earnings_today as "todayEarnings"
       FROM influencers 
       WHERE user_id = $1`,
      [userId]
    );
    return result.rows[0];
  }

  async getRecentTransactions(influencerId, limit = 10) {
    const result = await db.query(
      `SELECT t.id, t.amount, t.type, t.status, t.created_at as "createdAt", u.name as "userName"
       FROM transactions t
       JOIN users u ON t.user_id = u.id
       WHERE t.influencer_id = $1
       ORDER BY t.created_at DESC
       LIMIT $2`,
      [influencerId, limit]
    );
    return result.rows;
  }

  async incrementSubscribers(influencerId) {
    await db.query(
      'UPDATE influencers SET suscriptores_count = suscriptores_count + 1 WHERE id = $1',
      [influencerId]
    );
  }

  async decrementSubscribers(influencerId) {
    await db.query(
      'UPDATE influencers SET suscriptores_count = GREATEST(suscriptores_count - 1, 0) WHERE id = $1',
      [influencerId]
    );
  }
}

module.exports = new InfluencerRepository();