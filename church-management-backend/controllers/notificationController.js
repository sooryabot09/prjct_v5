// church-management-backend/controllers/notificationController.js
const db = require('../config/database');

exports.getAllNotifications = async (req, res) => {
  try {
    const { user_id } = req.query;
    
    let query = `
      SELECT 
        n.notification_id,
        n.message,
        n.created_at,
        u.name AS sender_name,
        tt.name AS target_type,
        nr.status_id,
        ds.name AS delivery_status
      FROM notifications n
      JOIN users u ON n.sender_id = u.user_id
      JOIN target_types tt ON n.target_type_id = tt.target_type_id
      LEFT JOIN notification_recipients nr ON n.notification_id = nr.notification_id
      LEFT JOIN delivery_statuses ds ON nr.status_id = ds.delivery_status_id
    `;
    
    const params = [];
    
    if (user_id) {
      query += ' WHERE nr.user_id = ?';
      params.push(user_id);
    }
    
    query += ' ORDER BY n.created_at DESC';
    
    const [rows] = await db.query(query, params);
    
    res.json({ success: true, data: rows });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

exports.createNotification = async (req, res) => {
  try {
    const {
      sender_id,
      target_type,
      target_id,
      message
    } = req.body;
    
    // Get target type ID
    const [targetTypeRows] = await db.query(
      'SELECT target_type_id FROM target_types WHERE name = ?',
      [target_type]
    );
    
    if (targetTypeRows.length === 0) {
      return res.status(400).json({ success: false, error: 'Invalid target type' });
    }
    
    // Insert notification
    const [result] = await db.query(`
      INSERT INTO notifications (sender_id, target_type_id, target_id, message)
      VALUES (?, ?, ?, ?)
    `, [sender_id, targetTypeRows[0].target_type_id, target_id, message]);
    
    const notificationId = result.insertId;
    
    // Get recipient user IDs based on target type
    let recipients = [];
    
    switch (target_type) {
      case 'USER':
        recipients = [target_id];
        break;
        
      case 'PRIEST':
        const [priests] = await db.query(
          'SELECT user_id FROM users WHERE role_id = (SELECT role_id FROM user_roles WHERE name = "PRIEST")'
        );
        recipients = priests.map(p => p.user_id);
        break;
        
      case 'CHURCH':
        const [churchUsers] = await db.query(
          'SELECT user_id FROM users WHERE church_id = ?',
          [target_id]
        );
        recipients = churchUsers.map(u => u.user_id);
        break;
        
      case 'FORANE':
        const [foraneUsers] = await db.query(`
          SELECT u.user_id 
          FROM users u
          JOIN churches c ON u.church_id = c.church_id
          WHERE c.forane_id = ?
        `, [target_id]);
        recipients = foraneUsers.map(u => u.user_id);
        break;
        
      case 'DIOCESE':
        const [dioceseUsers] = await db.query(`
          SELECT u.user_id 
          FROM users u
          JOIN churches c ON u.church_id = c.church_id
          JOIN foranes f ON c.forane_id = f.forane_id
          WHERE f.diocese_id = ?
        `, [target_id]);
        recipients = dioceseUsers.map(u => u.user_id);
        break;
        
      case 'ALL':
        const [allUsers] = await db.query('SELECT user_id FROM users WHERE is_active = 1');
        recipients = allUsers.map(u => u.user_id);
        break;
    }
    
    // Get PENDING status
    const [pendingStatus] = await db.query(
      'SELECT delivery_status_id FROM delivery_statuses WHERE name = ?',
      ['PENDING']
    );
    
    // Insert recipients
    if (recipients.length > 0) {
      const recipientValues = recipients.map(userId => 
        `(${notificationId}, ${userId}, ${pendingStatus[0].delivery_status_id})`
      ).join(',');
      
      await db.query(`
        INSERT INTO notification_recipients (notification_id, user_id, status_id)
        VALUES ${recipientValues}
      `);
    }
    
    res.status(201).json({
      success: true,
      message: 'Notification created successfully',
      notification_id: notificationId,
      recipients_count: recipients.length
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

exports.getUserNotifications = async (req, res) => {
  try {
    const { userId } = req.params;
    
    const [rows] = await db.query(`
      SELECT 
        n.notification_id,
        n.message,
        n.created_at,
        u.name AS sender_name,
        tt.name AS target_type,
        ds.name AS delivery_status,
        nr.last_attempt_at
      FROM notification_recipients nr
      JOIN notifications n ON nr.notification_id = n.notification_id
      JOIN users u ON n.sender_id = u.user_id
      JOIN target_types tt ON n.target_type_id = tt.target_type_id
      JOIN delivery_statuses ds ON nr.status_id = ds.delivery_status_id
      WHERE nr.user_id = ?
      ORDER BY n.created_at DESC
    `, [userId]);
    
    res.json({ success: true, data: rows });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

exports.markAsDelivered = async (req, res) => {
  try {
    const { notification_id, user_id } = req.body;
    
    // Get SENT status
    const [sentStatus] = await db.query(
      'SELECT delivery_status_id FROM delivery_statuses WHERE name = ?',
      ['SENT']
    );
    
    const [result] = await db.query(`
      UPDATE notification_recipients 
      SET status_id = ?, last_attempt_at = NOW(), attempt_count = attempt_count + 1
      WHERE notification_id = ? AND user_id = ?
    `, [sentStatus[0].delivery_status_id, notification_id, user_id]);
    
    if (result.affectedRows === 0) {
      return res.status(404).json({ success: false, error: 'Recipient not found' });
    }
    
    res.json({ success: true, message: 'Marked as delivered' });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};