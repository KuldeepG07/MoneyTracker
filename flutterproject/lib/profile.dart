import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutterproject/app_state.dart';
import 'package:flutterproject/config.dart';
import 'package:flutterproject/navbar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 3;
  late String email, userId;
  late bool isLoggedIn = false;
  bool isLoading = true;
  String profileImageUrl = '${url}uploads/default.png';
  String? name;
  String? joinedDate;

  void _onNavBarTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home');
        break;
      case 1:
        Navigator.pushNamed(context, '/categories');
        break;
      case 2:
        Navigator.pushNamed(context, '/analytics');
        break;
      case 3:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    email = appState.userDetails!['email'];
    userId = appState.userDetails!['_id'];
    isLoggedIn = appState.isLoggedIn;
    if (isLoggedIn) {
      fetchUserProfile();
    } else {
      _showToast("You're not logged in!", Colors.black, Colors.white);
    }
  }

  Future<void> fetchUserProfile() async {
    try {
      var response = await http.get(
          Uri.parse('$getProfileUrl?email=${Uri.encodeComponent(email)}'),
          headers: {"Content-Type": "application/json"});

      var jsonUserResponse = jsonDecode(response.body);

      if (jsonUserResponse['status'] == true &&
          jsonUserResponse.containsKey('profile')) {
        setState(() {
          name = jsonUserResponse['profile']['name'];
          profileImageUrl = url + jsonUserResponse['profile']['profileImage'];
          joinedDate = jsonUserResponse['profile']['joinedDate'];
          isLoading = false;
        });
      } else {
        _showToast("Profile not found!", Colors.black, Colors.white);
      }
    } catch (error) {
      _showToast(
          "Error while loading profile! ${error}", Colors.black, Colors.white);
    }
  }

  Future<void> _changePassword() async {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Center(
            child: Text(
              'Change Password',
              style: TextStyle(color: Colors.black),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Old Password',
                  labelStyle: TextStyle(color: Colors.black),
                ),
                style: const TextStyle(color: Colors.black),
              ),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  labelStyle: TextStyle(color: Colors.black),
                ),
                style: const TextStyle(color: Colors.black),
              ),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  labelStyle: TextStyle(color: Colors.black),
                ),
                style: const TextStyle(color: Colors.black),
              ),
            ],
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.black,
              ),
              onPressed: () async {
                final oldPassword = oldPasswordController.text;
                final newPassword = newPasswordController.text;
                final confirmPassword = confirmPasswordController.text;

                if (oldPassword.isEmpty ||
                    newPassword.isEmpty ||
                    confirmPassword.isEmpty) {
                  _showToast(
                      "All fields are required!", Colors.black, Colors.white);
                  return;
                }

                if (newPassword != confirmPassword) {
                  _showToast("New password and confirmation do not match!",
                      Colors.black, Colors.white);
                  return;
                }

                final pwdResponse = await http.post(
                  Uri.parse(changePasswordUrl),
                  headers: {"Content-Type": "application/json"},
                  body: jsonEncode({
                    'email': email,
                    'oldpwd': oldPassword,
                    'newpwd': newPassword,
                  }),
                );
                var jsonPwdResponse = jsonDecode(pwdResponse.body);
                if (jsonPwdResponse['status']) {
                  fetchUserProfile();
                  _showToast(jsonPwdResponse['message'], Colors.black, Colors.white);
                  Navigator.of(context).pop();
                } else {
                  _showToast(jsonPwdResponse['message'], Colors.black, Colors.white);
                }
              },
              child: const Text(
                'Submit',
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.black,
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _changeName() async {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Center(
            child: Text(
              'Change Name',
              style: TextStyle(color: Colors.black),
            ),
          ),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'New Name',
              labelStyle: TextStyle(color: Colors.black),
            ),
            style: const TextStyle(color: Colors.black),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.black,
              ),
              onPressed: () async {
                final newName = nameController.text;

                if (newName.isEmpty) {
                  _showToast(
                      "Name cannot be empty!", Colors.black, Colors.white);
                  return;
                }

                final nameResponse = await http.post(
                  Uri.parse(changeNameUrl),
                  headers: {"Content-Type": "application/json"},
                  body: jsonEncode({
                    'email': email,
                    'newName': newName,
                  }),
                );
                var jsonNameResponse = jsonDecode(nameResponse.body);
                if (jsonNameResponse['status']) {
                  fetchUserProfile();
                  _showToast(
                      jsonNameResponse['message'], Colors.black, Colors.white);
                  Navigator.of(context).pop();
                } else {
                  _showToast(
                      jsonNameResponse['message'], Colors.black, Colors.white);
                }
              },
              child: const Text(
                'Submit',
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.black,
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _logout(BuildContext context) {
    Provider.of<AppState>(context, listen: false).logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 40,
              height: 40,
            ),
            const SizedBox(
              width: 10,
            ),
            const Text(
              'Profile',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                _logout(context);
              },
              tooltip: 'Logout',
            ),
          ],
        ),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey,
            height: 1.0,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: NetworkImage(profileImageUrl),
                        backgroundColor: Colors.grey[200],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/profileimage');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 3, 158, 9),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Update Photo'),
                  ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Name:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Text(
                            name!,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Email:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Text(
                            email,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Joined Date:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Text(
                            joinedDate!.substring(0, 10),
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _changeName,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Change Name'),
                      ),
                      ElevatedButton(
                        onPressed: _changePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Change Password'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onNavBarTap,
      ),
    );
  }

  void _showToast(String message, Color bgColor, Color textColor) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: bgColor,
      textColor: textColor,
      fontSize: 16.0,
    );
  }
}
