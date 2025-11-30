// church-management-backend/controllers/transactionController.js
const db = require('../config/database');

exports.getAllTransactions = async (req, res) => {
  try {
    const { church_id, method_id, status_id, start_date, end_date } = req.query;
    
    let query = `
      SELECT 
        t.transaction_id,
        t.amount_paise / 100 AS amount_rupees,
        t.razorpay_order_id,
        t.razorpay_payment_id,
        t.proof_url,
        t.recorded_at,
        t.created_at,
        pm.name AS payment_method,
        ts.name AS status,
        b.booking_id,
        s.name AS service_name,
        u.name AS parishioner_name,
        c.name AS church_name,
        rec.name AS recorded_by_name
      FROM transactions t
      JOIN payment_methods pm ON t.method_id = pm.payment_method_id
      JOIN transaction_statuses ts ON t.status_id = ts.transaction_status_id
      LEFT JOIN bookings b ON t.booking_id = b.booking_id
      LEFT JOIN services s ON b.service_id = s.service_id
      LEFT JOIN users u ON b.parishioner_id = u.user_id
      JOIN churches c ON t.church_id = c.church_id
      LEFT JOIN users rec ON t.recorded_by = rec.user_id
      WHERE 1=1
    `;
    
    const params = [];
    
    if (church_id) {
      query += ' AND t.church_id = ?';
      params.push(church_id);
    }
    if (method_id) {
      query += ' AND t.method_id = ?';
      params.push(method_id);
    }
    if (status_id) {
      query += ' AND t.status_id = ?';
      params.push(status_id);
    }
    if (start_date) {
      query += ' AND t.created_at >= ?';
      params.push(start_date);
    }
    if (end_date) {
      query += ' AND t.created_at <= ?';
      params.push(end_date);
    }
    
    query += ' ORDER BY t.created_at DESC';
    
    const [rows] = await db.query(query, params);
    
    res.json({ success: true, count: rows.length, data: rows });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

exports.getTransactionById = async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT 
        t.*,
        pm.name AS payment_method,
        ts.name AS status,
        b.booking_id,
        s.name AS service_name,
        c.name AS church_name
      FROM transactions t
      JOIN payment_methods pm ON t.method_id = pm.payment_method_id
      JOIN transaction_statuses ts ON t.status_id = ts.transaction_status_id
      LEFT JOIN bookings b ON t.booking_id = b.booking_id
      LEFT JOIN services s ON b.service_id = s.service_id
      JOIN churches c ON t.church_id = c.church_id
      WHERE t.transaction_id = ?
    `, [req.params.id]);
    
    if (rows.length === 0) {
      return res.status(404).json({ success: false, error: 'Transaction not found' });
    }
    
    // Get split details
    const [splits] = await db.query(`
      SELECT 
        bt.name AS beneficiary,
        sc.percentage,
        (t.amount_paise * sc.percentage / 100) / 100 AS amount_rupees
      FROM split_config sc
      JOIN beneficiary_types bt ON sc.beneficiary_type_id = bt.beneficiary_type_id
      JOIN bookings b ON b.booking_id = ?
      JOIN transactions t ON t.transaction_id = ?
      WHERE sc.service_id = b.service_id
    `, [rows[0].booking_id, req.params.id]);
    
    rows[0].splits = splits;
    
    res.json({ success: true, data: rows[0] });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

exports.createTransaction = async (req, res) => {
  try {
    const {
      booking_id,
      church_id,
      amount_paise,
      method_id,
      status_id,
      razorpay_order_id,
      razorpay_payment_id,
      gateway_response,
      proof_url,
      recorded_by
    } = req.body;
    
    const [result] = await db.query(`
      INSERT INTO transactions (
        booking_id, church_id, amount_paise, method_id, status_id,
        razorpay_order_id, razorpay_payment_id, gateway_response,
        proof_url, recorded_by, recorded_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())
    `, [
      booking_id, church_id, amount_paise, method_id, status_id,
      razorpay_order_id, razorpay_payment_id, 
      gateway_response ? JSON.stringify(gateway_response) : null,
      proof_url, recorded_by
    ]);
    
    res.status(201).json({
      success: true,
      message: 'Transaction created successfully',
      transaction_id: result.insertId
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

exports.updateTransactionStatus = async (req, res) => {
  try {
    const { status } = req.body;
    
    // Get status ID
    const [statusRows] = await db.query(
      'SELECT transaction_status_id FROM transaction_statuses WHERE name = ?',
      [status]
    );
    
    if (statusRows.length === 0) {
      return res.status(400).json({ success: false, error: 'Invalid status' });
    }
    
    const [result] = await db.query(
      'UPDATE transactions SET status_id = ? WHERE transaction_id = ?',
      [statusRows[0].transaction_status_id, req.params.id]
    );
    
    if (result.affectedRows === 0) {
      return res.status(404).json({ success: false, error: 'Transaction not found' });
    }
    
    res.json({ success: true, message: 'Transaction status updated' });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

exports.getTransactionsByChurch = async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT 
        t.transaction_id,
        t.amount_paise / 100 AS amount_rupees,
        pm.name AS payment_method,
        ts.name AS status,
        t.created_at
      FROM transactions t
      JOIN payment_methods pm ON t.method_id = pm.payment_method_id
      JOIN transaction_statuses ts ON t.status_id = ts.transaction_status_id
      WHERE t.church_id = ?
      ORDER BY t.created_at DESC
    `, [req.params.churchId]);
    
    res.json({ success: true, data: rows });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

exports.getPendingReviews = async (req, res) => {
  try {
    const { church_id } = req.query;
    
    let query = `
      SELECT 
        t.transaction_id,
        t.amount_paise / 100 AS amount_rupees,
        pm.name AS payment_method,
        u.name AS parishioner,
        s.name AS service,
        c.name AS church,
        t.proof_url,
        t.recorded_at
      FROM transactions t
      JOIN payment_methods pm ON t.method_id = pm.payment_method_id
      JOIN transaction_statuses ts ON t.status_id = ts.transaction_status_id
      LEFT JOIN bookings b ON t.booking_id = b.booking_id
      LEFT JOIN services s ON b.service_id = s.service_id
      LEFT JOIN users u ON b.parishioner_id = u.user_id
      JOIN churches c ON t.church_id = c.church_id
      WHERE ts.name = 'PENDING_REVIEW'
    `;
    
    const params = [];
    
    if (church_id) {
      query += ' AND t.church_id = ?';
      params.push(church_id);
    }
    
    query += ' ORDER BY t.recorded_at DESC';
    
    const [rows] = await db.query(query, params);
    
    res.json({ success: true, data: rows });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};