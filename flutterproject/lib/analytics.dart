import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutterproject/app_state.dart';
import 'package:flutterproject/config.dart';
import 'package:flutterproject/navbar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  _AnalyticsPageState createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  int _selectedIndex = 2;
  late String email, userId;
  late bool isloggedin = false;
  Map<String, Color> _categoryColors = {};
  List<Map<String, dynamic>> expenseData = [];
  List<Map<String, dynamic>> incomeData = [];
  List<Map<String, dynamic>> filteredIncomeData = [];
  List<Map<String, dynamic>> filteredExpenseData = [];
  DateTime _currentDate = DateTime.now();
  bool isExpenseSelected = true;
  bool isLoading = true;
  int touchedIndex = -1;

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
        break;
      case 3:
        Navigator.pushNamed(context, '/profile');
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
    if (isloggedin) {
      fetchAllExpenseAndIncomes();
    } else {
      _showToast("You're not logged in!", Colors.black, Colors.white);
    }
  }

  void _changeMonth(int change) {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + change);
      _filterDataByMonthYear();
    });
  }

  void _filterDataByMonthYear() {
    filteredExpenseData = expenseData.where((entry) {
      DateTime entryDate = DateTime.parse(entry['date']);
      return entryDate.year == _currentDate.year &&
          entryDate.month == _currentDate.month;
    }).toList();

    filteredIncomeData = incomeData.where((entry) {
      DateTime entryDate = DateTime.parse(entry['date']);
      return entryDate.year == _currentDate.year &&
          entryDate.month == _currentDate.month;
    }).toList();
    isLoading = false;
  }

  Future<void> fetchAllExpenseAndIncomes() async {
    try {
      var expresponse = await http.get(
          Uri.parse('$fetchAllExpenses?email=${Uri.encodeComponent(email)}'),
          headers: {"Content-Type": "application/json"});

      var incresponse = await http.get(
          Uri.parse('$fetchAllIncomes?email=${Uri.encodeComponent(email)}'),
          headers: {"Content-Type": "application/json"});

      var jsonResponseExpense = jsonDecode(expresponse.body);
      var jsonResponseIncome = jsonDecode(incresponse.body);

      if (jsonResponseIncome['status'] &&
          jsonResponseIncome['items'] != null &&
          jsonResponseExpense['items'] != null &&
          jsonResponseExpense['status']) {
        setState(() {
          var expdata = jsonResponseExpense['items'];
          var incdata = jsonResponseIncome['items'];
          expenseData = List<Map<String, dynamic>>.from(expdata);
          incomeData = List<Map<String, dynamic>>.from(incdata);
          _filterDataByMonthYear();
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      _showToast("Error while fetching data.", Colors.black, Colors.white);
    }
  }

  void _logout(BuildContext context) {
    Provider.of<AppState>(context, listen: false).logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('MMMM yyyy').format(_currentDate);

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
            'Analytics',
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_left),
                      onPressed: () => _changeMonth(-1),
                    ),
                    Text(
                      formattedDate,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_right),
                      onPressed: () => _changeMonth(1),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildToggleButton("Expense", isExpenseSelected),
                    const SizedBox(width: 10),
                    _buildToggleButton("Income", !isExpenseSelected),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sections: _getPieChartData(),
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              touchedIndex = -1;
                              return;
                            }
                            touchedIndex = pieTouchResponse
                                .touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _buildDataList(),
                ),
              ],
            ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onNavBarTap,
      ),
    );
  }

  Widget _buildToggleButton(String label, bool isSelected) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.black : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      onPressed: () {
        setState(() {
          isExpenseSelected = label == "Expense";
        });
      },
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  List<PieChartSectionData> _getPieChartData() {
    List<Map<String, dynamic>> data =
        isExpenseSelected ? filteredExpenseData : filteredIncomeData;

    Map<String, double> categorySums = {};
    for (var entry in data) {
      String category = entry['categoryId']['name'];
      categorySums[category] = (categorySums[category] ?? 0) + entry['amount'];
    }

    return categorySums.entries.map((entry) {
      String category = entry.key;
      double amount = entry.value;
      int index = categorySums.keys.toList().indexOf(category);

      final isTouched = index == touchedIndex;
      final double fontSize = isTouched ? 18 : 14;
      final double radius = isTouched ? 120 : 100;

      return PieChartSectionData(
        color: _getDynamicCategoryColor(category),
        value: amount,
        radius: radius,
        title: isTouched ? "\u20B9$amount\n$category" : '',
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      );
    }).toList();
  }

  Color _getDynamicCategoryColor(String category) {
    if (!_categoryColors.containsKey(category)) {
      _categoryColors[category] =
          Color((category.hashCode * 0xFFFFFF).toInt()).withOpacity(1.0);
    }
    return _categoryColors[category]!;
  }

  Widget _buildDataList() {
    List<Map<String, dynamic>> data =
        isExpenseSelected ? filteredExpenseData : filteredIncomeData;

    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  image: DecorationImage(
                    image: NetworkImage(
                        '$url${data[index]['categoryId']['image']}'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data[index]['description'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "\u20B9${data[index]['amount']}",
                      style: const TextStyle(color: Colors.black),
                    ),
                    Text(
                      "${(data[index]['categoryId']['name'])}",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showToast(String message, Color textColor, Color backgroundColor) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: 16.0,
    );
  }
}
