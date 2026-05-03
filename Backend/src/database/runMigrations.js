require('dotenv').config();
const fs = require('fs');
const path = require('path');
const { pool } = require('../config/db');

async function run() {
  try {
    console.log(`Conectando a la base de datos...`);
    const sqlPath = path.join(__dirname, 'init.sql');
    const sql = fs.readFileSync(sqlPath, 'utf8');
    
    console.log('Ejecutando init.sql...');
    await pool.query(sql);
    console.log('¡Base de datos inicializada exitosamente con las 14 tablas!');
  } catch (error) {
    console.error('Error inicializando la base de datos:', error);
  } finally {
    await pool.end();
  }
}

run();
