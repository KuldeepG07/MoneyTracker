import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutterproject/navbar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'config.dart';
import 'package:http/http.dart' as http;
import 'package:flutterproject/app_state.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late String email, userId;
  late bool isloggedin = false;
  late double totalExpense = 0;
  late double totalIncome = 0;
  List<Map<String, dynamic>> recentExpenses = [];
  List<Map<String, dynamic>> recentIncomes = [];
  List<Map<String, dynamic>> categoriesList = [];
  List<Map<String, dynamic>> expenseCategories = [];
  List<Map<String, dynamic>> incomeCategories = [];
  bool isLoading = true;

  void _onNavBarTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushReplacementNamed(context,'/categories');
        break;
      case 2:
        Navigator.pushNamed(context, '/analytics');
        break;
      case 3:
        Navigator.pushReplacementNamed(context,'/profile');
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
    fetchAllCategories();
    if (isloggedin) {
      calculateTotalExpense();
      calculateTotalIncome();
      fetchDataforRecentDetails();
    } else {
      _showToast("You're not logged in !", Colors.black, Colors.white);
    }
  }

  void _logout(BuildContext context) {
    Provider.of<AppState>(context, listen: false).logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  // Callback function to change the state of HomePage with updated data

  void _refreshData() async {
    await calculateTotalIncome();
    await calculateTotalExpense();
    await fetchDataforRecentDetails();
    setState(() {});
  }

  // Code for fetching categories from Database

  Future<void> fetchAllCategories() async {
    try {
      var catresponse = await http.get(Uri.parse(getAllCategories),
          headers: {"Content-Type": "application/json"});
      var jsoncatresponse = jsonDecode(catresponse.body);

      if (jsoncatresponse['status'] && jsoncatresponse['categories'] != null) {
        var categories = jsoncatresponse['categories'];

        setState(() {
          categoriesList = List<Map<String, dynamic>>.from(categories);
        });

        expenseCategories = categoriesList
            .where((category) => category['type'] == 'Expense')
            .toList();
        incomeCategories = categoriesList
            .where((category) => category['type'] == 'Income')
            .toList();
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (error) {
      _showToast(
          "Error while fetching categories!", Colors.black, Colors.white);
    }
  }

  // Calculating Total Incomde and Expense

  Future<void> calculateTotalExpense() async {
    try {
      var totalexpresponse = await http.get(
          Uri.parse('$totalExpUrl?email=${Uri.encodeComponent(email)}'),
          headers: {"Content-Type": "application/json"});

      var jsonResponseTotalExpense = jsonDecode(totalexpresponse.body);

      if (jsonResponseTotalExpense['status'] &&
          jsonResponseTotalExpense['expamount'] != null) {
        setState(() {
          totalExpense = jsonResponseTotalExpense['expamount'];
        });
      }
    } catch (error) {
      _showToast(
          "Error while calculating total expense!", Colors.black, Colors.white);
    }
  }

  Future<void> calculateTotalIncome() async {
    try {
      var totalincresponse = await http.get(
          Uri.parse('$totalIncUrl?email=${Uri.encodeComponent(email)}'),
          headers: {"Content-Type": "application/json"});

      var jsonResponseTotalIncome = jsonDecode(totalincresponse.body);

      if (jsonResponseTotalIncome['status'] &&
          jsonResponseTotalIncome['incamount'] != null) {
        setState(() {
          totalIncome = jsonResponseTotalIncome['incamount'];
        });
      }
    } catch (error) {
      _showToast(
          "Error while calculating total income!", Colors.black, Colors.white);
    }
  }

  // Code for Get recent data from Database

  Future<void> fetchDataforRecentDetails() async {
    try {
      var expresponse = await http.get(
          Uri.parse('$getRecentExpenses?email=${Uri.encodeComponent(email)}'),
          headers: {"Content-Type": "application/json"});

      var incresponse = await http.get(
          Uri.parse('$getRecentIncomes?email=${Uri.encodeComponent(email)}'),
          headers: {"Content-Type": "application/json"});

      if (expresponse.statusCode == 200 && incresponse.statusCode == 200) {
        var jsonResponseExpense = jsonDecode(expresponse.body);
        var jsonResponseIncome = jsonDecode(incresponse.body);

        if (jsonResponseIncome['status'] &&
            jsonResponseIncome['item'] != null &&
            jsonResponseExpense['item'] != null &&
            jsonResponseExpense['status']) {
          setState(() {
            var expdata = jsonResponseExpense['item'];
            var incdata = jsonResponseIncome['item'];
            recentExpenses = List<Map<String, dynamic>>.from(expdata);
            recentIncomes = List<Map<String, dynamic>>.from(incdata);
          });
        } else {
          throw Exception('Failed to load data');
        }
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      _showToast("Eror while fetching data.", Colors.black, Colors.white);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final userDetails = appState.userDetails;

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
            'MoneyTracker',
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
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        "Welcome, ${userDetails?['name'] ?? 'Guest'}",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoCard(
                            'Total Income', totalIncome, Colors.green),
                        _buildInfoCard(
                            'Total Expense', totalExpense, Colors.red),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildRecentList(
                        'Recent Expenses', recentExpenses, Colors.red),
                    const SizedBox(height: 20),
                    _buildRecentList(
                        'Recent Incomes', recentIncomes, Colors.green),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onNavBarTap,
      ),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // Code for showing options of 'Add-Expense' or 'Add-Income'

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Add Income',
                  style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.pop(context);
                _showAddIncomeForm(context, _refreshData);
              },
            ),
            ListTile(
              leading: const Icon(Icons.remove_circle_outline),
              title: const Text('Add Expense',
                  style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.pop(context);
                _showAddExpenseForm(context, _refreshData);
              },
            ),
          ],
        );
      },
    );
  }

  // Code for Adding new Expense

  Future<void> _showAddExpenseForm(
      BuildContext context, VoidCallback onSuccess) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            final _formKeyExp = GlobalKey<FormState>();
            final _amountControllerExp = TextEditingController();
            final _descriptionControllerExp = TextEditingController();
            final _dateControllerExp = TextEditingController();
            final _payeeControllerExp = TextEditingController();
            String? _selectedCategoryExp;
            String? _selectedPaymentMethodExp;

            Future<void> submitFormExpense() async {
              if (_formKeyExp.currentState!.validate()) {
                if (_amountControllerExp.text.isNotEmpty &&
                    _descriptionControllerExp.text.isNotEmpty &&
                    _dateControllerExp.text.isNotEmpty &&
                    _payeeControllerExp.text.isNotEmpty &&
                    _selectedPaymentMethodExp != null &&
                    _selectedCategoryExp != null) {
                  try {
                    var expDataBody = {
                      "userId": userId,
                      "categoryName": _selectedCategoryExp,
                      "date": _dateControllerExp.text,
                      "amount": int.parse(_amountControllerExp.text),
                      "description": _descriptionControllerExp.text,
                      "payee": _payeeControllerExp.text,
                      "paymentMethod": _selectedPaymentMethodExp
                    };

                    var addExpenseResponse = await http.post(
                      Uri.parse(addExpense),
                      headers: {"Content-Type": "application/json"},
                      body: jsonEncode(expDataBody),
                    );

                    var jsonresponseAddExpense =
                        jsonDecode(addExpenseResponse.body);
                    if (jsonresponseAddExpense['status']) {
                      onSuccess();
                      Navigator.of(context).pop(true);
                      _showToast("Expense added successfully", Colors.green,
                          Colors.black);
                    } else {
                      _showToast("Error: ${jsonresponseAddExpense['message']}",
                          Colors.red, Colors.black);
                    }
                  } catch (error) {
                    _showToast("Error while adding expense: $error", Colors.red,
                        Colors.black);
                  }
                }
              }
            }

            return AlertDialog(
              contentPadding: const EdgeInsets.all(20),
              title: const Text('Add Expense'),
              content: SizedBox(
                width: 400,
                child: Form(
                  key: _formKeyExp,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          border: OutlineInputBorder(),
                        ),
                        controller: _dateControllerExp,
                        readOnly: true,
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );

                          if (pickedDate != null) {
                            _dateControllerExp.text =
                                DateFormat('yyyy-MM-dd').format(pickedDate);
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Date is required';
                          }
                          final date = DateTime.parse(value);
                          if (date.isAfter(DateTime.now())) {
                            return 'Date cannot be in the future';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Amount',
                          border: OutlineInputBorder(),
                        ),
                        controller: _amountControllerExp,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Amount is required';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        controller: _descriptionControllerExp,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Description is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedCategoryExp,
                        onChanged: (value) {
                          _selectedCategoryExp = value;
                        },
                        items: expenseCategories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category['name'].toString(),
                            child: Text(category['name']),
                          );
                        }).toList(),
                        validator: (value) {
                          if (value == null) {
                            return 'Category is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Payee',
                          border: OutlineInputBorder(),
                        ),
                        controller: _payeeControllerExp,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Payee is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Payment Method',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedPaymentMethodExp,
                        onChanged: (value) {
                          _selectedPaymentMethodExp = value;
                        },
                        items: const [
                          DropdownMenuItem<String>(
                            value: 'GPay/Paytm',
                            child: Text('GPay/Paytm'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'Online_Banking',
                            child: Text('Online_Banking'),
                          ),
                        ],
                        validator: (value) {
                          if (value == null) {
                            return 'Payment Method is required';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                      ),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: submitFormExpense,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                      ),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Code for Adding new income

  Future<void> _showAddIncomeForm(
      BuildContext context, VoidCallback onSuccess) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            final _formKeyInc = GlobalKey<FormState>();
            final _amountControllerInc = TextEditingController();
            final _descriptionControllerInc = TextEditingController();
            final _dateControllerInc = TextEditingController();
            final _payerControllerInc = TextEditingController();
            String? _selectedCategoryInc;
            String? _selectedPaymentMethodInc;

            Future<void> submitFormIncome() async {
              if (_formKeyInc.currentState!.validate()) {
                if (_amountControllerInc.text.isNotEmpty &&
                    _descriptionControllerInc.text.isNotEmpty &&
                    _dateControllerInc.text.isNotEmpty &&
                    _payerControllerInc.text.isNotEmpty &&
                    _selectedPaymentMethodInc != null &&
                    _selectedCategoryInc != null) {
                  try {
                    var expDataBody = {
                      "userId": userId,
                      "categoryName": _selectedCategoryInc,
                      "date": _dateControllerInc.text,
                      "amount": int.parse(_amountControllerInc.text),
                      "description": _descriptionControllerInc.text,
                      "payer": _payerControllerInc.text,
                      "paymentMethod": _selectedPaymentMethodInc
                    };

                    var addExpenseResponse = await http.post(
                      Uri.parse(addIncome),
                      headers: {"Content-Type": "application/json"},
                      body: jsonEncode(expDataBody),
                    );

                    var jsonresponseAddExpense =
                        jsonDecode(addExpenseResponse.body);
                    if (jsonresponseAddExpense['status']) {
                      onSuccess();
                      Navigator.of(context).pop(true);
                      _showToast("Income added successfully", Colors.green,
                          Colors.black);
                    } else {
                      _showToast("Error: ${jsonresponseAddExpense['message']}",
                          Colors.red, Colors.black);
                    }
                  } catch (error) {
                    _showToast("Error while adding income: $error", Colors.red,
                        Colors.black);
                  }
                }
              }
            }

            return AlertDialog(
              contentPadding: const EdgeInsets.all(20),
              title: const Text('Add Income'),
              content: SizedBox(
                width: 400,
                child: Form(
                  key: _formKeyInc,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          border: OutlineInputBorder(),
                        ),
                        controller: _dateControllerInc,
                        readOnly: true,
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );

                          if (pickedDate != null) {
                            _dateControllerInc.text =
                                DateFormat('yyyy-MM-dd').format(pickedDate);
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Date is required';
                          }
                          final date = DateTime.parse(value);
                          if (date.isAfter(DateTime.now())) {
                            return 'Date cannot be in the future';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Amount',
                          border: OutlineInputBorder(),
                        ),
                        controller: _amountControllerInc,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Amount is required';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        controller: _descriptionControllerInc,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Description is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedCategoryInc,
                        onChanged: (value) {
                          _selectedCategoryInc = value;
                        },
                        items: incomeCategories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category['name'].toString(),
                            child: Text(category['name']),
                          );
                        }).toList(),
                        validator: (value) {
                          if (value == null) {
                            return 'Category is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Payer',
                          border: OutlineInputBorder(),
                        ),
                        controller: _payerControllerInc,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Payer is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Payment Method',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedPaymentMethodInc,
                        onChanged: (value) {
                          _selectedPaymentMethodInc = value;
                        },
                        items: const [
                          DropdownMenuItem<String>(
                            value: 'GPay/Paytm',
                            child: Text('GPay/Paytm'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'Online_Banking',
                            child: Text('Online_Banking'),
                          ),
                        ],
                        validator: (value) {
                          if (value == null) {
                            return 'Payment Method is required';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                      ),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: submitFormIncome,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                      ),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Code for creating card to show 'Total-Income' and 'Total-Expense'

  Widget _buildInfoCard(String title, double value, Color valuecolor) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          Text(
            '\u20B9$value',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w500, color: valuecolor),
          ),
        ],
      ),
    );
  }

  // Code for Recent items table

  Widget _buildRecentList(
      String title, List<Map<String, dynamic>> items, Color amtcolor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        items.isEmpty
            ? const Text('No recent data found',
                style: TextStyle(fontSize: 16, color: Colors.grey))
            : Table(
                border: TableBorder.all(color: Colors.grey),
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(1.5),
                  2: FlexColumnWidth(1),
                  3: FlexColumnWidth(1.5),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey[200]),
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Date',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Description',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Amount',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Pay Method',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  ...items.map((item) {
                    return TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(item['date']?.substring(0, 10) ?? 'N/A',
                              textAlign: TextAlign.center),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(item['description']?.toString() ?? 'N/A',
                              textAlign: TextAlign.center),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '${item['amount']}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: amtcolor,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                              item['paymentMethod']?.toString() ?? 'N/A',
                              textAlign: TextAlign.center),
                        ),
                      ],
                    );
                  }),
                ],
              ),
      ],
    );
  }

  FloatingActionButton _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        _showOptions(context);
      },
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      elevation: 6.0,
      shape: const CircleBorder(
        side: BorderSide(color: Colors.white, width: 2.0),
      ),
      child: const Icon(Icons.add),
    );
  }

  // Code for showing messages in Toast

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
