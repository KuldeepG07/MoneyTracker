import 'dart:convert';
import 'package:flutterproject/app_state.dart';
import 'package:provider/provider.dart';

import 'config.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void login() async {
    if (_formKey.currentState!.validate()) {
      if (_emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty) {
        try {
          var userBody = {
            "email": _emailController.text,
            "password": _passwordController.text
          };
          
          var response = await http.post(Uri.parse(loginUrl),
                headers: {"Content-Type": "application/json"},
                body: jsonEncode(userBody));

          var jsonResponse = jsonDecode(response.body);

          if (jsonResponse['status']) 
          {
            Provider.of<AppState>(context, listen: false).login(jsonResponse['user']);
            _showToast(jsonResponse['message'],Colors.black, Colors.white);
            await Future.delayed(const Duration(seconds: 2));
            Navigator.pushReplacementNamed(context,'/home');
          } else {
            _showToast(jsonResponse['message'], Colors.red, Colors.white);
          }
        } catch (e) {
          _showToast('Network error: $e', Colors.red, Colors.white); 
          print('Network error: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'MoneyTracker',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
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
        body: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 50.0),
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Login',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30.0,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter an email";
                      }
                      if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                        return "Please enter a valid email";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter a password";
                      }
                      if (value.length < 7) {
                        return "Password must be at least 7 characters long";
                      }
                      if (!RegExp(r'[A-Z]').hasMatch(value) ||
                          !RegExp(r'\d').hasMatch(value)) {
                        return "Password must include at least one uppercase letter and one digit";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 30.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Text('Login'),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account?",
                        style: TextStyle(color: Colors.black),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                              context, '/signup'); // Redirect to Signup page
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red, // Red text color
                        ),
                        child: const Text(
                          'Signup',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BottomAppBar(
              color: Colors.white, // White background for the bottom bar
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black, // Inactive link color
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10.0), // Rounded corners
                        ),
                        backgroundColor: Colors.white.withOpacity(0.2),
                      ),
                      child: const Text('Login'),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: Colors.black, // Divider line between buttons
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/signup');
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey, // Active link color
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10.0), // Rounded corners
                        ),
                        backgroundColor: Colors.white.withOpacity(0.2),
                      ),
                      child: const Text('Signup'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
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
