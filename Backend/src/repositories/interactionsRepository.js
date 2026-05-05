const db = require('../config/db');

class InteractionsRepository {
  async addLike({ userId, contentId, contentType, influencerId }) {
    const table = contentType === 'video' ? 'videos' : 'photos';
    const result = await db.query(
      `INSERT INTO likes (user_id, content_id, content_type, influencer_id)
       VALUES ($1, $2, $3, $4)
       ON CONFLICT (user_id, content_id) DO NOTHING
       RETURNING id`,
      [userId, contentId, contentType, influencerId]
    );

    if (result.rows[0]) {
      await db.query(
        `UPDATE ${table} SET likes_count = likes_count + 1 WHERE id = $1`,
        [contentId]
      );
    }
    return result.rows[0];
  }

  async removeLike({ userId, contentId, contentType }) {
    const table = contentType === 'video' ? 'videos' : 'photos';
    const result = await db.query(
      `DELETE FROM likes WHERE user_id = $1 AND content_id = $2 AND content_type = $3
       RETURNING id`,
      [userId, contentId, contentType]
    );

    if (result.rows[0]) {
      await db.query(
        `UPDATE ${table} SET likes_count = likes_count - 1 WHERE id = $1 AND likes_count > 0`,
        [contentId]
      );
    }
    return result.rows[0];
  }

  async isLiked({ userId, contentId }) {
    const result = await db.query(
      'SELECT id FROM likes WHERE user_id = $1 AND content_id = $2',
      [userId, contentId]
    );
    return !!result.rows[0];
  }

  async getLikesCount({ contentId, contentType }) {
    const table = contentType === 'video' ? 'videos' : 'photos';
    const result = await db.query(
      `SELECT likes_count FROM ${table} WHERE id = $1`,
      [contentId]
    );
    return result.rows[0]?.likes_count || 0;
  }

  async addComment({ userId, contentId, contentType, influencerId, parentId, content }) {
    const result = await db.query(
      `INSERT INTO comments (user_id, content_id, content_type, influencer_id, parent_id, content)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING id, content, created_at`,
      [userId, contentId, contentType, influencerId, parentId || null, content]
    );
    return result.rows[0];
  }

  async getComments({ contentId, contentType, limit = 50 }) {
    const result = await db.query(
      `SELECT c.id, c.content, c.created_at, u.name as "userName", u.profile_picture_url as "userAvatar"
       FROM comments c
       JOIN users u ON c.user_id = u.id
       WHERE c.content_id = $1 AND c.content_type = $2
       ORDER BY c.created_at DESC
       LIMIT $3`,
      [contentId, contentType, limit]
    );
    return result.rows;
  }

  async followInfluencer({ followerId, influencerId }) {
    const result = await db.query(
      `INSERT INTO follows (follower_id, influencer_id)
       VALUES ($1, $2)
       ON CONFLICT (follower_id, influencer_id) DO NOTHING
       RETURNING id`,
      [followerId, influencerId]
    );

if (result.rows[0]) {
      await db.query(
        `UPDATE influencers SET suscriptores_count = suscriptores_count + 1 WHERE id = $1`,
        [influencerId]
      );
    }
    return result.rows[0];
  }

  async removeLike({ userId, contentId, contentType }) {
    const table = contentType === 'video' ? 'videos' : 'photos';
    const result = await db.query(
      `DELETE FROM likes WHERE user_id = $1 AND content_id = $2 AND content_type = $3
       RETURNING id`,
      [userId, contentId, contentType]
    );

    if (result.rows[0]) {
      await db.query(
        `UPDATE ${table} SET likes_count = likes_count - 1 WHERE id = $1 AND likes_count > 0`,
        [contentId]
      );
    }
    return result.rows[0];
  }

  async unfollowInfluencer({ followerId, influencerId }) {
    const result = await db.query(
      `DELETE FROM follows WHERE follower_id = $1 AND influencer_id = $2
       RETURNING id`,
      [followerId, influencerId]
    );

    if (result.rows[0]) {
      await db.query(
        `UPDATE influencers SET suscriptores_count = GREATEST(suscriptores_count - 1, 0) WHERE id = $1`,
        [influencerId]
      );
    }
    return result.rows[0];
  }
    return result.rows[0];
  }

  async unfollowInfluencer({ followerId, influencerId }) {
    const result = await db.query(
      `DELETE FROM follows WHERE follower_id = $1 AND influencer_id = $2
       RETURNING id`,
      [followerId, influencerId]
    );

    if (result.rows[0]) {
      await db.query(
        `UPDATE influencers SET suscriptores_count = seguidores_count - 1 WHERE id = $1 AND suscriptores_count > 0`,
        [influencerId]
      );
    }
    return result.rows[0];
  }

  async isFollowing({ followerId, influencerId }) {
    const result = await db.query(
      'SELECT id FROM follows WHERE follower_id = $1 AND influencer_id = $2',
      [followerId, influencerId]
    );
    return !!result.rows[0];
  }

  async getFollowersCount(influencerId) {
    const result = await db.query(
      'SELECT COUNT(*) FROM follows WHERE influencer_id = $1',
      [influencerId]
    );
    return parseInt(result.rows[0].count, 10);
  }
}

module.exports = new InteractionsRepository();