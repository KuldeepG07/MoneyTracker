const express = require('express');
const bodyParser = require('body-parser');
const cors=  require('cors');
const userRouter = require('./routers/user.routers');
const expenseRouter = require('./routers/expense.routers');
const incomeRouter = require('./routers/income.routers');
const categoryRouter = require('./routers/category.routers');

const app = express();
app.use(cors());
app.use(bodyParser.json());
app.use("/uploads", express.static("uploads"));

app.use('/', userRouter);
app.use('/', expenseRouter);
app.use('/', incomeRouter);
app.use('/', categoryRouter);

module.exports = app;