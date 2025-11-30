// church-management-backend/routes/auth.js
const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const db = require('../config/database');

// Register new user
router.post('/register', async (req, res) => {
  try {
    const { name, email, password, phone, church_id, role_id } = req.body;
    
    console.log('📝 Registration attempt:', { name, email, church_id });
    
    // Validate required fields
    if (!name || !email || !password) {
      console.log('❌ Missing required fields');
      return res.status(400).json({
        success: false,
        error: 'Name, email, and password are required'
      });
    }

    // Validate church_id is provided
    if (!church_id) {
      console.log('❌ Missing church_id');
      return res.status(400).json({
        success: false,
        error: 'Church selection is required'
      });
    }
    
    // Check if user exists
    const [existing] = await db.query(
      'SELECT * FROM users WHERE email = ?',
      [email]
    );
    
    if (existing.length > 0) {
      console.log('❌ User already exists:', email);
      return res.status(400).json({
        success: false,
        error: 'User with this email already exists'
      });
    }

    // Verify church exists
    const [churchExists] = await db.query(
      'SELECT church_id FROM churches WHERE church_id = ?',
      [church_id]
    );

    if (churchExists.length === 0) {
      console.log('❌ Church not found:', church_id);
      return res.status(400).json({
        success: false,
        error: 'Selected church does not exist'
      });
    }
    
    // Hash password
    const password_hash = await bcrypt.hash(password, 10);
    
    // Insert user (default to PARISHIONER role if not specified)
    const [result] = await db.query(
      `INSERT INTO users (name, email, password_hash, phone, church_id, role_id)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [name, email, password_hash, phone, church_id, role_id || 1]
    );
    
    console.log('✅ User created with ID:', result.insertId);
    
    // Get user with role information
    const [userData] = await db.query(
      `SELECT u.user_id, u.name, u.email, u.phone, u.church_id, u.birthday,
              u.ordination_date, u.feast_date, u.motto, u.is_active,
              ur.name as role, c.name as church_name
       FROM users u
       JOIN user_roles ur ON u.role_id = ur.role_id
       LEFT JOIN churches c ON u.church_id = c.church_id
       WHERE u.user_id = ?`,
      [result.insertId]
    );
    
    if (userData.length === 0) {
      console.log('❌ Failed to fetch created user');
      return res.status(500).json({
        success: false,
        error: 'User created but failed to fetch details'
      });
    }
    
    // Generate token
    const token = jwt.sign(
      { user_id: userData[0].user_id, role: userData[0].role },
      process.env.JWT_SECRET || 'your-secret-key-change-this',
      { expiresIn: '7d' }
    );
    
    console.log('✅ Token generated for user:', userData[0].email);
    
    // Prepare response
    const user = { ...userData[0] };
    
    const response = {
      success: true,
      token: token,
      user: user,
      message: 'Registration successful'
    };
    
    console.log('✅ Sending success response');
    
    res.status(201).json(response);
    
  } catch (error) {
    console.error('❌ Registration error:', error);
    res.status(500).json({ 
      success: false, 
      error: 'Registration failed. Please try again.',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Login user
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    
    // Validate required fields
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        error: 'Email and password are required'
      });
    }
    
    // Get user with role information
    const [users] = await db.query(
      `SELECT u.user_id, u.name, u.email, u.phone, u.church_id, u.birthday,
              u.ordination_date, u.feast_date, u.motto, u.is_active,
              u.password_hash,
              ur.name as role, c.name as church_name
       FROM users u
       JOIN user_roles ur ON u.role_id = ur.role_id
       LEFT JOIN churches c ON u.church_id = c.church_id
       WHERE u.email = ? AND u.is_active = true`,
      [email]
    );
    
    if (users.length === 0) {
      return res.status(401).json({
        success: false,
        error: 'Invalid credentials'
      });
    }
    
    const user = users[0];
    
    // Verify password
    const isValid = await bcrypt.compare(password, user.password_hash);
    
    if (!isValid) {
      return res.status(401).json({
        success: false,
        error: 'Invalid credentials'
      });
    }
    
    // Generate token
    const token = jwt.sign(
      { user_id: user.user_id, role: user.role },
      process.env.JWT_SECRET || 'your-secret-key-change-this',
      { expiresIn: '7d' }
    );
    
    // Remove password from response
    delete user.password_hash;
    
    res.json({
      success: true,
      token,
      user
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ 
      success: false, 
      error: 'Login failed. Please try again.',
      details: error.message 
    });
  }
});

// Logout (client-side token removal, but can blacklist token here if needed)
router.post('/logout', async (req, res) => {
  try {
    // In a more complex system, you might blacklist the token here
    // For now, client will just remove the token
    res.json({
      success: true,
      message: 'Logged out successfully'
    });
  } catch (error) {
    console.error('Logout error:', error);
    res.status(500).json({ 
      success: false, 
      error: error.message 
    });
  }
});

// Request password reset
router.post('/reset-password', async (req, res) => {
  try {
    const { email } = req.body;
    
    if (!email) {
      return res.status(400).json({
        success: false,
        error: 'Email is required'
      });
    }
    
    // Check if user exists
    const [users] = await db.query(
      'SELECT user_id, email FROM users WHERE email = ?',
      [email]
    );
    
    if (users.length === 0) {
      // Don't reveal if user exists or not for security
      return res.json({
        success: true,
        message: 'If an account exists, a reset link will be sent'
      });
    }
    
    // In production, you would:
    // 1. Generate a reset token
    // 2. Store it in database with expiry
    // 3. Send email with reset link
    
    // For now, just return success
    res.json({
      success: true,
      message: 'Password reset functionality not fully implemented'
    });
  } catch (error) {
    console.error('Reset password error:', error);
    res.status(500).json({ 
      success: false, 
      error: error.message 
    });
  }
});

module.exports = router;