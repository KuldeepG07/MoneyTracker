const mongoose = require('mongoose');

const connection = mongoose.createConnection('mongodb://127.0.0.1:27017/Flutter_MoneyTracker').on('open', ()=> {
    console.log('Database connected...');
}); 

module.exports = connection;