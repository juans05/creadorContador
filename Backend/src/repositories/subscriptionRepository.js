const db = require('../config/db');

class SubscriptionRepository {
  async findActive(userId, influencerId) {
    const result = await db.query(
      `SELECT id FROM subscriptions 
       WHERE user_id = $1 AND influencer_id = $2 AND active = true AND expires_at > CURRENT_TIMESTAMP`,
      [userId, influencerId]
    );
    return result.rows[0];
  }

  async create({ userId, influencerId, planType, pricePaid }) {
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 30);

    const result = await db.query(
      `INSERT INTO subscriptions (user_id, influencer_id, plan_type, price_paid, expires_at, active)
       VALUES ($1, $2, $3, $4, $5, true)
       RETURNING id`,
      [userId, influencerId, planType, pricePaid, expiresAt]
    );
    return result.rows[0];
  }

  async findById(id) {
    const result = await db.query(
      'SELECT * FROM subscriptions WHERE id = $1',
      [id]
    );
    return result.rows[0];
  }

  async findByUser(userId) {
    const result = await db.query(
      `SELECT s.*, i.username, i.profile_picture_url
       FROM subscriptions s
       JOIN influencers i ON s.influencer_id = i.id
       WHERE s.user_id = $1 AND s.active = true AND s.expires_at > CURRENT_TIMESTAMP`,
      [userId]
    );
    return result.rows;
  }

  async deactivate(id) {
    await db.query('UPDATE subscriptions SET active = false WHERE id = $1', [id]);
  }

  async deactivateByUserAndInfluencer(userId, influencerId) {
    await db.query(
      'UPDATE subscriptions SET active = false WHERE user_id = $1 AND influencer_id = $2',
      [userId, influencerId]
    );
  }
}

module.exports = new SubscriptionRepository();