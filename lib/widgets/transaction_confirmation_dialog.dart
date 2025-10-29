import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/sms_parser.dart';
import '../databases/database_helper.dart';
import '../services/sms_service.dart';

class TransactionConfirmationDialog extends StatefulWidget {
  final TransactionData transaction;

  const TransactionConfirmationDialog({
    super.key,
    required this.transaction,
  });

  @override
  State<TransactionConfirmationDialog> createState() =>
      _TransactionConfirmationDialogState();
}

class _TransactionConfirmationDialogState
    extends State<TransactionConfirmationDialog> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final SmsService _smsService = SmsService();

  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _subcategories = [];
  int? _selectedCategoryId;
  int? _selectedSubcategoryId;
  bool _isLoading = true;

  late TextEditingController _amountController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _amountController =
        TextEditingController(text: widget.transaction.amount.toStringAsFixed(2));
    _descriptionController = TextEditingController(
        text: widget.transaction.merchant ?? widget.transaction.type);
    _loadCategories();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final categories = await _dbHelper.getCategories();
    setState(() {
      _categories = categories;
      _isLoading = false;
    });

    // Auto-select category based on merchant
    if (_categories.isNotEmpty) {
      final suggestedCategory =
          SmsParser.getCategoryFromMerchant(widget.transaction.merchant);
      final matchedCategory = _categories.firstWhere(
        (c) => c['categoryName'] == suggestedCategory,
        orElse: () => _categories.first,
      );

      setState(() {
        _selectedCategoryId = matchedCategory['categoryId'];
      });
      _loadSubcategories(_selectedCategoryId!);
    }
  }

  Future<void> _loadSubcategories(int categoryId) async {
    final subcategories = await _dbHelper.getSubcategories(categoryId);
    setState(() {
      _subcategories = subcategories;
      _selectedSubcategoryId =
          subcategories.isNotEmpty ? subcategories.first['subCategoryId'] : null;
    });
  }

  Future<void> _save() async {
    if (_selectedCategoryId == null || _selectedSubcategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select category and subcategory')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid amount')),
      );
      return;
    }

    final transaction = TransactionData(
      amount: amount,
      type: widget.transaction.type,
      merchant: _descriptionController.text,
      date: widget.transaction.date,
      accountNumber: widget.transaction.accountNumber,
      referenceNumber: widget.transaction.referenceNumber,
      rawMessage: widget.transaction.rawMessage,
    );

    await _smsService.saveTransaction(
      transaction,
      _selectedCategoryId!,
      _selectedSubcategoryId!,
    );

    if (mounted) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction added successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      widget.transaction.type == 'Income'
                          ? Icons.arrow_downward
                          : Icons.arrow_upward,
                      color: widget.transaction.type == 'Income'
                          ? Colors.green
                          : Colors.red,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Confirm Transaction',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else ...[
                  // Amount
                  Text(
                    'Amount',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefixText: '₹ ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category
                  Text(
                    'Category',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: _selectedCategoryId,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: _categories
                        .map((cat) => DropdownMenuItem<int>(
                              value: cat['categoryId'],
                              child: Text(cat['categoryName']),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedCategoryId = value;
                        });
                        _loadSubcategories(value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Subcategory
                  Text(
                    'Subcategory',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: _selectedSubcategoryId,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: _subcategories
                        .map((subcat) => DropdownMenuItem<int>(
                              value: subcat['subCategoryId'],
                              child: Text(subcat['subCategoryName']),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSubcategoryId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Date
                  Text(
                    'Date',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(dateFormat.format(widget.transaction.date)),
                  ),
                  const SizedBox(height: 20),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _save,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Confirm'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
