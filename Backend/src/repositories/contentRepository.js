const db = require('../config/db');

class ContentRepository {
  async createPhoto({ influencerId, url, thumbnailUrl, cloudinaryPublicId, description, visibility, ppvPrice }) {
    const result = await db.query(
      `INSERT INTO photos (influencer_id, url, thumbnail_url, cloudinary_public_id, description, visibility, ppv_price_diamonds)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       RETURNING id, url, visibility, 'photo' as content_type`,
      [influencerId, url, thumbnailUrl, cloudinaryPublicId, description, visibility, ppvPrice]
    );
    return result.rows[0];
  }

  async createVideo({ influencerId, url, cloudinaryPublicId, description, visibility, ppvPrice, duration }) {
    const result = await db.query(
      `INSERT INTO videos (influencer_id, url, cloudinary_public_id, description, visibility, ppv_price_diamonds, duration)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       RETURNING id, url, visibility, 'video' as content_type`,
      [influencerId, url, cloudinaryPublicId, description, visibility, ppvPrice, duration]
    );
    return result.rows[0];
  }

  async findPhotosByInfluencer(influencerId) {
    const result = await db.query(
      `SELECT id as "photoId", url, thumbnail_url as thumbnail, visibility, ppv_price_diamonds as "ppvPrice", created_at as "createdAt"
       FROM photos
       WHERE influencer_id = $1
       ORDER BY created_at DESC`,
      [influencerId]
    );
    return result.rows;
  }

  async findPhotosByInfluencerForOwner(influencerId) {
    const result = await db.query(
      `SELECT id, url, thumbnail_url, description, visibility, ppv_price_diamonds, created_at, 'photo' as content_type
       FROM photos 
       WHERE influencer_id = $1 
       ORDER BY created_at DESC`,
      [influencerId]
    );
    return result.rows;
  }

  async findVideosByInfluencerForOwner(influencerId) {
    const result = await db.query(
      `SELECT id, url, description, visibility, ppv_price_diamonds, duration, created_at, 'video' as content_type
       FROM videos 
       WHERE influencer_id = $1 
       ORDER BY created_at DESC`,
      [influencerId]
    );
    return result.rows;
  }

  async findPhotoById(id, influencerId) {
    const result = await db.query(
      'SELECT cloudinary_public_id FROM photos WHERE id = $1 AND influencer_id = $2',
      [id, influencerId]
    );
    return result.rows[0];
  }

  async findVideoById(id, influencerId) {
    const result = await db.query(
      'SELECT cloudinary_public_id FROM videos WHERE id = $1 AND influencer_id = $2',
      [id, influencerId]
    );
    return result.rows[0];
  }

  async deletePhoto(id, influencerId) {
    await db.query('DELETE FROM photos WHERE id = $1 AND influencer_id = $2', [id, influencerId]);
  }

  async deleteVideo(id, influencerId) {
    await db.query('DELETE FROM videos WHERE id = $1 AND influencer_id = $2', [id, influencerId]);
  }
}

module.exports = new ContentRepository();