const { pool } = require('../config/db');
const culqiService = require('../services/culqiService');

exports.createSubscription = async (req, res) => {
  const { influencerId, planType, source_id } = req.body; // source_id es el token generado por culqi.js en el frontend
  const userId = req.user.userId;
  const email = req.user.email;

  const planPricing = {
    basic: 9.99,
    premium: 19.99,
    vip: 49.99
  };

  if (!planPricing[planType]) {
    return res.status(400).json({ success: false, message: 'Plan inválido' });
  }

  const amount = planPricing[planType];

  try {
    let culqiTransactionId = 'culqi_mock_txn_' + Date.now();
    
    // Si envían source_id, procesamos el pago real con la API de Culqi
    if (source_id) {
       const charge = await culqiService.createCharge({ 
         amount: Math.round(amount * 100), // Culqi usa céntimos
         currency_code: 'PEN', 
         email, 
         source_id, 
         description: 'Suscripción ' + planType 
       });
       culqiTransactionId = charge.id;
    }

    // 2. Registrar transacción
    const insertTxQuery = `
      INSERT INTO transactions (user_id, influencer_id, amount, type, status, culqi_transaction_id, payment_method, description, processed_at)
      VALUES ($1, $2, $3, 'subscription', 'completed', $4, 'culqi', $5, CURRENT_TIMESTAMP)
    `;
    await pool.query(insertTxQuery, [userId, influencerId, amount, culqiTransactionId, `Suscripción ${planType}`]);

    // 3. Crear o actualizar suscripción (Expira en 1 mes)
    const expireDate = new Date();
    expireDate.setMonth(expireDate.getMonth() + 1);

    const upsertSubQuery = `
      INSERT INTO subscriptions (user_id, influencer_id, plan_type, amount, expires_at, active)
      VALUES ($1, $2, $3, $4, $5, true)
      ON CONFLICT (user_id, influencer_id)
      DO UPDATE SET plan_type = EXCLUDED.plan_type, amount = EXCLUDED.amount, expires_at = EXCLUDED.expires_at, active = true
      RETURNING id
    `;
    const subResult = await pool.query(upsertSubQuery, [userId, influencerId, planType, amount, expireDate]);

    // 4. Actualizar ganancias de creadora (Asumimos que el 80% va para ella)
    await pool.query('UPDATE influencers SET total_earnings_soles = total_earnings_soles + $1, total_earnings_today = total_earnings_today + $1 WHERE id = $2', [amount * 0.8, influencerId]);

    res.status(201).json({
      success: true,
      data: {
        subscriptionId: subResult.rows[0].id,
        influencerId,
        planType,
        amount,
        status: 'active',
        expiresAt: expireDate
      }
    });

  } catch (error) {
    console.error('Subscription error:', error);
    res.status(500).json({ success: false, message: 'Error procesando suscripción. Verifique su método de pago.' });
  }
};
