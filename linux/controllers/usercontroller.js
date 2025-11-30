const db = require('../config/database');
const bcrypt = require('bcrypt');

// Get all users
exports.getAllUsers = async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT 
        u.user_id, u.name, u.email, u.phone,
        ur.name AS role, c.name AS church_name,
        u.birthday, u.ordination_date, u.feast_date, u.motto,
        u.is_active
      FROM users u
      JOIN user_roles ur ON u.role_id = ur.role_id
      LEFT JOIN churches c ON u.church_id = c.church_id
      ORDER BY u.created_at DESC
    `);
    
    res.json({
      success: true,
      data: rows
    });
  } catch (error) {
    console.error('Error fetching users:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
};

// Get user by ID
exports.getUserById = async (req, res) => {
  try {
    const { id } = req.params;
    
    const [rows] = await db.query(`
      SELECT 
        u.user_id, u.name, u.email, u.phone,
        ur.name AS role, c.name AS church_name,
        u.church_id, u.birthday, u.ordination_date, 
        u.feast_date, u.motto, u.is_active
      FROM users u
      JOIN user_roles ur ON u.role_id = ur.role_id
      LEFT JOIN churches c ON u.church_id = c.church_id
      WHERE u.user_id = ?
    `, [id]);
    
    if (rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'User not found'
      });
    }
    
    res.json({
      success: true,
      data: rows[0]
    });
  } catch (error) {
    console.error('Error fetching user:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
};

// Create user
exports.createUser = async (req, res) => {
  try {
    const {
      name, email, password, phone, role_id, church_id,
      birthday, ordination_date, feast_date, motto
    } = req.body;
    
    // Check if user exists
    const [existing] = await db.query(
      'SELECT user_id FROM users WHERE email = ?',
      [email]
    );
    
    if (existing.length > 0) {
      return res.status(400).json({
        success: false,
        error: 'User with this email already exists'
      });
    }
    
    // Hash password
    const password_hash = await bcrypt.hash(password, 10);
    
    // Insert user
    const [result] = await db.query(`
      INSERT INTO users 
      (name, email, password_hash, phone, role_id, church_id, 
       birthday, ordination_date, feast_date, motto)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `, [name, email, password_hash, phone, role_id, church_id,
        birthday, ordination_date, feast_date, motto]);
    
    res.status(201).json({
      success: true,
      message: 'User created successfully',
      user_id: result.insertId
    });
  } catch (error) {
    console.error('Error creating user:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
};

// Update user
exports.updateUser = async (req, res) => {
  try {
    const { id } = req.params;
    const {
      name, email, phone, church_id,
      birthday, ordination_date, feast_date, motto
    } = req.body;
    
    const [result] = await db.query(`
      UPDATE users 
      SET name = ?, email = ?, phone = ?, church_id = ?,
          birthday = ?, ordination_date = ?, feast_date = ?, motto = ?
      WHERE user_id = ?
    `, [name, email, phone, church_id, birthday, ordination_date, 
        feast_date, motto, id]);
    
    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        error: 'User not found'
      });
    }
    
    res.json({
      success: true,
      message: 'User updated successfully'
    });
  } catch (error) {
    console.error('Error updating user:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
};

// Delete user
exports.deleteUser = async (req, res) => {
  try {
    const { id } = req.params;
    
    const [result] = await db.query(
      'DELETE FROM users WHERE user_id = ?',
      [id]
    );
    
    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        error: 'User not found'
      });
    }
    
    res.json({
      success: true,
      message: 'User deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting user:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
};

// Toggle user active status
exports.toggleUserStatus = async (req, res) => {
  try {
    const { id } = req.params;
    
    const [result] = await db.query(`
      UPDATE users 
      SET is_active = NOT is_active 
      WHERE user_id = ?
    `, [id]);
    
    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        error: 'User not found'
      });
    }
    
    res.json({
      success: true,
      message: 'User status updated successfully'
    });
  } catch (error) {
    console.error('Error toggling user status:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
};
