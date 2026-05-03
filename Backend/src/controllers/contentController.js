const { pool } = require('../config/db');
const cloudinaryService = require('../services/cloudinaryService');
const fs = require('fs');

// POST /api/content/upload
exports.uploadContent = async (req, res) => {
  const userId = req.user.userId;
  const { description, visibility, ppvPrice, mediaType } = req.body;

  if (!req.file) {
    return res.status(400).json({ success: false, message: 'Ningún archivo enviado' });
  }

  try {
    // 1. Verificar si es creadora
    const infRes = await pool.query('SELECT id FROM influencers WHERE user_id = $1', [userId]);
    if (infRes.rows.length === 0) {
      fs.unlinkSync(req.file.path);
      return res.status(403).json({ success: false, message: 'Solo las creadoras pueden subir contenido' });
    }
    const influencerId = infRes.rows[0].id;

    const finalVisibility = visibility || 'public';
    const finalPrice = finalVisibility === 'ppv' ? (parseInt(ppvPrice, 10) || 50) : null;
    const isVideo = req.file.mimetype.startsWith('video/');

    // 2. Determinar tipo de recurso para Cloudinary
    const resourceType = isVideo ? 'video' : 'image';
    
    // 2. Subir a Cloudinary dentro de la carpeta luxor_content
    const result = await cloudinaryService.uploadFile(req.file.path, 'luxor_content', resourceType);

    // 3. Eliminar archivo temporal local
    fs.unlinkSync(req.file.path);

    // 4. Determinar tabla y tipo de contenido
    if (isVideo) {
      // Guardar en tabla de videos
      const insertVideoQuery = `
        INSERT INTO videos (influencer_id, url, cloudinary_public_id, description, visibility, ppv_price_diamonds, duration)
        VALUES ($1, $2, $3, $4, $5, $6, $7)
        RETURNING id, url, visibility, 'video' as content_type
      `;
      const videoResult = await pool.query(insertVideoQuery, [
        influencerId,
        result.secure_url,
        result.public_id,
        description,
        finalVisibility,
        finalPrice,
        result.duration || null
      ]);

      return res.status(201).json({
        success: true,
        message: 'Video subido exitosamente',
        data: videoResult.rows[0]
      });
    } else {
      // Guardar en tabla de fotos
      const insertPhotoQuery = `
        INSERT INTO photos (influencer_id, url, thumbnail_url, cloudinary_public_id, description, visibility, ppv_price_diamonds)
        VALUES ($1, $2, $3, $4, $5, $6, $7)
        RETURNING id, url, visibility, 'photo' as content_type
      `;
      const photoResult = await pool.query(insertPhotoQuery, [
        influencerId,
        result.secure_url,
        result.secure_url, 
        result.public_id,
        description,
        finalVisibility,
        finalPrice
      ]);

      return res.status(201).json({
        success: true,
        message: 'Foto subida exitosamente',
        data: photoResult.rows[0]
      });
    }

  } catch (error) {
    console.error('Upload error:', error);
    if (req.file && fs.existsSync(req.file.path)) {
       fs.unvokeSync(req.file.path);
    }
    res.status(500).json({ success: false, message: 'Error interno al subir contenido' });
  }
};

// GET /api/content/my - Obtener contenido de la creadora
exports.getMyContent = async (req, res) => {
  const userId = req.user.userId;

  try {
    const infRes = await pool.query('SELECT id FROM influencers WHERE user_id = $1', [userId]);
    if (infRes.rows.length === 0) {
      return res.status(403).json({ success: false, message: 'Solo las creadoras pueden ver contenido' });
    }
    const influencerId = infRes.rows[0].id;

    // Obtener fotos
    const photosRes = await pool.query(`
      SELECT id, url, thumbnail_url, description, visibility, ppv_price_diamonds, created_at, 'photo' as content_type
      FROM photos 
      WHERE influencer_id = $1 
      ORDER BY created_at DESC
    `, [influencerId]);

    // Obtener videos
    const videosRes = await pool.query(`
      SELECT id, url, description, visibility, ppv_price_diamonds, duration, created_at, 'video' as content_type
      FROM videos 
      WHERE influencer_id = $1 
      ORDER BY created_at DESC
    `, [influencerId]);

    // Combinar y ordenar
    const allContent = [...photosRes.rows, ...videosRes.rows].sort((a, b) => 
      new Date(b.created_at) - new Date(a.created_at)
    );

    res.status(200).json({
      success: true,
      data: allContent
    });

  } catch (error) {
    console.error('Get content error:', error);
    res.status(500).json({ success: false, message: 'Error al obtener contenido' });
  }
};

// DELETE /api/content/:id - Eliminar contenido
exports.deleteContent = async (req, res) => {
  const userId = req.user.userId;
  const { id } = req.params;
  const { type } = req.query; // 'photo' o 'video'

  try {
    const infRes = await pool.query('SELECT id FROM influencers WHERE user_id = $1', [userId]);
    if (infRes.rows.length === 0) {
      return res.status(403).json({ success: false, message: 'Solo las creadoras pueden eliminar contenido' });
    }
    const influencerId = infRes.rows[0].id;

    // Verificar que el contenido pertenece a la creadora
    let checkQuery, deleteQuery, publicIdRes;
    
    if (type === 'video') {
      checkQuery = 'SELECT cloudinary_public_id FROM videos WHERE id = $1 AND influencer_id = $2';
      deleteQuery = 'DELETE FROM videos WHERE id = $1 AND influencer_id = $2';
    } else {
      checkQuery = 'SELECT cloudinary_public_id FROM photos WHERE id = $1 AND influencer_id = $2';
      deleteQuery = 'DELETE FROM photos WHERE id = $1 AND influencer_id = $2';
    }

    const checkRes = await pool.query(checkQuery, [id, influencerId]);
    if (checkRes.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Contenido no encontrado' });
    }

    // Eliminar de Cloudinary
    const publicId = checkRes.rows[0].cloudinary_public_id;
    await cloudinaryService.deleteFile(publicId, type === 'video' ? 'video' : 'image');

    // Eliminar de la base de datos
    await pool.query(deleteQuery, [id, influencerId]);

    res.status(200).json({
      success: true,
      message: 'Contenido eliminado exitosamente'
    });

  } catch (error) {
    console.error('Delete content error:', error);
    res.status(500).json({ success: false, message: 'Error al eliminar contenido' });
  }
};