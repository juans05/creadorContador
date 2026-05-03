require('dotenv').config();
const { pool } = require('./src/config/db');

async function fixDatabase() {
  try {
    console.log('Verificando y creando tablas faltantes...');
    
    // Tabla videos
    await pool.query(`
      CREATE TABLE IF NOT EXISTS videos (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        influencer_id UUID NOT NULL REFERENCES influencers(id) ON DELETE CASCADE,
        url VARCHAR(500) NOT NULL,
        thumbnail_url VARCHAR(500),
        cloudinary_public_id VARCHAR(500),
        description TEXT,
        visibility VARCHAR(20) DEFAULT 'public' CHECK (visibility IN ('public', 'subscribers', 'ppv')),
        ppv_price_diamonds INT,
        duration INT,
        views_count INT DEFAULT 0,
        likes_count INT DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('Tabla "videos" verificada/creada.');

    // Verificar si photos necesita actualización (likes_count, updated_at)
    const res = await pool.query(`
      SELECT column_name 
      FROM information_schema.columns 
      WHERE table_name = 'photos' AND column_name = 'likes_count'
    `);
    
    if (res.rows.length === 0) {
      await pool.query(`ALTER TABLE photos ADD COLUMN IF NOT EXISTS likes_count INT DEFAULT 0`);
      await pool.query(`ALTER TABLE photos ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP`);
      console.log('Columnas faltantes añadidas a "photos".');
    }

    console.log('¡Base de datos actualizada correctamente!');
  } catch (error) {
    console.error('Error:', error);
  } finally {
    await pool.end();
  }
}

fixDatabase();
