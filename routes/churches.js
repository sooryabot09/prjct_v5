// routes/churches.js
const express = require('express');
const router = express.Router();
const db = require('../config/database');

// GET all churches
router.get('/', async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT 
        c.church_id, c.name, c.address, c.phone,
        f.name AS forane_name, d.name AS diocese_name
      FROM churches c
      JOIN foranes f ON c.forane_id = f.forane_id
      JOIN dioceses d ON f.diocese_id = d.diocese_id
      ORDER BY c.name
    `);
    
    res.json({ success: true, data: rows });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// GET church by ID
router.get('/:id', async (req, res) => {
  try {
    const [rows] = await db.query(
      'SELECT * FROM churches WHERE church_id = ?',
      [req.params.id]
    );
    
    if (rows.length === 0) {
      return res.status(404).json({ success: false, error: 'Church not found' });
    }
    
    res.json({ success: true, data: rows[0] });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// GET services by church
router.get('/:id/services', async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT 
        service_id, name, description,
        amount_paise / 100 AS amount_rupees
      FROM services
      WHERE church_id = ?
    `, [req.params.id]);
    
    res.json({ success: true, data: rows });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

module.exports = router;