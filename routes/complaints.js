// church-management-backend/routes/complaints.js
const express = require('express');
const router = express.Router();
const db = require('../config/database');

router.get('/', async (req, res) => {
  try {
    const [complaints] = await db.query(`
      SELECT 
        c.complaint_id,
        u.name AS complainant,
        c.title,
        c.body,
        cs.name AS status,
        c.created_at
      FROM complaints c
      JOIN users u ON c.user_id = u.user_id
      JOIN complaint_statuses cs ON c.status_id = cs.complaint_status_id
      ORDER BY c.created_at DESC
    `);
    
    res.json({ success: true, data: complaints });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

router.get('/:id', async (req, res) => {
  try {
    const [complaints] = await db.query(`
      SELECT 
        c.complaint_id,
        u.name AS complainant,
        c.title,
        c.body,
        cs.name AS status,
        c.created_at
      FROM complaints c
      JOIN users u ON c.user_id = u.user_id
      JOIN complaint_statuses cs ON c.status_id = cs.complaint_status_id
      WHERE c.complaint_id = ?
    `, [req.params.id]);
    
    if (complaints.length === 0) {
      return res.status(404).json({ success: false, error: 'Complaint not found' });
    }
    
    res.json({ success: true, data: complaints[0] });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

router.post('/', async (req, res) => {
  try {
    const { user_id, booking_id, title, body } = req.body;
    
    // Get OPEN status
    const [status] = await db.query(
      'SELECT complaint_status_id FROM complaint_statuses WHERE name = ?',
      ['OPEN']
    );
    
    const [result] = await db.query(
      `INSERT INTO complaints (user_id, booking_id, title, body, status_id)
       VALUES (?, ?, ?, ?, ?)`,
      [user_id, booking_id, title, body, status[0].complaint_status_id]
    );
    
    res.status(201).json({
      success: true,
      complaint_id: result.insertId
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

router.put('/:id/status', async (req, res) => {
  try {
    const { status } = req.body;
    
    // Get status ID
    const [statusRows] = await db.query(
      'SELECT complaint_status_id FROM complaint_statuses WHERE name = ?',
      [status]
    );
    
    if (statusRows.length === 0) {
      return res.status(400).json({ success: false, error: 'Invalid status' });
    }
    
    const [result] = await db.query(
      'UPDATE complaints SET status_id = ? WHERE complaint_id = ?',
      [statusRows[0].complaint_status_id, req.params.id]
    );
    
    if (result.affectedRows === 0) {
      return res.status(404).json({ success: false, error: 'Complaint not found' });
    }
    
    res.json({ success: true, message: 'Complaint status updated' });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

router.get('/user/:userId', async (req, res) => {
  try {
    const [complaints] = await db.query(`
      SELECT 
        c.complaint_id,
        c.title,
        c.body,
        cs.name AS status,
        c.created_at
      FROM complaints c
      JOIN complaint_statuses cs ON c.status_id = cs.complaint_status_id
      WHERE c.user_id = ?
      ORDER BY c.created_at DESC
    `, [req.params.userId]);
    
    res.json({ success: true, data: complaints });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

module.exports = router;