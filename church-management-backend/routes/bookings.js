// routes/bookings.js
const express = require('express');
const router = express.Router();
const bookingController = require('../controllers/bookingController');

// GET all bookings
router.get('/', bookingController.getAllBookings);

// GET booking by ID
router.get('/:id', bookingController.getBookingById);

// POST create new booking
router.post('/', bookingController.createBooking);

// PATCH update booking status
router.patch('/:id/status', bookingController.updateBookingStatus);

module.exports = router;