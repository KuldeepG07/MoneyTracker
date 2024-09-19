const router = require('express').Router();
const expenseController = require('../controllers/expense.controllers');

router.post('/addexpense', expenseController.createExpense );
router.get('/getrecentexpenses', expenseController.getRecentExpenses );
router.get('/gettotalexpense', expenseController.getTotalExpenses );
router.get('/fetchallexpenses', expenseController.fetchAllExpensesData );

module.exports = router;