const CategoryServices = require('../services/category.services');
const UserServices = require('../services/user.services');

exports.getAllCategories = async (req, res, next) => {
    try {
        const categories = await CategoryServices.getAllCategories();
        if (categories.length > 0) {
            return res.status(200).json({status: true, categories: categories});
        }
        else {
            return res.status(200).json({status: true, categories: []});
        }
    } catch (error) {
        res.status(500).json({status: false, message: `Error while fetching categories: ${error}` });
    }
}

exports.getItemsFromCategory = async (req,res,next) => {
    try {
        const { categoryName } = req.params;
        const { email } = req.query;
        if( !email ) {
            return res.status(400).json({ status: false, message: "Email is required!"});
        }
        const categoryData = await CategoryServices.getCategoryType(categoryName);
        if(!categoryData) {
            return res.status(404).json({ status: false, message: "Category type not found" });
        }
        const catId = categoryData['_id'];
        if(categoryData['type'] == "Expense") {
            const expItems = await CategoryServices.getExpensesByTypeAndUser(email, catId);
            if(expItems.length > 0) {
                return res.status(200).json({ status: true, messgae: "Items loaded successfully !", items: expItems});
            } else {
                return res.status(200).json({ status: true, messgae: "No items found !", items: []});
            }
        } else {
            const incItems = await CategoryServices.getIncomesByTypeAndUser(email, catId);
            if(incItems.length > 0) {
                return res.status(200).json({ status: true, messgae: "Items loaded successfully !", items: incItems});
            } else {
                return res.status(200).json({ status: true, messgae: "No items found !", items: []});
            }
        }
    } catch (error) {
        return res.status(500).json({ status: false, message: "Error while fetching Items !" });
    }
}

exports.updateItemData = async (req,res,next) => {
    const {itemid, categoryid, description, amount, paymentMethod, date } = req.body;
    const category = await CategoryServices.getCategoryTypeFromId(categoryid);
    if (!category) {
        return res.status(404).json({ status: false, message: "Category type not found" });
    }
    const categoryType = category["type"];
    if(categoryType == "Expense") {
        const expUpdatedItem = await CategoryServices.updateExpItemData(itemid, description, amount, paymentMethod, date);
        if (!expUpdatedItem) {
            return res.status(200).json({status: false, message:"No item found !"});
        }
        return res.status(200).json({status: true, message:"Item Updated successfully !", item: expUpdatedItem});
    } else {
        const incUpdatedItem = await CategoryServices.updateIncItemData(itemid, description, amount, paymentMethod, date);
        if (!incUpdatedItem) {
            return res.status(200).json({status: false, message:"No item found !"});
        }
        return res.status(200).json({status: true, message:"Item Updated successfully !", item: incUpdatedItem});
    }
};

exports.deleteItemData = async (req,res,next) => {
    const {itemid, categoryid} = req.body;
    const category = await CategoryServices.getCategoryTypeFromId(categoryid);
    if (!category) {
        return res.status(404).json({ status: false, message: "Category type not found" });
    }
    const categoryType = category["type"];
    if(categoryType == "Expense") {
        const resExpDelete = await CategoryServices.deleteExpItemData(itemid);
        return res.status(200).json(resExpDelete);
    } else {
        const resIncDelete = await CategoryServices.deleteIncItemData(itemid);
        return res.status(200).json(resIncDelete);
    }
};