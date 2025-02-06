import 'package:expenses_tracker/styles/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../databases/database_helper.dart';
import 'package:pie_chart/pie_chart.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _transactions = [];
  final NumberFormat _currencyFormat =
      NumberFormat.currency(symbol: '', decimalDigits: 2);
  DateTime _selectedMonth = DateTime.now();
  double _totalIncome = 0.0;
  double _totalExpenses = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    final transactions = await _dbHelper.getExpensesByDateRange(
      DateTime(_selectedMonth.year, _selectedMonth.month, 1)
          .subtract(Duration(days: 1)),
      DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1)
          .subtract(Duration(days: 1)),
    );
    double totalIncome = 0.0;
    double totalExpenses = 0.0;
    for (var transaction in transactions) {
      if (transaction['debit'] > 0) {
        totalExpenses += transaction['debit'];
      } else {
        totalIncome += transaction['credit'];
      }
    }

    setState(() {
      _transactions = transactions;
      _totalIncome = totalIncome;
      _totalExpenses = totalExpenses;
    });
  }

  void _selectMonth(DateTime month) {
    setState(() {
      _selectedMonth = month;
    });
    _fetchTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        backgroundColor: Styles.appBgColor,
        toolbarHeight: 45,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            _buildMonthSelector(),
            _buildIncomeExpensesChart(),
            _buildIncomesList(),
            _buildExpensesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Padding(
      padding: const EdgeInsets.only(top: 0, left: 4, right: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(12, (index) {
            DateTime month = DateTime(DateTime.now().year, index + 1, 1);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: ChoiceChip(
                // backgroundColor: Styles.chipBodyColor,
                label: Text(DateFormat.MMMM().format(month)),
                selected: _selectedMonth.month == month.month,
                side: BorderSide(
                  color: Colors.grey,
                  width: 1,
                ),
                shape: StadiumBorder(side: BorderSide.none),
                padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 2.0),
                avatarBorder:
                    CircleBorder(side: BorderSide.none, eccentricity: 0.9),
                onSelected: (selected) {
                  if (selected) {
                    _selectMonth(month);
                  }
                },
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildIncomeExpensesChart() {
    if (_transactions.isEmpty) {
      return Column(
        children: [
          Text('No Data found',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ],
      );
    }

    Map<String, double> dataMap = {
      "Income": _totalIncome,
      "Expenses": _totalExpenses,
    };

    var colorList = [
      Colors.indigoAccent,
      Colors.redAccent,
    ];
    return Column(
      children: [
        SizedBox(height: 20),
        PieChart(
          dataMap: dataMap,
          animationDuration: Duration(milliseconds: 800),
          chartLegendSpacing: 32,
          chartRadius: MediaQuery.of(context).size.width / 3.2,
          colorList: colorList,
          initialAngleInDegree: 0,
          chartType: ChartType.ring,
          ringStrokeWidth: 32,
          centerText: "",
          legendOptions: LegendOptions(
            showLegendsInRow: false,
            legendPosition: LegendPosition.right,
            showLegends: true,
            legendShape: BoxShape.circle,
            legendTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          chartValuesOptions: ChartValuesOptions(
            showChartValueBackground: true,
            showChartValues: true,
            showChartValuesInPercentage: false,
            showChartValuesOutside: false,
            decimalPlaces: 2,
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildExpensesList() {
    var _expenseTransactions =
        _transactions.where((transaction) => transaction['debit'] > 0).toList();
    if (_expenseTransactions.isEmpty) {
      return Container();
    }
    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Text('Expenses',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            Container(
              padding: EdgeInsets.only(left: 10, right: 10),
              width: double.infinity,
              child: DataTable(
                horizontalMargin: 15,
                headingRowHeight: 25,
                border: TableBorder.symmetric(
                    inside: BorderSide(width: 1, color: Colors.transparent),
                    outside: BorderSide(width: 1, color: Colors.grey)),
                columns: [
                  DataColumn(label: Text('Description')),
                  DataColumn(label: Text('Amount')),
                ],
                rows: _expenseTransactions.map((transaction) {
                  return DataRow(cells: [
                    // DataCell(Text(transaction['transactionDate'])),
                    DataCell(Column(
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
                    )),
                    DataCell(Container(
                      alignment: Alignment.centerRight,
                      child: Text(
                        _currencyFormat
                            .format(transaction['debit'])
                            .toString()
                            .padLeft(10, ' '),
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    )),
                  ]);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomesList() {
    if (_transactions.isEmpty) {
      return Container();
    }

    var _incomeTransactions = _transactions
        .where((transaction) => transaction['credit'] > 0)
        .toList();
    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Text('Incomes',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            Container(
              padding: EdgeInsets.only(left: 10, right: 10),
              width: double.infinity,
              child: DataTable(
                horizontalMargin: 15,
                headingRowHeight: 25,
                border: TableBorder.symmetric(
                    inside: BorderSide(width: 1, color: Colors.transparent),
                    outside: BorderSide(width: 1, color: Colors.grey)),
                columns: [
                  DataColumn(label: Text('Description')),
                  DataColumn(label: Text('Amount')),
                ],
                rows: _incomeTransactions.map((transaction) {
                  return DataRow(cells: [
                    // DataCell(Text(transaction['transactionDate'])),
                    DataCell(Column(
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
                    )),
                    DataCell(Container(
                      alignment: Alignment.centerRight,
                      child: Text(
                        _currencyFormat
                            .format(transaction['credit'])
                            .toString()
                            .padLeft(10, ' '),
                        style: TextStyle(
                          color: Colors.green,
                        ),
                      ),
                    )),
                  ]);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
