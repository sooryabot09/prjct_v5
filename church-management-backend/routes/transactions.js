// church-management-backend/routes/transactions.js
const express = require('express');
const router = express.Router();
const transactionController = require('../controllers/transactionController');

router.get('/', transactionController.getAllTransactions);
router.get('/pending-reviews', transactionController.getPendingReviews);
router.get('/church/:churchId', transactionController.getTransactionsByChurch);
router.get('/:id', transactionController.getTransactionById);
router.post('/', transactionController.createTransaction);
router.patch('/:id/status', transactionController.updateTransactionStatus);

module.exports = router;