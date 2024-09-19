import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutterproject/app_state.dart';
import 'package:flutterproject/categorydetail.dart';
import 'package:flutterproject/config.dart';
import 'package:flutterproject/navbar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});
  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  int _selectedIndex = 1;
  late String email, userId;
  late bool isloggedin = false;
  List<Map<String, dynamic>> categoriesList = [];
  List<Map<String, dynamic>> expenseCategories = [];
  List<Map<String, dynamic>> incomeCategories = [];
  bool isLoading = true;

  bool isExpenseSelected = true;

  void _onNavBarTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        break;
      case 2:
        Navigator.pushNamed(context, '/analytics');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
      default:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    email = appState.userDetails!['email'];
    userId = appState.userDetails!['_id'];
    isloggedin = appState.isLoggedIn;
    if (!isloggedin) {
      _showToast("You're not logged in !", Colors.black, Colors.white);
    }
    fetchAllCategories();
  }

  void _logout(BuildContext context) {
    Provider.of<AppState>(context, listen: false).logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> fetchAllCategories() async {
    try {
      var catresponse = await http.get(Uri.parse(getAllCategories),
          headers: {"Content-Type": "application/json"});
      var jsoncatresponse = jsonDecode(catresponse.body);

      if (jsoncatresponse['status'] && jsoncatresponse['categories'] != null) {
        var categories = jsoncatresponse['categories'];

        setState(() {
          categoriesList = List<Map<String, dynamic>>.from(categories);
          expenseCategories = categoriesList
              .where((category) => category['type'] == 'Expense')
              .toList();
          incomeCategories = categoriesList
              .where((category) => category['type'] == 'Income')
              .toList();
        });
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (error) {
      _showToast(
          "Error while fetching categories!", Colors.black, Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Image.asset(
            'assets/images/logo.png',
            width: 40,
            height: 40,
          ),
          const SizedBox(
            width: 10,
          ),
          const Text(
            'Categories',
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
        ]),
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
      body: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: const BorderSide(color: Colors.black, width: 2),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      backgroundColor:
                          isExpenseSelected ? Colors.black : Colors.white,
                      foregroundColor:
                          isExpenseSelected ? Colors.white : Colors.black,
                    ),
                    onPressed: () {
                      setState(() {
                        isExpenseSelected = true;
                      });
                    },
                    child: const Text('Expense'),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: const BorderSide(color: Colors.black, width: 2),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      backgroundColor:
                          !isExpenseSelected ? Colors.black : Colors.white,
                      foregroundColor:
                          !isExpenseSelected ? Colors.white : Colors.black,
                    ),
                    onPressed: () {
                      setState(() {
                        isExpenseSelected = false;
                      });
                    },
                    child: const Text('Income'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
              ),
              itemCount: isExpenseSelected
                  ? expenseCategories.length
                  : incomeCategories.length,
              itemBuilder: (context, index) {
                final category = isExpenseSelected
                    ? expenseCategories[index]
                    : incomeCategories[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoryDetailPage(
                          categoryId: category['_id'],
                          categoryName: category['name'],
                        ),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 5,
                            spreadRadius: 1,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                        padding: const EdgeInsets.all(8.0),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage("$url${category['image']}"),
                          backgroundColor: Colors.grey[200],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category['name']!,
                        style: const TextStyle(color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
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
