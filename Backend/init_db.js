require('dotenv').config();
const fs = require('fs');
const path = require('path');
const { pool } = require('./src/config/db');

async function inicializarBaseDeDatos() {
  try {
    console.log('🚀 Iniciando conexión con PostgreSQL (Esquema: luxordb)...');
    
    // 1. Asegurar que estamos usando el esquema correcto
    await pool.query('SET search_path TO luxordb, public');
    console.log('📍 Esquema configurado a "luxordb"');

    // 2. Leemos el archivo SQL
    const sqlPath = path.join(__dirname, 'src', 'database', 'init.sql');
    let sql = fs.readFileSync(sqlPath, 'utf8');

    // 3. Optimizamos el SQL para evitar errores si ya existen las tablas o índices
    sql = sql.replace(/CREATE TABLE /g, 'CREATE TABLE IF NOT EXISTS ');
    sql = sql.replace(/CREATE INDEX /g, 'CREATE INDEX IF NOT EXISTS ');
    sql = sql.replace(/CREATE UNIQUE INDEX /g, 'CREATE UNIQUE INDEX IF NOT EXISTS ');

    console.log('📡 Ejecutando scripts de creación de tablas en luxordb...');
    
    // 4. Ejecutamos el SQL completo
    await pool.query(sql);

    console.log('✅ ¡Tablas creadas o verificadas exitosamente!');
    
    // 5. Verificación final: listar las tablas creadas en el esquema luxordb
    const res = await pool.query(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'luxordb'
      ORDER BY table_name;
    `);
    
    if (res.rows.length === 0) {
      console.log('⚠️ No se encontraron tablas en "luxordb". Verificando en "public"...');
      const resPublic = await pool.query("SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'");
      console.log('Tablas en public:', resPublic.rows.map(r => r.table_name));
    } else {
      console.log('\n📊 Resumen de tablas en el esquema "luxordb":');
      console.table(res.rows);
    }

  } catch (error) {
    console.error('❌ Error crítico al inicializar la base de datos:', error.message);
  } finally {
    await pool.end();
    console.log('🔌 Conexión cerrada.');
  }
}

inicializarBaseDeDatos();
