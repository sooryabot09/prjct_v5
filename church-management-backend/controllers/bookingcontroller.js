// controllers/bookingController.js
const db = require('../config/database');

// Get all bookings with details
exports.getAllBookings = async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT 
        b.booking_id,
        u.name AS parishioner,
        s.name AS service,
        c.name AS church,
        p.name AS priest,
        b.amount_paise / 100 AS amount_rupees,
        bs.name AS status,
        b.created_at
      FROM bookings b
      JOIN users u ON b.parishioner_id = u.user_id
      JOIN services s ON b.service_id = s.service_id
      JOIN churches c ON b.church_id = c.church_id
      LEFT JOIN users p ON b.priest_id = p.user_id
      JOIN booking_statuses bs ON b.status_id = bs.booking_status_id
      ORDER BY b.created_at DESC
    `);
    
    res.json({
      success: true,
      count: rows.length,
      data: rows
    });
  } catch (error) {
    console.error('Error fetching bookings:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
};

// Get booking by ID
exports.getBookingById = async (req, res) => {
  try {
    const { id } = req.params;
    
    const [rows] = await db.query(`
      SELECT 
        b.*,
        u.name AS parishioner_name,
        s.name AS service_name,
        c.name AS church_name,
        p.name AS priest_name,
        bs.name AS status_name
      FROM bookings b
      JOIN users u ON b.parishioner_id = u.user_id
      JOIN services s ON b.service_id = s.service_id
      JOIN churches c ON b.church_id = c.church_id
      LEFT JOIN users p ON b.priest_id = p.user_id
      JOIN booking_statuses bs ON b.status_id = bs.booking_status_id
      WHERE b.booking_id = ?
    `, [id]);
    
    if (rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Booking not found'
      });
    }
    
    res.json({
      success: true,
      data: rows[0]
    });
  } catch (error) {
    console.error('Error fetching booking:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
};

// Create new booking
exports.createBooking = async (req, res) => {
  try {
    const {
      service_id,
      parishioner_id,
      church_id,
      priest_id,
      amount_paise
    } = req.body;
    
    // Validate required fields
    if (!service_id || !parishioner_id || !church_id || !amount_paise) {
      return res.status(400).json({
        success: false,
        error: 'Missing required fields'
      });
    }
    
    // Get PENDING status ID
    const [statusRows] = await db.query(
      'SELECT booking_status_id FROM booking_statuses WHERE name = ?',
      ['PENDING']
    );
    
    const status_id = statusRows[0].booking_status_id;
    
    const [result] = await db.query(`
      INSERT INTO bookings (
        service_id, parishioner_id, church_id, priest_id, 
        amount_paise, status_id, created_by
      ) VALUES (?, ?, ?, ?, ?, ?, ?)
    `, [service_id, parishioner_id, church_id, priest_id, amount_paise, status_id, parishioner_id]);
    
    res.status(201).json({
      success: true,
      message: 'Booking created successfully',
      booking_id: result.insertId
    });
  } catch (error) {
    console.error('Error creating booking:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
};

// Update booking status
exports.updateBookingStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;
    
    // Get status ID
    const [statusRows] = await db.query(
      'SELECT booking_status_id FROM booking_statuses WHERE name = ?',
      [status]
    );
    
    if (statusRows.length === 0) {
      return res.status(400).json({
        success: false,
        error: 'Invalid status'
      });
    }
    
    const status_id = statusRows[0].booking_status_id;
    
    const [result] = await db.query(
      'UPDATE bookings SET status_id = ? WHERE booking_id = ?',
      [status_id, id]
    );
    
    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        error: 'Booking not found'
      });
    }
    
    res.json({
      success: true,
      message: 'Booking status updated successfully'
    });
  } catch (error) {
    console.error('Error updating booking:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
};