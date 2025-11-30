const db = require('../config/database');

exports.getAllChurches = async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT 
        c.church_id, c.name, c.address, c.phone,
        c.bank_account, c.qr_code_url,
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
};

exports.getChurchById = async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT 
        c.*, f.name AS forane_name, d.name AS diocese_name
      FROM churches c
      JOIN foranes f ON c.forane_id = f.forane_id
      JOIN dioceses d ON f.diocese_id = d.diocese_id
      WHERE c.church_id = ?
    `, [req.params.id]);
    
    if (rows.length === 0) {
      return res.status(404).json({ success: false, error: 'Church not found' });
    }
    
    res.json({ success: true, data: rows[0] });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

exports.getChurchServices = async (req, res) => {
  try {
    const [services] = await db.query(`
      SELECT 
        service_id, name, description,
        amount_paise / 100 AS amount_rupees
      FROM services
      WHERE church_id = ?
    `, [req.params.id]);
    
    // Get splits for each service
    for (let service of services) {
      const [splits] = await db.query(`
        SELECT bt.name AS beneficiary, sc.percentage
        FROM split_config sc
        JOIN beneficiary_types bt ON sc.beneficiary_type_id = bt.beneficiary_type_id
        WHERE sc.service_id = ?
        ORDER BY sc.percentage DESC
      `, [service.service_id]);
      
      service.splits = splits;
    }
    
    res.json({ success: true, data: services });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

exports.createChurch = async (req, res) => {
  try {
    const { forane_id, name, address, phone, bank_account, qr_code_url } = req.body;
    
    const [result] = await db.query(`
      INSERT INTO churches (forane_id, name, address, phone, bank_account, qr_code_url)
      VALUES (?, ?, ?, ?, ?, ?)
    `, [forane_id, name, address, phone, bank_account, qr_code_url]);
    
    res.status(201).json({
      success: true,
      message: 'Church created successfully',
      church_id: result.insertId
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

exports.updateChurch = async (req, res) => {
  try {
    const { id } = req.params;
    const { name, address, phone, bank_account, qr_code_url } = req.body;
    
    const [result] = await db.query(`
      UPDATE churches 
      SET name = ?, address = ?, phone = ?, bank_account = ?, qr_code_url = ?
      WHERE church_id = ?
    `, [name, address, phone, bank_account, qr_code_url, id]);
    
    if (result.affectedRows === 0) {
      return res.status(404).json({ success: false, error: 'Church not found' });
    }
    
    res.json({ success: true, message: 'Church updated successfully' });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

exports.deleteChurch = async (req, res) => {
  try {
    const [result] = await db.query(
      'DELETE FROM churches WHERE church_id = ?',
      [req.params.id]
    );
    
    if (result.affectedRows === 0) {
      return res.status(404).json({ success: false, error: 'Church not found' });
    }
    
    res.json({ success: true, message: 'Church deleted successfully' });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};