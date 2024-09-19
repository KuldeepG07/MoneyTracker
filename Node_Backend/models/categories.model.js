const mongoose = require('mongoose');
const db = require('../configurations/database');

const { Schema } = mongoose;

const categorySchema = new Schema({
    name: {
        type: String,
        required:true,
    },
    type: {
        type: String,
        enum: ['Income','Expense'],
        required: true,
    },
    image: {
        type: String,
        required:true,
    },
});

const categoryModel = db.model('Category', categorySchema);
module.exports = categoryModel;