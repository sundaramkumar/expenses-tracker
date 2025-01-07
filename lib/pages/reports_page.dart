import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../databases/database_helper.dart';

class ReportsPage extends StatefulWidget {
  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  DateTime? _fromDate;
  DateTime? _toDate;
  String _filterOption = 'Both';
  List<Map<String, dynamic>> _transactions = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final NumberFormat _currencyFormat =
      NumberFormat.currency(symbol: '', decimalDigits: 2);

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    if (_fromDate != null && _toDate != null) {
      final transactions =
          await _dbHelper.getExpensesByDateRange(_fromDate!, _toDate!);
      setState(() {
        _transactions = transactions.where((transaction) {
          if (_filterOption == 'Both') return true;
          if (_filterOption == 'Income') return transaction['credit'] > 0;
          if (_filterOption == 'Expenses') return transaction['debit'] > 0;
          return false;
        }).toList();
      });
    }
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != (isFromDate ? _fromDate : _toDate)) {
      setState(() {
        if (isFromDate) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });
      _fetchTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reports'),
        backgroundColor: Colors.red,
        toolbarHeight: 45,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _dateFilters(context),
            SizedBox(height: 16),
            _transactionType(context),
            SizedBox(height: 16),
            Expanded(
              child: _generateDataTable(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateFilters(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'From Date',
              hintStyle: TextStyle(fontSize: 8, color: Colors.grey),
              hintText: _fromDate == null
                  ? 'Select Date'
                  : DateFormat('yyyy-MM-dd').format(_fromDate!),
            ),
            onTap: () => _selectDate(context, true),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'To Date',
              hintStyle: TextStyle(fontSize: 8, color: Colors.grey),
              hintText: _toDate == null
                  ? 'Select Date'
                  : DateFormat('yyyy-MM-dd').format(_toDate!),
            ),
            onTap: () => _selectDate(context, false),
          ),
        ),
      ],
    );
  }

  Widget _transactionType(BuildContext context) {
    return Row(
      children: [
        Text('Transaction Type: '),
        DropdownButton<String>(
          value: _filterOption,
          onChanged: (String? newValue) {
            setState(() {
              _filterOption = newValue!;
            });
            _fetchTransactions();
          },
          items: <String>['Income', 'Expenses', 'Both']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _generateDataTable(BuildContext context) {
    if (_transactions.isEmpty) {
      return Container();
    }
    return Container(
      // padding: EdgeInsets.only(left: 10, right: 10),
      width: double.infinity,
      child: DataTable(
        horizontalMargin: 15,
        headingRowHeight: 20,
        border: TableBorder.symmetric(
            inside: BorderSide(width: 1, color: Colors.transparent),
            outside: BorderSide(width: 1, color: Colors.grey)),
        columns: [
          // DataColumn(label: Text('Date')),
          DataColumn(label: Text('Description')),
          DataColumn(label: Text('Amount')),
          // DataColumn(label: Text('Type')),
        ],
        rows: _transactions.map((transaction) {
          return DataRow(cells: [
            DataCell(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(transaction['description']),
                  SizedBox(height: 1),
                  Text(
                    transaction['transactionDate'],
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
            // DataCell(Text(transaction['description'],
            //     overflow: TextOverflow.ellipsis, softWrap: false)),
            DataCell(Container(
              alignment: Alignment.centerRight,
              child: Text(
                  transaction['credit'] > 0
                      ? _currencyFormat
                          .format(transaction['credit'])
                          .toString()
                          .padLeft(10, ' ')
                      : _currencyFormat
                          .format(transaction['debit'])
                          .toString()
                          .padLeft(10, ' '),
                  style: TextStyle(
                    color:
                        transaction['credit'] > 0 ? Colors.green : Colors.red,
                  )),
            )),
            // DataCell(Text(
            //     transaction['credit'] > 0 ? 'Income' : 'Expenses')),
          ]);
        }).toList(),
      ),
    );
  }
}
