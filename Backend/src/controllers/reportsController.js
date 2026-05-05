const { pool } = require('../config/db');

exports.reportUser = async (req, res) => {
  const { targetUserId, targetInfluencerId, contentId, reason, description } = req.body;
  const reporterId = req.user.userId;

  if (!targetUserId && !targetInfluencerId && !contentId) {
    return res.status(400).json({ success: false, message: 'Debe especificar usuario, influencer o contenido a reportar' });
  }

  if (!reason) {
    return res.status(400).json({ success: false, message: 'Razón requerida' });
  }

  const validReasons = ['spam', 'harassment', 'inappropriate_content', 'fake_profile', 'other'];
  if (!validReasons.includes(reason)) {
    return res.status(400).json({ success: false, message: 'Razón inválida' });
  }

  try {
    const contentType = contentId ? (await getContentType(contentId)) : null;

    const result = await pool.query(
      `INSERT INTO reports (reporter_id, reported_user_id, reported_influencer_id, content_id, content_type, reason, description)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       RETURNING id`,
      [reporterId, targetUserId || null, targetInfluencerId || null, contentId || null, contentType, reason, description || null]
    );

    res.status(201).json({
      success: true,
      message: 'Reporte enviado. Gracias por tu colaboración.',
      data: { reportId: result.rows[0].id }
    });
  } catch (error) {
    console.error('Report error:', error);
    res.status(500).json({ success: false, message: 'Error al enviar reporte' });
  }
};

async function getContentType(contentId) {
  const photo = await pool.query('SELECT id FROM photos WHERE id = $1', [contentId]);
  if (photo.rows.length > 0) return 'photo';

  const video = await pool.query('SELECT id FROM videos WHERE id = $1', [contentId]);
  if (video.rows.length > 0) return 'video';

  return null;
}