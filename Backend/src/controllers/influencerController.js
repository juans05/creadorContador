const { pool } = require('../config/db');

// POST /api/influencers/register
exports.register = async (req, res) => {
  const { username, bio, yapeNumber } = req.body;
  const userId = req.user?.userId;

  if (!userId) {
    return res.status(401).json({ success: false, message: 'No autenticado' });
  }

  try {
    if (!username || username.length < 3 || username.length > 50) {
      return res.status(422).json({ success: false, message: 'Username inválido' });
    }
    if (!/^\d{14}$/.test(yapeNumber)) {
      return res.status(422).json({ success: false, message: 'Número YAPE debe tener 14 dígitos' });
    }

    const checkUser = await pool.query('SELECT id FROM influencers WHERE username = $1', [username]);
    if (checkUser.rows.length > 0) {
      return res.status(400).json({ success: false, message: 'Username ya está en uso' });
    }

    const yapeEncrypted = Buffer.from(yapeNumber).toString('base64'); // MVP Mock

    const insertQuery = `
      INSERT INTO influencers (user_id, username, bio, yape_id_encrypted)
      VALUES ($1, $2, $3, $4)
      RETURNING id, username
    `;
    const result = await pool.query(insertQuery, [userId, username, bio, yapeEncrypted]);
    const newInfluencer = result.rows[0];

    res.status(201).json({
      success: true,
      data: {
        influencerId: newInfluencer.id,
        username: newInfluencer.username,
        dashboard: '/dashboard/influencer',
        canUploadContent: true
      }
    });

  } catch (error) {
    console.error('Influencer register error:', error);
    if (error.code === '23505') {
      return res.status(400).json({ success: false, message: 'El usuario ya está registrado como creadora' });
    }
    res.status(500).json({ success: false, message: 'Error interno del servidor' });
  }
};

// GET /api/influencers/:username
exports.getProfile = async (req, res) => {
  const { username } = req.params;
  const userId = req.user?.userId;

  try {
    const infQuery = `
      SELECT i.id as influencer_id, i.username, i.bio, i.profile_picture_url as "profilePicture", 
             i.rating, i.rating_count as "ratingCount", i.suscriptores_count as "subscribersCount", u.name
      FROM influencers i
      JOIN users u ON i.user_id = u.id
      WHERE i.username = $1 AND i.status = 'active'
    `;
    const infResult = await pool.query(infQuery, [username]);
    
    if (infResult.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Creadora no encontrada' });
    }
    
    const influencer = infResult.rows[0];

    let isSubscribed = false;
    if (userId) {
      const subCheck = await pool.query(
        'SELECT id FROM subscriptions WHERE user_id = $1 AND influencer_id = $2 AND active = true AND expires_at > CURRENT_TIMESTAMP',
        [userId, influencer.influencer_id]
      );
      isSubscribed = subCheck.rows.length > 0;
    }

    const photosQuery = `
      SELECT id as "photoId", url, thumbnail_url as thumbnail, visibility, ppv_price_diamonds as "ppvPrice", created_at as "createdAt"
      FROM photos
      WHERE influencer_id = $1
      ORDER BY created_at DESC
    `;
    const photosResult = await pool.query(photosQuery, [influencer.influencer_id]);
    
    const photos = photosResult.rows.map(p => {
      let hasAccess = p.visibility === 'public';
      if (p.visibility === 'subscribers_only' && isSubscribed) hasAccess = true;
      
      return {
        ...p,
        hasAccess,
        url: hasAccess ? p.url : null,
      };
    });

    res.status(200).json({
      success: true,
      data: {
        ...influencer,
        isSubscribed,
        photos
      }
    });

  } catch (error) {
    console.error('Get profile error:', error);
    res.status(500).json({ success: false, message: 'Error interno del servidor' });
  }
};

// GET /api/influencers/dashboard/stats
exports.getDashboardStats = async (req, res) => {
  const userId = req.user.userId;

  try {
    const infRes = await pool.query(`
      SELECT id, username, rating, suscriptores_count as "subscribersCount", 
             total_earnings_soles as "totalEarnings", total_earnings_today as "todayEarnings"
      FROM influencers 
      WHERE user_id = $1
    `, [userId]);

    if (infRes.rows.length === 0) {
      return res.status(403).json({ success: false, message: 'No eres una creadora registrada' });
    }

    const influencer = infRes.rows[0];

    // Obtener transacciones recientes
    const transRes = await pool.query(`
      SELECT t.id, t.amount, t.type, t.status, t.created_at as "createdAt", u.name as "userName"
      FROM transactions t
      JOIN users u ON t.user_id = u.id
      WHERE t.influencer_id = $1
      ORDER BY t.created_at DESC
      LIMIT 10
    `, [influencer.id]);

    res.status(200).json({
      success: true,
      data: {
        stats: influencer,
        recentTransactions: transRes.rows
      }
    });

  } catch (error) {
    console.error('Get dashboard stats error:', error);
    res.status(500).json({ success: false, message: 'Error al obtener estadísticas' });
  }
};
