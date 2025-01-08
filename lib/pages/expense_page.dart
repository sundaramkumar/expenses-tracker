import 'package:expenses_tracker/pages/home_page.dart';
import 'package:expenses_tracker/pages/transactions_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../databases/database_helper.dart';

class ExpensePage extends StatefulWidget {
  final Map<String, dynamic>? expense;

  ExpensePage({this.expense});

  @override
  _ExpensePageState createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  late String _date;
  late String _name;
  late double _amount;
  late String _transactionType;
  late String _paymentMethod;
  int? _selectedCategory;
  int? _selectedSubcategory;

  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _subcategories = [];

  TextEditingController _dateController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  final FocusNode _amountFocusNode = FocusNode();
  // final _valueNotifier = ValueNotifier<String>('');

  @override
  void initState() {
    super.initState();
    _loadCategories();
    if (widget.expense != null) {
      _date = DateFormat('yyyy-MM-dd')
          .format(DateTime.parse(widget.expense!['transactionDate']));
      _name = widget.expense!['description'];
      _amount = widget.expense!['debit'] > 0.0
          ? widget.expense!['debit'].toDouble()
          : widget.expense!['credit'].toDouble();
      _transactionType = widget.expense!['debit'] > 0 ? 'Expense' : 'Income';
      _paymentMethod = widget.expense!['transactionType'];
      _selectedCategory = widget.expense!['categoryId'];
      _selectedSubcategory = widget.expense!['subCategoryId'];

      _descriptionController.text = _name;
      _loadSubcategories(_selectedCategory!);
    } else {
      _date = DateFormat('yyyy-MM-dd').format(DateTime.now());
      _name = '';
      _amount = 0.0;
      _transactionType = 'Expense';
      _paymentMethod = 'Cash';
      _selectedCategory = null;
      _selectedSubcategory = null;
    }

    _amountController.text = _amount.toString();
    _amountFocusNode.addListener(() {
      if (_amountFocusNode.hasFocus) {
        _amountController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _amountController.text.length,
        );
      }
    });

    _dateController.text = _date;
  }

  @override
  void dispose() {
    _dateController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  // load categories on page load
  void _loadCategories() async {
    List<Map<String, dynamic>> categories = await _dbHelper.getCategories();
    setState(() {
      _categories = categories;
    });
  }

  // load subcategories based on the selected category
  void _loadSubcategories(int categoryId) async {
    List<Map<String, dynamic>> subcategories =
        await _dbHelper.getSubcategories(categoryId);
    setState(() {
      _subcategories = subcategories;
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Map<String, dynamic> expense = {
        'userId': 1, // as this is a single user app
        'transactionDate': _date,
        'description': _name.trim(),
        'debit': _transactionType == 'Expense' ? _amount : 0.0,
        'credit': _transactionType == 'Income' ? _amount : 0.0,
        'transactionType': _paymentMethod,
        'categoryId': _selectedCategory,
        'subCategoryId': _selectedSubcategory
      };
      if (widget.expense != null) {
        // Update existing expense
        expense['id'] = widget.expense!['id'];
        await _dbHelper.updateExpense(expense);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transaction updated successfully!'),
            backgroundColor: Colors.grey[800],
          ),
        );
      } else {
        // Insert new expense
        await _dbHelper.insertExpense(expense);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transaction added successfully!'),
            backgroundColor: Colors.green[800],
          ),
        );
      }

      // Reset form fields and state variables
      _formKey.currentState!.reset();
      setState(() {
        _date = DateFormat('yyyy-MM-dd').format(DateTime.now());
        _name = '';
        _amount = 0.0;
        _transactionType = 'Expense';
        _paymentMethod = 'Cash';
        _selectedCategory = null;
        _selectedSubcategory = null;
      });

      // Redirect to TransactionsPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
            body: TransactionsPage(),
            currentIndex: 3,
          ),
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(_date),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != DateTime.parse(_date)) {
      setState(() {
        _date = DateFormat('yyyy-MM-dd').format(picked);
        _dateController.text = _date;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
            widget.expense != null ? 'Edit Transaction' : 'Add Transaction'),
        // backgroundColor: Colors.grey[200],
        backgroundColor: Colors.red,
        toolbarHeight: 45,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width,
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Container(
            color: Colors.grey[200],
            child: IntrinsicHeight(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 0.0, vertical: 0.0),
                              title: const Text(
                                'Income',
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                              leading: Radio<String>(
                                value: 'Income',
                                groupValue: _transactionType,
                                onChanged: (String? value) {
                                  _selectedCategory = null;
                                  _selectedSubcategory = null;
                                  setState(() {
                                    _transactionType = value!;
                                  });
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 0.0, vertical: 0.0),
                              title: const Text('Expense',
                                  style: TextStyle(fontSize: 15)),
                              leading: Radio<String>(
                                value: 'Expense',
                                groupValue: _transactionType,
                                onChanged: (String? value) {
                                  setState(() {
                                    _transactionType = value!;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      InputDecorator(
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 3.0),
                          labelText: 'Transaction Detail',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                        ),
                        child: TextFormField(
                          controller: _descriptionController,
                          // decoration:
                          //     InputDecoration(labelText: 'Transaction Detail'),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter the detail.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _name = value!;
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      InputDecorator(
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 0),
                          labelText: 'Category',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                        ),
                        child: DropdownButtonFormField<int>(
                          value: _selectedCategory,
                          decoration: InputDecoration(labelText: 'select'),
                          items: _categories.map((category) {
                            return DropdownMenuItem<int>(
                              value: category['categoryId'],
                              child: Text(category['categoryName']),
                            );
                          }).toList(),
                          onChanged: (int? newValue) {
                            setState(() {
                              _selectedCategory = newValue!;
                              _selectedSubcategory = null;
                              _loadSubcategories(newValue);
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a category.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _selectedCategory = value;
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      InputDecorator(
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 0),
                          labelText: 'Sub Category',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                        ),
                        child: DropdownButtonFormField<int>(
                          value: _selectedSubcategory,
                          decoration: InputDecoration(labelText: 'select'),
                          items: _subcategories.map((subcategory) {
                            return DropdownMenuItem<int>(
                              value: subcategory['subCategoryId'],
                              child: Text(subcategory['subCategoryName']),
                            );
                          }).toList(),
                          onChanged: (int? newValue) {
                            setState(() {
                              _selectedSubcategory = newValue!;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a subcategory.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _selectedSubcategory = value;
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      InputDecorator(
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 3),
                          labelText: 'Amount',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                        ),
                        child: TextFormField(
                          controller: _amountController,
                          focusNode: _amountFocusNode,
                          // decoration: InputDecoration(
                          //   labelText: 'Amount',
                          // ),
                          keyboardType: TextInputType.number,
                          // initialValue: _amount.toString(),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter an amount.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _amount = double.parse(value!);
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      InputDecorator(
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 3),
                          labelText: 'Date',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                        ),
                        child: TextFormField(
                          controller: _dateController,
                          // decoration: InputDecoration(labelText: 'select'),
                          readOnly: true,
                          onTap: () => _selectDate(context),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Select date.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _date = value!;
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      InputDecorator(
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 0),
                          labelText: 'Payment Method',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _paymentMethod,
                          // decoration:
                          //     InputDecoration(labelText: 'Payment Method'),
                          items: ['Bank', 'Cash', 'Card', 'UPI']
                              .map((String method) {
                            return DropdownMenuItem<String>(
                              value: method,
                              child: Text(method),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _paymentMethod = newValue!;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a payment method.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _paymentMethod = value!;
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _submitForm,
                        child: Text(widget.expense != null
                            ? 'Save Transaction'
                            : 'Add Transaction'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
