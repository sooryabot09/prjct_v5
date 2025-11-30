// church-management-backend/controllers/servicecontroller.js
const db = require('../config/database');

exports.getAllServices = async (req, res) => {
  try {
    const [services] = await db.query(`
      SELECT 
        s.service_id, s.name, s.description,
        s.amount_paise / 100 AS amount_rupees,
        c.name AS church_name
      FROM services s
      JOIN churches c ON s.church_id = c.church_id
      ORDER BY s.created_at DESC
    `);
    
    res.json({ success: true, data: services });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

exports.createService = async (req, res) => {
  try {
    const { name, description, amount_paise, church_id, splits } = req.body;
    
    // Insert service
    const [result] = await db.query(`
      INSERT INTO services (name, description, amount_paise, church_id)
      VALUES (?, ?, ?, ?)
    `, [name, description, amount_paise, church_id]);
    
    const serviceId = result.insertId;
    
    // Insert splits
    if (splits && splits.length > 0) {
      for (const split of splits) {
        const [benefType] = await db.query(
          'SELECT beneficiary_type_id FROM beneficiary_types WHERE name = ?',
          [split.beneficiary_type]
        );
        
        if (benefType.length > 0) {
          await db.query(`
            INSERT INTO split_config (service_id, beneficiary_type_id, percentage)
            VALUES (?, ?, ?)
          `, [serviceId, benefType[0].beneficiary_type_id, split.percentage]);
        }
      }
    }
    
    res.status(201).json({
      success: true,
      message: 'Service created successfully',
      service_id: serviceId
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

exports.updateService = async (req, res) => {
  try {
    const { id } = req.params;
    const { name, description, amount_paise } = req.body;
    
    const [result] = await db.query(`
      UPDATE services 
      SET name = ?, description = ?, amount_paise = ?
      WHERE service_id = ?
    `, [name, description, amount_paise, id]);
    
    if (result.affectedRows === 0) {
      return res.status(404).json({ success: false, error: 'Service not found' });
    }
    
    res.json({ success: true, message: 'Service updated successfully' });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

exports.deleteService = async (req, res) => {
  try {
    // Delete splits first
    await db.query('DELETE FROM split_config WHERE service_id = ?', [req.params.id]);
    
    // Delete service
    const [result] = await db.query(
      'DELETE FROM services WHERE service_id = ?',
      [req.params.id]
    );
    
    if (result.affectedRows === 0) {
      return res.status(404).json({ success: false, error: 'Service not found' });
    }
    
    res.json({ success: true, message: 'Service deleted successfully' });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};