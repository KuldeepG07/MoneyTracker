const app = require('./app');
const db = require('./configurations/database');
const userModel = require('./models/user.model');
const categoryModel = require('./models/categories.model');
const expenseModel = require('./models/expenses.model');
const incomeModel = require('./models/incomes.model');

const port = 3000;

app.get('/', (req,res) => {
    res.send("hello World!!!");
})


app.listen(port,()=>{
    console.log(`Server is running on http://localhost:${port}`);
})