const categoryModel = require('../models/categories.model');
const ExpenseModel = require('../models/expenses.model');
const UserModel = require('../models/user.model');

class ExpenseServices {
    
    static async createExpense (userId, categoryName, date, amount, description, payee, paymentMethod) {
        const categorydata = await categoryModel.findOne({name: categoryName});
        if(!categorydata) {
            throw new Error('Category not exists !');
        }
        
        const categoryId = categorydata._id;
        const createExpense = new ExpenseModel({userId, categoryId, date, amount, description, payee, paymentMethod});
        return await createExpense.save();
    }

    static async fetchRecentExpenses(email) {
        const user = await UserModel.findOne({ email });
        if (!user) {
            throw new Error('User not found');
        }
        const userId = user._id;
        return await ExpenseModel.find({ userId }).sort({ date: -1 }).limit(5);
    }

    static async fetchAllExpenses(email) {
        const user = await UserModel.findOne({ email });
        if (!user) {
            throw new Error('User not found');
        }
        const userId = user._id;
        return await ExpenseModel.find({ userId }).populate('categoryId').sort({ date: -1 });
    }

    static async calculateTotalExpense(email) {
        const user = await UserModel.findOne({ email });
        if (!user) {
            throw new Error('User not found');
        }
        const userId = user._id;
        const totalExpense = await ExpenseModel.aggregate([
            { $match: { userId: userId } },
            { $group: { _id: null, totalAmount: { $sum: '$amount' } } }
        ]);
        return totalExpense.length>0 ? totalExpense[0].totalAmount : 0;   
    }
}

module.exports = ExpenseServices;