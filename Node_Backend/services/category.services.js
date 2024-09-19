const CategoryModel = require('../models/categories.model');
const ExpenseModel = require('../models/expenses.model');
const incomeModel = require('../models/incomes.model');
const IncomeModel = require('../models/incomes.model');
const UserModel = require('../models/user.model');

class CategoryServices {

    static async getAllCategories ()  {
        try {
            const categories = await CategoryModel.find();
            return categories;
        } catch(error) {
            next(error);
        }
    }

    static async getCategoryType(categoryName) {
        try {
            const categoryData = await CategoryModel.findOne({ name: categoryName });
            return categoryData ? categoryData : null;
        } catch (error) {
            throw error;
        }
    }

    static async getExpensesByTypeAndUser(email, catId) {
        try {
            const user = await UserModel.findOne({email});
            if(!user) {
                throw new Error("User not found");
            }
            const userId = user._id;
            const items = await ExpenseModel.find({ userId: userId, categoryId: catId });
            return items;
        } catch (error) {
            throw error;
        }
    }

    static async getIncomesByTypeAndUser(email, catId) {
        try {
            const user = await UserModel.findOne({email});
            if(!user) {
                throw new Error("User not found");
            }
            const userId = user._id;
            const items = await IncomeModel.find({ userId: userId, categoryId: catId });
            return items;
        } catch (error) {
            throw error;
        }
    }

    static async getCategoryTypeFromId(categoryid) {
        try {
            const categoryData = await CategoryModel.findOne({ _id: categoryid });
            return categoryData ? categoryData : null;
        } catch (error) {
            throw error;
        }
    }

    static async updateExpItemData(itemid, description, amount, paymentMethod, date) {
        try {
            const expItem = await ExpenseModel.findById(itemid);
            if(!expItem) {
                throw new Error("Item not updated !");
            }
            expItem.description = description;
            expItem.amount = amount;
            expItem.paymentMethod = paymentMethod;
            expItem.date = date;
            const updatedItem = await expItem.save();

            return updatedItem;
        } catch(error) {
            throw error;
        }
    }

    static async updateIncItemData(itemid, description, amount, paymentMethod, date) {
        try {
            const incItem = await IncomeModel.findById(itemid);
            if(!incItem) {
                throw new Error("Item not updated !");
            }
            incItem.description = description;
            incItem.amount = amount;
            incItem.paymentMethod = paymentMethod;
            incItem.date = date;
            const updatedItem = await incItem.save();

            return updatedItem;
        } catch(error) {
            throw error;
        }
    }

    static async deleteExpItemData(itemid) {
        try {
            const result = await ExpenseModel.deleteOne({ _id:itemid });
            if(result.deletedCount == 0) {
                throw new Error ("No item found to be deleted!");
            }
            return {status: true, message: "Expensedata deleted successfully !"};

        } catch (error) {
            throw error;
        }
    }

    static async deleteIncItemData(itemid) {
        try {
            const result = await IncomeModel.deleteOne({ _id:itemid });
            if(result.deletedCount == 0) {
                throw new Error ("No item found to be deleted!");
            }
            return {status: true, message: "Incomedata deleted successfully !"};

        } catch (error) {
            throw error;
        }
    }
}

module.exports = CategoryServices;