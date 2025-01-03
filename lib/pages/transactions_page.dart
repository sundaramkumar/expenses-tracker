import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../databases/database_helper.dart';

class TransactionsPage extends StatefulWidget {
  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  List<Map<String, dynamic>> _transactions = [];
  final NumberFormat _currencyFormat =
      NumberFormat.currency(symbol: '', decimalDigits: 2);

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    // final dbHelper = DatabaseHelper.instance;
    final DatabaseHelper dbHelper = DatabaseHelper();
    final transactions = await dbHelper.getExpenses();
    print(transactions);
    setState(() {
      _transactions = transactions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transactions'),
        backgroundColor: Colors.grey[200],
      ),
      body: Container(
        color: Colors.grey[200],
        child: _transactions.isEmpty
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('description')),
                    DataColumn(label: Text('credit')),
                    DataColumn(label: Text('debit')),
                    DataColumn(label: Text('Category')),
                    DataColumn(label: Text('Subcategory')),
                  ],
                  rows: _transactions.map((transaction) {
                    return DataRow(cells: [
                      DataCell(Text(transaction['transactionDate'].toString())),
                      DataCell(Text(transaction['description'].toString())),
                      DataCell(
                          Text(_currencyFormat.format(transaction['credit']))),
                      DataCell(
                          Text(_currencyFormat.format(transaction['debit']))),
                      DataCell(Text(transaction['categoryName'].toString())),
                      DataCell(Text(transaction['subCategoryName'].toString())),
                    ]);
                  }).toList(),
                ),
              ),
      ),
    );
  }
}
