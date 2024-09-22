const router = require('express').Router();
const userController = require('../controllers/user.controllers');
const multer = require('multer');

const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        console.log(file.filename);
        cb(null, "uploads");
    },
    filename: function (req, file, cb) {
        cb(null, Date.now() + file.originalname);
    }
});

const upload = multer({
    storage: storage,
});

router.post('/users/upload', upload.single("image"), userController.uploadProfile);
router.get('/users/getuser', userController.getUserByEmail);
router.get('/users/getuserprofile', userController.getUserProfileData);
router.post('/users/changepassword', userController.changePassword);
router.post('/users/changename', userController.changeName);
router.post('/signup', userController.signup);
router.post('/login', userController.login);

module.exports = router;