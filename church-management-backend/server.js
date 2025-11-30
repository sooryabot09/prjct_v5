// church-management-backend/server.js
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
require('dotenv').config();

// Verify environment variables are loaded
console.log('🔍 Checking environment variables...');
console.log('   PORT:', process.env.PORT || '3000 (default)');
console.log('   DB_HOST:', process.env.DB_HOST || 'localhost (default)');
console.log('   DB_USER:', process.env.DB_USER || 'root (default)');
console.log('   DB_NAME:', process.env.DB_NAME || 'church_management_system (default)');
console.log('   DB_PASSWORD:', process.env.DB_PASSWORD ? '[SET]' : '[NOT SET]');
console.log('   JWT_SECRET:', process.env.JWT_SECRET ? '[SET]' : '⚠️  [NOT SET - PLEASE ADD]');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware - MUST BE BEFORE ROUTES
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Health check endpoint - put before other routes
app.get('/', (req, res) => {
  res.json({ 
    message: 'Church Management System API',
    status: 'running',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
    endpoints: {
      auth: '/api/auth',
      bookings: '/api/bookings',
      users: '/api/users',
      churches: '/api/churches',
      complaints: '/api/complaints',
      events: '/api/events'
    }
  });
});

// Test database connection endpoint
app.get('/api/health', async (req, res) => {
  try {
    const db = require('./config/database');
    await db.query('SELECT 1');
    res.json({ 
      success: true, 
      message: 'Database connection OK',
      database: process.env.DB_NAME
    });
  } catch (error) {
    res.status(500).json({ 
      success: false, 
      message: 'Database connection failed',
      error: error.message
    });
  }
});

// Import routes
let authRoutes, bookingRoutes, userRoutes, churchRoutes, complaintRoutes, eventRoutes, transactionRoutes, notificationRoutes;

try {
  authRoutes = require('./routes/auth');
  bookingRoutes = require('./routes/bookings');
  userRoutes = require('./routes/users');
  churchRoutes = require('./routes/churches');
  complaintRoutes = require('./routes/complaints');
  eventRoutes = require('./routes/events');
  transactionRoutes = require('./routes/transactions');
  notificationRoutes = require('./routes/notifications');
  console.log('✅ All route modules loaded successfully');
} catch (error) {
  console.error('❌ Error loading route modules:', error.message);
  console.error('→ Make sure all route files exist in ./routes/ directory');
  process.exit(1);
}

// Mount routes
app.use('/api/auth', authRoutes);
app.use('/api/bookings', bookingRoutes);
app.use('/api/users', userRoutes);
app.use('/api/churches', churchRoutes);
app.use('/api/complaints', complaintRoutes);
app.use('/api/events', eventRoutes);
app.use('/api/transactions', transactionRoutes);
app.use('/api/notifications', notificationRoutes);

// 404 handler - MUST BE AFTER ALL ROUTES
app.use((req, res) => {
  res.status(404).json({ 
    success: false, 
    error: 'Route not found',
    path: req.path,
    method: req.method
  });
});

// Error handling middleware - MUST BE LAST
app.use((err, req, res, next) => {
  console.error('❌ Server Error:', err.message);
  console.error(err.stack);
  
  res.status(err.status || 500).json({
    success: false,
    error: {
      message: err.message || 'Internal Server Error',
      status: err.status || 500
    }
  });
});

// Start server
const server = app.listen(PORT, () => {
  console.log('\n' + '='.repeat(60));
  console.log('🚀 Server Started Successfully!');
  console.log('='.repeat(60));
  console.log(`📍 URL: http://localhost:${PORT}`);
  console.log(`⏰ Time: ${new Date().toLocaleString()}`);
  console.log('\n📋 Available Endpoints:');
  console.log('   GET    /                     - Health check');
  console.log('   GET    /api/health           - Database connection test');
  console.log('   POST   /api/auth/register    - Register new user');
  console.log('   POST   /api/auth/login       - User login');
  console.log('   POST   /api/auth/logout      - User logout');
  console.log('   GET    /api/churches         - Get all churches');
  console.log('   GET    /api/bookings         - Get all bookings');
  console.log('   POST   /api/bookings         - Create booking');
  console.log('   GET    /api/events           - Get events');
  console.log('   POST   /api/events           - Create event');
  console.log('   GET    /api/complaints       - Get complaints');
  console.log('   GET    /api/users            - Get users');
  console.log('='.repeat(60));
  console.log('\n💡 Tips:');
  console.log('   - Test connection: curl http://localhost:' + PORT);
  console.log('   - Test database: curl http://localhost:' + PORT + '/api/health');
  console.log('   - Stop server: Press Ctrl+C');
  console.log('='.repeat(60) + '\n');
});

// Handle server errors
server.on('error', (error) => {
  if (error.code === 'EADDRINUSE') {
    console.error(`❌ Port ${PORT} is already in use!`);
    console.error('→ Try changing the PORT in .env file');
    console.error('→ Or kill the process using that port');
  } else {
    console.error('❌ Server error:', error.message);
  }
  process.exit(1);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('\n📴 SIGTERM received. Shutting down gracefully...');
  server.close(() => {
    console.log('✅ Server closed');
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  console.log('\n📴 SIGINT received. Shutting down gracefully...');
  server.close(() => {
    console.log('✅ Server closed');
    process.exit(0);
  });
});

module.exports = app;