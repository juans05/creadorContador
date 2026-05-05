const { pool } = require('../config/db');

// GET /api/home/feed
exports.getFeed = async (req, res) => {
  const page = parseInt(req.query.page, 10) || 1;
  const limit = parseInt(req.query.limit, 10) || 20;
  const sort = req.query.sort || 'trending';
  const category = req.query.category;
  const search = req.query.search;
  const offset = (page - 1) * limit;

  try {
    let orderByClause = 'ORDER BY i.rating DESC';
    if (sort === 'trending') {
      orderByClause = 'ORDER BY i.suscriptores_count DESC, i.rating DESC';
    } else if (sort === 'recent') {
      orderByClause = 'ORDER BY i.created_at DESC';
    }

    let whereClause = "WHERE i.status = 'active'";
    const params = [limit, offset];
    let paramIndex = 3;

    if (category) {
      whereClause += ` AND i.id IN (
        SELECT influencer_id FROM influencer_categories 
        WHERE category_id = (SELECT id FROM categories WHERE slug = $${paramIndex})
      )`;
      params.push(category);
      paramIndex++;
    }

    if (search) {
      whereClause += ` AND i.username ILIKE $${paramIndex}`;
      params.push(`%${search}%`);
      paramIndex++;
    }

    const query = `
      SELECT i.id as "influencerId", i.username, i.profile_picture_url as "profilePicture", 
             i.rating, i.rating_count as "ratingCount", i.suscriptores_count as "subscribersCount",
             i.is_live as "isLive"
      FROM influencers i
      ${whereClause}
      ${orderByClause}
      LIMIT $1 OFFSET $2
    `;

    const countQuery = `SELECT COUNT(*) FROM influencers i ${whereClause}`;

    const [creatorsResult, countResult] = await Promise.all([
      pool.query(query, params),
      pool.query(countQuery, params.slice(0, -2))
    ]);

    const creatorIds = creatorsResult.rows.map(c => c.influencerId);
    let previewPhotosMap = {};

    if (creatorIds.length > 0) {
      const photosQuery = `
        SELECT influencer_id, url, thumbnail_url as thumbnail, 'photo' as type
        FROM photos 
        WHERE influencer_id = ANY($1) AND visibility = 'public'
        ORDER BY created_at DESC
      `;
      const videosQuery = `
        SELECT influencer_id, url, thumbnail_url as thumbnail, 'video' as type
        FROM videos 
        WHERE influencer_id = ANY($1) AND visibility = 'public'
        ORDER BY created_at DESC
      `;

      const [photosResult, videosResult] = await Promise.all([
        pool.query(photosQuery, [creatorIds]),
        pool.query(videosQuery, [creatorIds])
      ]);

      const allContent = [...photosResult.rows, ...videosResult.rows];
      
      creatorIds.forEach(id => {
        const creatorContent = allContent
          .filter(c => c.influencer_id === id)
          .slice(0, 3)
          .map(c => ({ url: c.url, thumbnail: c.thumbnail, type: c.type }));
        previewPhotosMap[id] = creatorContent;
      });
    }

    const creatorsWithPreviews = creatorsResult.rows.map(creator => ({
      ...creator,
      previewPhotos: previewPhotosMap[creator.influencerId] || []
    }));

    res.status(200).json({
      success: true,
      data: {
        total: parseInt(countResult.rows[0].count, 10),
        page,
        limit,
        creators: creatorsWithPreviews
      }
    });

  } catch (error) {
    console.error('Get feed error:', error);
    res.status(500).json({ success: false, message: 'Error interno del servidor' });
  }
};

// GET /api/home/search
exports.search = async (req, res) => {
  const { q, type = 'all', limit = 20 } = req.query;

  if (!q || q.trim().length < 2) {
    return res.status(400).json({ success: false, message: 'Buscar mínimo 2 caracteres' });
  }

  const searchTerm = `%${q.trim()}%`;

  try {
    const results = {
      creators: [],
      content: []
    };

    if (type === 'all' || type === 'creators') {
      const creatorsResult = await pool.query(
        `SELECT i.id as "influencerId", i.username, i.profile_picture_url as "profilePicture", 
                i.rating, i.suscriptores_count as "subscribersCount"
         FROM influencers i
         WHERE i.status = 'active' AND i.username ILIKE $1
         ORDER BY i.suscriptores_count DESC
         LIMIT $2`,
        [searchTerm, limit]
      );
      results.creators = creatorsResult.rows;
    }

    if (type === 'all' || type === 'content') {
      const contentResult = await pool.query(
        `(SELECT id, influencer_id as "influencerId", url, thumbnail_url as thumbnail, 
                'photo' as type, created_at as "createdAt"
         FROM photos 
         WHERE description ILIKE $1 AND visibility = 'public')
         UNION ALL
         (SELECT id, influencer_id as "influencerId", url, thumbnail_url as thumbnail, 
                'video' as type, created_at as "createdAt"
         FROM videos 
         WHERE description ILIKE $1 AND visibility = 'public')
         ORDER BY "createdAt" DESC
         LIMIT $2`,
        [searchTerm, limit]
      );
      results.content = contentResult.rows;
    }

    res.status(200).json({
      success: true,
      data: {
        query: q,
        total: results.creators.length + results.content.length,
        ...results
      }
    });

  } catch (error) {
    console.error('Search error:', error);
    res.status(500).json({ success: false, message: 'Error en la búsqueda' });
  }
};