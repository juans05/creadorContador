const { pool } = require('../config/db');
const culqiService = require('../services/culqiService');

const diamondPackages = {
  50: 9.99,
  150: 24.99,
  350: 49.99,
  1000: 129.99
};

exports.getBalance = async (req, res) => {
  const userId = req.user.userId;

  try {
    let result = await pool.query(
      'SELECT balance, total_spent, total_earned, last_updated FROM diamonds_balance WHERE user_id = $1',
      [userId]
    );

    if (result.rows.length === 0) {
      await pool.query(
        'INSERT INTO diamonds_balance (user_id, balance) VALUES ($1, 0)',
        [userId]
      );
      result = await pool.query(
        'SELECT balance, total_spent, total_earned, last_updated FROM diamonds_balance WHERE user_id = $1',
        [userId]
      );
    }

    res.status(200).json({
      success: true,
      data: {
        balance: result.rows[0].balance,
        totalSpent: result.rows[0].total_spent,
        totalEarned: result.rows[0].total_earned,
        lastUpdated: result.rows[0].last_updated
      }
    });
  } catch (error) {
    console.error('Get balance error:', error);
    res.status(500).json({ success: false, message: 'Error al obtener balance' });
  }
};

exports.purchaseDiamonds = async (req, res) => {
  const { packageSize, source_id } = req.body;
  const userId = req.user.userId;
  const email = req.user.email;

  const price = diamondPackages[packageSize];
  if (!price) return res.status(400).json({ success: false, message: 'Paquete inválido' });

  try {
    let culqiTransactionId = 'culqi_mock_txn_diamond_' + Date.now();

    if (source_id) {
       const charge = await culqiService.createCharge({ 
         amount: Math.round(price * 100), 
         currency_code: 'PEN', 
         email, 
         source_id, 
         description: `Compra de ${packageSize} diamantes` 
       });
       culqiTransactionId = charge.id;
    }

    await pool.query(`
      INSERT INTO transactions (user_id, amount, type, status, culqi_transaction_id, payment_method, description, processed_at)
      VALUES ($1, $2, 'diamond_purchase', 'completed', $3, 'culqi', $4, CURRENT_TIMESTAMP)
    `, [userId, price, culqiTransactionId, `Compra de ${packageSize} diamantes`]);

    await pool.query(`
      INSERT INTO diamond_purchases (user_id, package_size, price_soles, diamonds_received, status, culqi_transaction_id, completed_at)
      VALUES ($1, $2, $3, $4, 'completed', $5, CURRENT_TIMESTAMP)
    `, [userId, packageSize, price, packageSize, culqiTransactionId]);

    await pool.query(`
      INSERT INTO diamonds_balance (user_id, balance)
      VALUES ($1, $2)
      ON CONFLICT (user_id) DO UPDATE SET balance = diamonds_balance.balance + EXCLUDED.balance
    `, [userId, packageSize]);

    res.status(201).json({ success: true, data: { packageSize, priceSoles: price, status: 'completed' }});
  } catch (error) {
    console.error('Diamond purchase error:', error);
    res.status(500).json({ success: false, message: 'Error procesando compra' });
  }
};

exports.spendDiamonds = async (req, res) => {
  const { contentId, diamondAmount } = req.body;
  const userId = req.user.userId;

  try {
    const photoRes = await pool.query('SELECT influencer_id FROM photos WHERE id = $1', [contentId]);
    if (photoRes.rows.length === 0) return res.status(404).json({ success: false, message: 'Contenido no encontrado' });
    const influencerId = photoRes.rows[0].influencer_id;

    const checkBought = await pool.query('SELECT id FROM user_diamond_purchases WHERE user_id = $1 AND content_id = $2', [userId, contentId]);
    if (checkBought.rows.length > 0) return res.status(409).json({ success: false, error: 'CONTENT_ALREADY_PURCHASED', message: 'Ya desbloqueaste este contenido' });

    const balRes = await pool.query('SELECT balance FROM diamonds_balance WHERE user_id = $1', [userId]);
    const balance = balRes.rows[0]?.balance || 0;

    if (balance < diamondAmount) return res.status(400).json({ success: false, message: 'Diamantes insuficientes' });

    await pool.query('UPDATE diamonds_balance SET balance = balance - $1, total_spent = total_spent + $1 WHERE user_id = $2', [diamondAmount, userId]);

    await pool.query(`
      INSERT INTO user_diamond_purchases (user_id, content_id, influencer_id, diamonds_spent)
      VALUES ($1, $2, $3, $4)
    `, [userId, contentId, influencerId, diamondAmount]);

    const creatorEarnedSoles = diamondAmount * 0.08; // 1 diamante = S/ 0.10 -> 80% para el creador
    await pool.query('UPDATE influencers SET total_earnings_soles = total_earnings_soles + $1, total_earnings_today = total_earnings_today + $1 WHERE id = $2', [creatorEarnedSoles, influencerId]);

    res.status(200).json({ success: true, data: { contentId, diamondsSpent: diamondAmount, diamondsRemaining: balance - diamondAmount, contentUnlocked: true, creatorEarnedSoles }});
  } catch (error) {
    console.error('Spend diamond error:', error);
    res.status(500).json({ success: false, message: 'Error al procesar gasto de diamantes' });
  }
};

exports.convertDiamonds = async (req, res) => {
  const { diamondsAmount } = req.body;
  const userId = req.user.userId;

  if (diamondsAmount < 100) return res.status(400).json({ success: false, message: 'El mínimo de conversión es 100 diamantes' });

  try {
    const infRes = await pool.query('SELECT id, yape_id_encrypted FROM influencers WHERE user_id = $1', [userId]);
    if (infRes.rows.length === 0) return res.status(403).json({ success: false, message: 'Solo creadoras pueden convertir diamantes' });
    const influencer = infRes.rows[0];

    const amountSoles = diamondsAmount * 0.10; // 1 diamante = S/ 0.10

    // Para el MVP, asumimos que tiene los diamantes. Lo ideal es descontar de su balance de diamantes ganados.
    const culqiTransferId = 'culqi_mock_transfer_' + Date.now();

    // 1. Llamar a Culqi Transfer si tuviéramos un destination_id real
    /* 
    const transfer = await culqiService.createTransfer({
      amount: Math.round(amountSoles * 100),
      destination_id: Buffer.from(influencer.yape_id_encrypted, 'base64').toString('ascii'),
      description: 'Conversión de diamantes'
    });
    */

    // 2. Registrar conversión
    const convResult = await pool.query(`
      INSERT INTO diamond_conversions (influencer_id, diamonds_converted, amount_soles, status, culqi_transfer_id, processed_at)
      VALUES ($1, $2, $3, 'processing', $4, CURRENT_TIMESTAMP)
      RETURNING id
    `, [influencer.id, diamondsAmount, amountSoles, culqiTransferId]);

    res.status(201).json({
      success: true,
      data: {
        conversionId: convResult.rows[0].id,
        diamondsConverted: diamondsAmount,
        amountSoles: amountSoles,
        status: 'pending',
        estimatedProcessing: new Date(Date.now() + 5 * 60000) // 5 minutos aprox
      }
    });

  } catch (error) {
    console.error('Convert diamond error:', error);
    res.status(500).json({ success: false, message: 'Error procesando conversión' });
  }
};
