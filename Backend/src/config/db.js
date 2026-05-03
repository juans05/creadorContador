const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  // Desactivamos SSL ya que el servidor remoto no lo soporta
  ssl: false
});

module.exports = {
  query: (text, params) => pool.query(text, params),
  pool
};
