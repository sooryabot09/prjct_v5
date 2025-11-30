// church-management-backend/routes/notifications.js
const express = require('express');
const router = express.Router();
const notificationController = require('../controllers/notificationController');

router.get('/', notificationController.getAllNotifications);
router.get('/user/:userId', notificationController.getUserNotifications);
router.post('/', notificationController.createNotification);
router.patch('/delivered', notificationController.markAsDelivered);

module.exports = router;