const router = require('express').Router();
const categoryController = require('../controllers/category.controller');

router.get('/getcategories', categoryController.getAllCategories );
router.get('/getitems/:categoryName', categoryController.getItemsFromCategory );
router.put('/updateitem', categoryController.updateItemData );
router.delete('/deleteitem', categoryController.deleteItemData );

module.exports = router;