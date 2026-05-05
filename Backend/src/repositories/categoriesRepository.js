const db = require('../config/db');

class CategoriesRepository {
  async getAll() {
    const result = await db.query(
      `SELECT id, name, slug, icon, color, sort_order as "sortOrder"
       FROM categories 
       WHERE is_active = true 
       ORDER BY sort_order ASC`
    );
    return result.rows;
  }

  async getBySlug(slug) {
    const result = await db.query(
      `SELECT id, name, slug, icon, color FROM categories WHERE slug = $1 AND is_active = true`,
      [slug]
    );
    return result.rows[0];
  }

  async getTrendingTags(limit = 10) {
    const result = await db.query(
      `SELECT tag, usage_count as "usageCount" 
       FROM trending_tags 
       WHERE is_active = true 
       ORDER BY usage_count DESC 
       LIMIT $1`,
      [limit]
    );
    return result.rows;
  }

  async incrementTagUsage(tag) {
    await db.query(
      `INSERT INTO trending_tags (tag, usage_count) VALUES ($1, 1)
       ON CONFLICT (tag) DO UPDATE SET usage_count = trending_tags.usage_count + 1`,
      [tag]
    );
  }

  async getInfluencersByCategory(categoryId, limit = 20) {
    const result = await db.query(
      `SELECT i.id as "influencerId", i.username, i.profile_picture_url as "profilePicture",
              i.rating, i.rating_count as "ratingCount", i.suscriptores_count as "subscribersCount"
       FROM influencers i
       JOIN influencer_categories ic ON i.id = ic.influencer_id
       WHERE ic.category_id = $1 AND i.status = 'active'
       ORDER BY i.rating DESC
       LIMIT $2`,
      [categoryId, limit]
    );
    return result.rows;
  }
}

module.exports = new CategoriesRepository();