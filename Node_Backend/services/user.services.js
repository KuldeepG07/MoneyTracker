const UserModel = require('../models/user.model');
const jwt = require('jsonwebtoken');

class UserServices {

    static async isUserExists(email) {
        try {
            return await UserModel.isUserExists(email);
        } catch (error) {
            throw error;
        }
    }

    static async signup(name, email, password) {
        try {
            return await UserModel.createUser(name, email, password);
        } catch (error) {
            throw error;
        }
    }
    static async login(email, password) {
        try {
            return await UserModel.login(email, password);
        } catch (error) {
            throw error;
        }
    }

    static async getUserProfileData(email) {
        try {
            const user = await UserModel.findOne({email});
            return user;
        } catch (error) {
            throw error;
        }
    }

    static async changePassword(email, oldpwd, newpwd) {
        try {
            return await UserModel.changePassword(email, oldpwd, newpwd);
        } catch(error) {
            throw error;    
        }
    }

    static async changeName(email, newName) {
        try {
            return await UserModel.changeName(email, newName);
        } catch(error) {
            throw error;
        }
    }
}

module.exports = UserServices;