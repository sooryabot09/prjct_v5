// routes/users.js
const express = require('express');
const router = express.Router();
const db = require('../config/database');

// GET all users
router.get('/', async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT 
        u.user_id, u.name, u.email, u.phone,
        ur.name AS role, c.name AS church_name
      FROM users u
      JOIN user_roles ur ON u.role_id = ur.role_id
      LEFT JOIN churches c ON u.church_id = c.church_id
    `);
    
    res.json({ success: true, data: rows });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// GET user by ID
router.get('/:id', async (req, res) => {
  try {
    const [rows] = await db.query(
      'SELECT * FROM users WHERE user_id = ?',
      [req.params.id]
    );
    
    if (rows.length === 0) {
      return res.status(404).json({ success: false, error: 'User not found' });
    }
    
    res.json({ success: true, data: rows[0] });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

module.exports = router;