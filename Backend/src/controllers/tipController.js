const { pool } = require('../config/db');
const culqiService = require('../services/culqiService');

/**
 * RF-010: TIPS / PROPINAS
 * Maneja el envío de propinas directas en Soles o Diamantes.
 */
exports.sendTip = async (req, res) => {
  const { influencerId, amount, type, source_id } = req.body; // type: 'cash' | 'diamonds'
  const userId = req.user.userId;
  const email = req.user.email;

  if (!amount || amount <= 0) {
    return res.status(400).json({ success: false, message: 'Monto inválido' });
  }

  try {
    // Verificar que el influencer existe
    const influencerRes = await pool.query('SELECT id, user_id FROM influencers WHERE id = $1', [influencerId]);
    if (influencerRes.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Creadora no encontrada' });
    }

    if (type === 'cash') {
      // --- PROPINA EN SOLES (Vía Culqi) ---
      if (!source_id) {
        return res.status(400).json({ success: false, message: 'Se requiere un método de pago (token)' });
      }

      // Procesar cargo en Culqi
      const charge = await culqiService.createCharge({
        amount: Math.round(amount * 100), // En céntimos
        currency_code: 'PEN',
        email,
        source_id,
        description: `Propina para creadora ID: ${influencerId}`
      });

      // Registrar transacción
      await pool.query(`
        INSERT INTO transactions (user_id, influencer_id, amount, type, status, culqi_transaction_id, payment_method, description, processed_at)
        VALUES ($1, $2, $3, 'tip', 'completed', $4, 'culqi', $5, CURRENT_TIMESTAMP)
      `, [userId, influencerId, amount, charge.id, 'Propina en Soles']);

      // Abonar a la creadora (80%)
      const creatorNet = amount * 0.8;
      await pool.query(`
        UPDATE influencers 
        SET total_earnings_soles = total_earnings_soles + $1, 
            total_earnings_today = total_earnings_today + $1 
        WHERE id = $2
      `, [creatorNet, influencerId]);

      return res.status(200).json({ success: true, message: 'Propina enviada exitosamente', data: { amount, type: 'cash' } });

    } else if (type === 'diamonds') {
      // --- PROPINA EN DIAMANTES ---
      // 1. Verificar balance del usuario
      const balRes = await pool.query('SELECT balance FROM diamonds_balance WHERE user_id = $1', [userId]);
      const currentBalance = balRes.rows[0]?.balance || 0;

      if (currentBalance < amount) {
        return res.status(400).json({ success: false, message: 'Diamantes insuficientes' });
      }

      // 2. Descontar del usuario
      await pool.query(`
        UPDATE diamonds_balance 
        SET balance = balance - $1, total_spent = total_spent + $1 
        WHERE user_id = $2
      `, [amount, userId]);

      // 3. Registrar transacción
      await pool.query(`
        INSERT INTO transactions (user_id, influencer_id, amount, type, status, payment_method, description, processed_at)
        VALUES ($1, $2, $3, 'tip', 'completed', 'diamonds', $4, CURRENT_TIMESTAMP)
      `, [userId, influencerId, amount, 'Propina en Diamantes']);

      // 4. Abonar a la creadora (80% del valor en Soles: 1 diamante = S/ 0.10)
      const creatorNetSoles = (amount * 0.10) * 0.8;
      await pool.query(`
        UPDATE influencers 
        SET total_earnings_soles = total_earnings_soles + $1, 
            total_earnings_today = total_earnings_today + $1 
        WHERE id = $2
      `, [creatorNetSoles, influencerId]);

      return res.status(200).json({ success: true, message: 'Propina enviada exitosamente', data: { amount, type: 'diamonds' } });

    } else {
      return res.status(400).json({ success: false, message: 'Tipo de propina no soportado' });
    }

  } catch (error) {
    console.error('Error enviando propina:', error);
    res.status(500).json({ success: false, message: 'Error interno del servidor al procesar la propina' });
  }
};
