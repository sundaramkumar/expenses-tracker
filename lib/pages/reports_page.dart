import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
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
  List<FlSpot> expenseSpots = [];
  List<FlSpot> _expenseSpots = [];
  List<String> dateLabels = [];
  int index = 0;
  Map<String, double> dailyExpenses = {};
  double maxExpense = 0.0;
  double interval = 1.0;

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

    // reset variables
    dailyExpenses = {};
    expenseSpots = [];
    _expenseSpots = [];
    dateLabels = [];

    // Calculate daily expenses
    _transactions.where((txn) => txn['debit'] > 0).forEach((txn) {
      String dateKey = txn['transactionDate'];
      dailyExpenses.update(dateKey, (value) => value + txn['debit'].toDouble(),
          ifAbsent: () => txn['debit'].toDouble());
    });

    dailyExpenses.forEach((date, amount) {
      expenseSpots.add(FlSpot(index.toDouble(), amount));
      dateLabels.add(date);
      index++;
    });

    setState(() {
      _expenseSpots = expenseSpots;
    });

    // Calculate max expense value for Y-axis limit
    maxExpense = dailyExpenses.isNotEmpty
        ? dailyExpenses.values.reduce((a, b) => a > b ? a : b)
        : 100;
    interval =
        (maxExpense / 5).ceilToDouble(); // Dynamic interval for better scaling
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
              child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      if (_filterOption != 'Income') _generateExpenseChart(),
                      SizedBox(height: 16),
                      _generateDataTable(context),
                    ],
                  )),
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

/*************  ✨ Codeium Command ⭐  *************/
  /// Generates a line chart widget displaying the expenses over a selected
  /// date range. The chart includes dynamic Y-axis scaling based on the
  /// maximum expense value and labels on both the X and Y axes. The X-axis
  /// labels represent the dates of transactions, while the Y-axis labels
  /// represent the expense amounts. The chart is styled with a bold title
  /// and a light red area under the curve to highlight the expenses.

/******  138fc70a-5ddd-4fae-99d3-69c7510df473  *******/
  Widget _generateExpenseChart() {
    return Column(
      children: [
        Text('Expenses Chart', style: TextStyle(fontWeight: FontWeight.bold)),
        Container(
          height: 300,
          child: LineChart(
            LineChartData(
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      int index = value.toInt();
                      if (index >= 0 && index < dateLabels.length) {
                        return Text(
                          DateFormat('MM/dd').format(DateFormat('yyyy-MM-dd')
                              .parse(dateLabels[index])),
                          style: const TextStyle(fontSize: 10),
                          textAlign: TextAlign.center,
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: interval, // Set dynamic interval for Y-axis
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text('${value.toInt()}',
                          style: const TextStyle(fontSize: 10));
                    },
                  ),
                ),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: interval,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withAlpha(51),
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  );
                },
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: _expenseSpots, // Set expense data points
                  isCurved: true,
                  color: Colors.redAccent,
                  barWidth: 2,
                  dotData: const FlDotData(
                      show: true), // Show dots on each data point
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.redAccent
                        .withAlpha(51), // Light red area under the curve
                  ),
                ),
              ],
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.black.withAlpha(76)),
              ),
              minY: 0,
              maxY: maxExpense +
                  (interval * 2), // Add extra space above the highest expense
            ),
          ),
        ),
      ],
    );
  }
}
