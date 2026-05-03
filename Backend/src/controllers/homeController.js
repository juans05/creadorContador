const { pool } = require('../config/db');

// GET /api/home/feed
exports.getFeed = async (req, res) => {
  const page = parseInt(req.query.page, 10) || 1;
  const limit = parseInt(req.query.limit, 10) || 20;
  const sort = req.query.sort || 'trending';
  const offset = (page - 1) * limit;

  try {
    let orderByClause = 'ORDER BY i.rating DESC';
    if (sort === 'trending') {
      orderByClause = 'ORDER BY i.suscriptores_count DESC, i.rating DESC';
    } else if (sort === 'recent') {
      orderByClause = 'ORDER BY i.created_at DESC';
    }

    const query = `
      SELECT i.id as "influencerId", i.username, i.profile_picture_url as "profilePicture", 
             i.rating, i.rating_count as "ratingCount", i.suscriptores_count as "subscribersCount"
      FROM influencers i
      WHERE i.status = 'active'
      ${orderByClause}
      LIMIT $1 OFFSET $2
    `;
    
    const countQuery = `SELECT COUNT(*) FROM influencers WHERE status = 'active'`;

    const [creatorsResult, countResult] = await Promise.all([
      pool.query(query, [limit, offset]),
      pool.query(countQuery)
    ]);

    res.status(200).json({
      success: true,
      data: {
        total: parseInt(countResult.rows[0].count, 10),
        page,
        limit,
        creators: creatorsResult.rows
      }
    });

  } catch (error) {
    console.error('Get feed error:', error);
    res.status(500).json({ success: false, message: 'Error interno del servidor' });
  }
};
