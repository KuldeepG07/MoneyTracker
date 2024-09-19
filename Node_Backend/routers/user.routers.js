const router = require('express').Router();
const userController = require('../controllers/user.controllers');

router.get('/users/getuser', userController.getUserByEmail);
router.get('/users/getuserprofile', userController.getUserProfileData);
router.post('/users/changepassword', userController.changePassword);
router.post('/users/changename', userController.changeName);
router.post('/signup', userController.signup);
router.post('/login', userController.login);

module.exports = router;