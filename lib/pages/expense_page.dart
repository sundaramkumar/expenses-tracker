import 'package:expenses_tracker/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../databases/database_helper.dart';
import '../utils/widgets/app_bars.dart';
import '../utils/widgets/primary_button.dart';
import '../utils/intent_bridge.dart';
import '../services/sms_service.dart';
import '../utils/sms_parser.dart';

class ExpensePage extends StatefulWidget {
  final Map<String, dynamic>? expense;

  const ExpensePage({super.key, this.expense});

  @override
  State<ExpensePage> createState() => _ExpensePageState();
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
  final List<String> _paymentMethods = const ['Bank', 'Cash', 'Card', 'UPI'];

  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _subcategories = [];
  bool _isLoadingCategories = true;
  bool _isLoadingSubcategories = false;
  String? _loadError;
  
  List<TransactionData> _recentSmsTransactions = [];
  bool _isLoadingSms = false;

  TextEditingController _dateController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  final FocusNode _amountFocusNode = FocusNode();
  // final _valueNotifier = ValueNotifier<String>('');

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadRecentSms();
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

    // Try prefill from Android widget intent
    _prefillFromIntent();

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

  Future<void> _prefillFromIntent() async {
    final extras = await IntentBridge.getExtras();
    if (!mounted || widget.expense != null) return;
    final type = (extras['type'] ?? '').toString();
    final amountStr = (extras['amount'] ?? '').toString();
    if (type == 'Income' || type == 'Expense') {
      setState(() {
        _transactionType = type;
      });
    }
    if (amountStr.isNotEmpty) {
      final parsed = double.tryParse(amountStr);
      if (parsed != null) {
        setState(() {
          _amount = parsed;
          _amountController.text = parsed.toStringAsFixed(2);
        });
      }
    }
  }

  // load categories on page load
  void _loadCategories() async {
    try {
      final categories = await _dbHelper.getCategories().timeout(const Duration(seconds: 5));
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _isLoadingCategories = false;
        _loadError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingCategories = false;
        _loadError = 'Failed to load categories';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to load categories. Please try again.')),
      );
    }
  }

  // load subcategories based on the selected category
  void _loadSubcategories(int categoryId) async {
    setState(() {
      _isLoadingSubcategories = true;
      _subcategories = [];
    });
    try {
      final subcategories = await _dbHelper.getSubcategories(categoryId).timeout(const Duration(seconds: 5));
      if (!mounted) return;
      setState(() {
        _subcategories = subcategories;
        _isLoadingSubcategories = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingSubcategories = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to load subcategories. Please try again.')),
      );
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final navigator = Navigator.of(context);
      final messenger = ScaffoldMessenger.of(context);
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
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(
            content: const Text('Transaction updated successfully!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      } else {
        // Insert new expense
        await _dbHelper.insertExpense(expense);
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(
            content: const Text('Transaction added successfully!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
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
      navigator.pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomePage(initialIndex: 3),
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
  
  Future<void> _loadRecentSms() async {
    if (widget.expense != null) return; // Don't load for edit mode
    
    setState(() {
      _isLoadingSms = true;
    });
    
    try {
      final smsService = SmsService();
      final hasPermission = await smsService.checkPermission();
      
      if (!hasPermission) {
        setState(() {
          _isLoadingSms = false;
        });
        return;
      }
      
      final transactions = await smsService.scanHistoricalSms(limit: 4);
      
      if (mounted) {
        setState(() {
          _recentSmsTransactions = transactions;
          _isLoadingSms = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingSms = false;
        });
      }
    }
  }
  
  void _fillFromSms(TransactionData transaction) async {
    // Set basic fields
    setState(() {
      _transactionType = transaction.type;
      _amount = transaction.amount;
      _amountController.text = transaction.amount.toStringAsFixed(2);
      _descriptionController.text = transaction.merchant ?? transaction.type;
      _date = DateFormat('yyyy-MM-dd').format(transaction.date);
      _dateController.text = _date;
      _paymentMethod = 'UPI';
    });
    
    // Auto-select category
    final suggestedCategory = SmsParser.getCategoryFromMerchant(transaction.merchant);
    final matchedCategory = _categories.firstWhere(
      (c) => c['categoryName'] == suggestedCategory,
      orElse: () => _categories.isNotEmpty ? _categories.first : {},
    );
    
    if (matchedCategory.isNotEmpty) {
      setState(() {
        _selectedCategory = matchedCategory['categoryId'];
      });
      _loadSubcategories(_selectedCategory!);
      
      // Wait a bit for subcategories to load, then select first
      await Future.delayed(const Duration(milliseconds: 300));
      if (_subcategories.isNotEmpty && mounted) {
        setState(() {
          _selectedSubcategory = _subcategories.first['subCategoryId'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: MinimalAppBar(
        title: widget.expense != null ? 'Edit Transaction' : 'Add Transaction',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 540,
              ),
              child: Card(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(value: 'Income', label: Text('Income'), icon: Icon(Icons.south_west)),
                            ButtonSegment(value: 'Expense', label: Text('Expense'), icon: Icon(Icons.north_east)),
                          ],
                          selected: {_transactionType},
                          onSelectionChanged: (s) {
                            setState(() {
                              _transactionType = s.first;
                              _selectedCategory = null;
                              _selectedSubcategory = null;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Transaction Detail',
                            prefixIcon: Icon(Icons.text_fields),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the detail.';
                            }
                            return null;
                          },
                          onSaved: (value) => _name = value!,
                        ),
                        const SizedBox(height: 12),
                        if (_isLoadingCategories)
                          const LinearProgressIndicator(minHeight: 2)
                        else if (_loadError != null)
                          Text(
                            _loadError!,
                            style: TextStyle(color: Theme.of(context).colorScheme.error),
                          )
                        else
                          DropdownButtonFormField<int>(
                            isExpanded: true,
                            value: _selectedCategory,
                            menuMaxHeight: 360,
                            decoration: const InputDecoration(
                              labelText: 'Category',
                              prefixIcon: Icon(Icons.category_outlined),
                            ),
                            items: _categories.map((category) {
                              return DropdownMenuItem<int>(
                                value: category['categoryId'] as int,
                                child: Text(category['categoryName'] as String),
                              );
                            }).toList(),
                            onChanged: (int? newValue) {
                              setState(() {
                                _selectedCategory = newValue;
                                _selectedSubcategory = null;
                              });
                              if (newValue != null) {
                                _loadSubcategories(newValue);
                              }
                            },
                            validator: (value) => value == null ? 'Please select a category.' : null,
                            onSaved: (value) => _selectedCategory = value,
                          ),
                        const SizedBox(height: 12),
                        if (_selectedCategory == null)
                          const Text('Select a category first')
                        else if (_isLoadingSubcategories)
                          const LinearProgressIndicator(minHeight: 2)
                        else
                          DropdownButtonFormField<int>(
                            isExpanded: true,
                            value: _selectedSubcategory,
                            menuMaxHeight: 360,
                            decoration: const InputDecoration(
                              labelText: 'Subcategory',
                              prefixIcon: Icon(Icons.label_outline),
                            ),
                            items: _subcategories.map((subcategory) {
                              return DropdownMenuItem<int>(
                                value: subcategory['subCategoryId'] as int,
                                child: Text(subcategory['subCategoryName'] as String),
                              );
                            }).toList(),
                            onChanged: (int? newValue) => setState(() => _selectedSubcategory = newValue),
                            validator: (value) => value == null ? 'Please select a subcategory.' : null,
                            onSaved: (value) => _selectedSubcategory = value,
                          ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _amountController,
                          focusNode: _amountFocusNode,
                          decoration: const InputDecoration(
                            labelText: 'Amount',
                            prefixIcon: Icon(Icons.currency_rupee),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) => (value == null || value.isEmpty) ? 'Please enter an amount.' : null,
                          onSaved: (value) => _amount = double.parse(value!),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _dateController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Date',
                            prefixIcon: Icon(Icons.event),
                          ),
                          onTap: () => _selectDate(context),
                          validator: (value) => (value == null || value.isEmpty) ? 'Select date.' : null,
                          onSaved: (value) => _date = value!,
                        ),
                        const SizedBox(height: 12),
                        Text('Payment Method', style: Theme.of(context).textTheme.labelLarge),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: _paymentMethods.map((m) {
                            final selected = _paymentMethod == m;
                            return ChoiceChip(
                              label: Text(m),
                              selected: selected,
                              onSelected: (_) => setState(() => _paymentMethod = m),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        PrimaryButton(
                          onPressed: _submitForm,
                          text: widget.expense != null ? 'Save Transaction' : 'Add Transaction',
                          icon: Icons.check,
                        ),
                        
                        // SMS Suggestions Section
                        if (widget.expense == null && (_isLoadingSms || _recentSmsTransactions.isNotEmpty)) ...[
                          const SizedBox(height: 24),
                          const Divider(),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.sms, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Recent SMS Transactions',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (_isLoadingSms)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else if (_recentSmsTransactions.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'No recent bank transactions found in SMS',
                                style: Theme.of(context).textTheme.bodySmall,
                                textAlign: TextAlign.center,
                              ),
                            )
                          else
                            ..._recentSmsTransactions.map((tx) => Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                dense: true,
                                leading: CircleAvatar(
                                  backgroundColor: tx.type == 'Income'
                                      ? Colors.green.withOpacity(0.2)
                                      : Colors.red.withOpacity(0.2),
                                  child: Icon(
                                    tx.type == 'Income' ? Icons.arrow_downward : Icons.arrow_upward,
                                    color: tx.type == 'Income' ? Colors.green : Colors.red,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  '₹${tx.amount.toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  tx.merchant ?? tx.type,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                trailing: TextButton(
                                  onPressed: () => _fillFromSms(tx),
                                  child: const Text('Use'),
                                ),
                              ),
                            )).toList(),
                        ],
                      ],
                    ),
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
