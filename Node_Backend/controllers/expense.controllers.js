const ExpenseServices = require('../services/expense.services');

exports.createExpense = async (req, res, next) => {
    try {
        const {userId, categoryName, date, amount, description, payee, paymentMethod} = req.body;
        let expense = await ExpenseServices.createExpense(userId, categoryName, date, amount, description, payee, paymentMethod);
        res.status(200).json({status: true, message: "Expesne Added Successfully !"});
    } catch(error) {
        res.status(500).json({status: false, message:"Error while adding expense !"});
    }
}

exports.getRecentExpenses = async (req, res, next) => {
    try {
        const email = req.query.email;
        if (!email) {
            return res.status(400).json({ status: false, message: "Email is required" });
        }
        let recentexpenses = await ExpenseServices.fetchRecentExpenses(email);
        if (recentexpenses.length > 0) {
            return res.status(200).json({status: true, item: recentexpenses});
        } else {
            return res.status(200).json({status: true, item: []});
        }
    } catch(error) {
        res.status(500).json({status: false, message: `Error while fetching recent expenses! ${error}`});
    }
}

exports.getTotalExpenses = async (req,res,next) => {
    try {
        const email = req.query.email;
        if (!email) {
            return res.status(400).json({ status: false, message: "Email is required" });
        }
        let amount = await ExpenseServices.calculateTotalExpense(email);
        if(amount !== null) {
            return res.status(200).json({status: true, expamount: amount});
        } else {
            return res.status(200).json({status: true, expamount: 0});
        }
    } catch(error) {
        res.status(500).json({status: false, message: `Error while calculating total expenses! ${error}`});
    }
}

exports.fetchAllExpensesData = async (req,res,next) => {
    try {
        const email = req.query.email;
        if (!email) {
            return res.status(400).json({ status: false, message: "Email is required" });
        }
        let allExpenses = await ExpenseServices.fetchAllExpenses(email);
        if (allExpenses.length > 0) {
            return res.status(200).json({status: true, items: allExpenses});
        } else {
            return res.status(200).json({status: true, items: []});
        }
    } catch (error) {
        res.status(500).json({status: false, message: `Error while fetching all expenses! ${error}`});
    }
};