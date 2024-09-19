const mongoose = require('mongoose');
const db = require('../configurations/database');
const UserModel = require('../models/user.model');
const CategoryModel = require('../models/categories.model');

const { Schema } = mongoose;

const expenseSchema = new Schema({
    userId: {
        type: Schema.Types.ObjectId,
        ref: UserModel.modelName,
        required: true,
    },
    categoryId: {
        type: Schema.Types.ObjectId,
        ref: CategoryModel.modelName ,
        required: true,
    },
    date: {
        type: Date,
        required: true,
    },
    amount: {
        type: Number,
        required: true,
    },
    description: {
        type: String,
    },
    payee: {
        type: String,
        required: true,
    },
    paymentMethod: {
        type: String,
        enum: ['Online_Banking','UPI','GPay/Paytm','Cash','Credit_Card','Debit_Card'],
        required: true,
    },
});

const expenseModel = db.model('Expense', expenseSchema);
module.exports = expenseModel;