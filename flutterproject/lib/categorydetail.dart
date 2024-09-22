import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutterproject/app_state.dart';
import 'package:flutterproject/config.dart';
import 'package:flutterproject/navbar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CategoryDetailPage extends StatefulWidget {
  final String categoryName;
  final String categoryId;

  const CategoryDetailPage({
    super.key,
    required this.categoryName,
    required this.categoryId,
  });

  @override
  _CategoryDetailPageState createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  int _selectedIndex = 1;
  late String email, userId;
  late bool isloggedin = false;
  // Hello
  List<Map<String, dynamic>> itemList = [];
  bool isLoading = true;

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
      _showToast("You're not logged in!", Colors.black, Colors.white);
    }
    fetchCategoryItems();
  }

  Future<void> fetchCategoryItems() async {
    try {
      var catResponse = await http.get(
          Uri.parse(
              "$getItemsByCategory${widget.categoryName}?email=${Uri.encodeComponent(email)}"),
          headers: {"Content-Type": "application/json"});
      var jsonCategoryResponse = jsonDecode(catResponse.body);

      if (jsonCategoryResponse['status'] &&
          jsonCategoryResponse['items'] != null) {
        setState(() {
          itemList =
              List<Map<String, dynamic>>.from(jsonCategoryResponse['items']);
        });
      } else {
        _showToast("There is no items!", Colors.black, Colors.white);
      }
    } catch (error) {
      _showToast("Error while fetching items!", Colors.black, Colors.white);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _editItem(Map<String, dynamic> item) async {
    final _formKey = GlobalKey<FormState>();

    final TextEditingController _descriptionController =
        TextEditingController(text: item['description']);
    final TextEditingController _amountController =
        TextEditingController(text: item['amount'].toString());
    final TextEditingController _dateController =
        TextEditingController(text: item['date'].substring(0, 10));
    String _paymentMethod = item['paymentMethod'];

    DateTime _date = DateTime.parse(item["date"]);

    await showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        height: 300,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'Date'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a date';
                    }
                    return null;
                  },
                  onTap: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _date = pickedDate;
                        _dateController.text =
                            DateFormat('yyyy-MM-dd').format(pickedDate);
                      });
                    }
                  },
                ),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(labelText: 'Amount'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField(
                  value: _paymentMethod,
                  decoration:
                      const InputDecoration(labelText: 'Payment Method'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a payment method';
                    }
                    return null;
                  },
                  onChanged: (value) => setState(() => _paymentMethod = value!),
                  items: [
                    'GPay/Paytm',
                    'Online_Banking',
                  ].map((paymentMethod) {
                    return DropdownMenuItem(
                      value: paymentMethod,
                      child: Text(paymentMethod),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          var updateResponse = await http.put(
                            Uri.parse(updateItemUrl),
                            headers: {"Content-Type": "application/json"},
                            body: jsonEncode({
                              'itemid': item["_id"],
                              'categoryid': item["categoryId"],
                              'description': _descriptionController.text,
                              'amount': _amountController.text,
                              'paymentMethod': _paymentMethod,
                              'date': _dateController.text,
                            }),
                          );
                          var jsonUpdateResponse =
                              jsonDecode(updateResponse.body);

                          if (jsonUpdateResponse['status']) {
                            setState(() {
                              item['description'] = _descriptionController.text;
                              item['amount'] = _amountController.text;
                              item['paymentMethod'] = _paymentMethod;
                              item['date'] = _dateController.text;
                            });
                            Navigator.pop(context);
                          } else {
                            _showToast("Error updating item!", Colors.black,
                                Colors.white);
                          }
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteItem(Map<String, dynamic> item) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this item?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        final response = await http.delete(
          Uri.parse(deleteItemUrl),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(
              {"itemid": item["_id"], "categoryid": item["categoryId"]}),
        );

        final responseBody = jsonDecode(response.body);
        if (responseBody['status']) {
          setState(() {
            fetchCategoryItems();
          });
          _showToast("Item deleted successfully!", Colors.black, Colors.white);
        } else {
          _showToast("Error deleting item!", Colors.black, Colors.white);
        }
      } catch (error) {
        _showToast("Error while deleting item!", Colors.black, Colors.white);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : itemList.isEmpty
              ? const Center(child: Text('No items found for this category.'))
              : ListView.builder(
                  itemCount: itemList.length,
                  itemBuilder: (context, index) {
                    final item = itemList[index];

                    final bool isWhiteBackground = index % 2 == 0;
                    final Color backgroundColor =
                        isWhiteBackground ? Colors.white : Colors.black;
                    final Color textColor =
                        isWhiteBackground ? Colors.black : Colors.white;

                    return Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item['description'],
                                style: TextStyle(
                                    color: textColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '\u20B9 ${item['amount']}',
                                style:
                                    TextStyle(color: textColor, fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Date: ${item['date'].substring(0, 10)}',
                                style: TextStyle(color: textColor),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Payment: ${item['paymentMethod']}',
                                style: TextStyle(color: textColor),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: textColor),
                                onPressed: () => _editItem(item),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: textColor),
                                onPressed: () => _deleteItem(item),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
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
