const db = require('../config/db');

class UserRepository {
  async findByEmail(email) {
    const result = await db.query(
      'SELECT id, email, password_hash, name, status FROM users WHERE email = $1',
      [email]
    );
    return result.rows[0];
  }

  async findById(id) {
    const result = await db.query(
      'SELECT id, email, name, status FROM users WHERE id = $1',
      [id]
    );
    return result.rows[0];
  }

  async create({ email, passwordHash, name, phone, dateOfBirth, ageConfirmed, termsAccepted, privacyAccepted }) {
    const result = await db.query(
      `INSERT INTO users (email, password_hash, name, phone, date_of_birth, age_confirmed, terms_accepted, privacy_accepted)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
       RETURNING id, email`,
      [email, passwordHash, name, phone, dateOfBirth, ageConfirmed, termsAccepted, privacyAccepted]
    );
    return result.rows[0];
  }

  async emailExists(email) {
    const result = await db.query('SELECT id FROM users WHERE email = $1', [email]);
    return result.rows.length > 0;
  }

  async updateStatus(id, status) {
    await db.query('UPDATE users SET status = $1 WHERE id = $2', [status, id]);
  }
}

module.exports = new UserRepository();