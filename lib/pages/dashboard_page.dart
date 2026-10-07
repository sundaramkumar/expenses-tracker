import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../databases/database_helper.dart';
import 'package:pie_chart/pie_chart.dart';
import '../utils/widgets/app_bars.dart';
import '../utils/widgets/stat_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with AutomaticKeepAliveClientMixin {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _transactions = [];
  final NumberFormat _currencyFormat =
      NumberFormat.currency(symbol: '', decimalDigits: 2);
  DateTime _selectedMonth = DateTime.now();
  double _totalIncome = 0.0;
  double _totalExpenses = 0.0;
  double get _balance => _totalIncome - _totalExpenses;

  @override
  bool get wantKeepAlive => false;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  @override
  void didUpdateWidget(DashboardPage oldWidget) {
    super.didUpdateWidget(oldWidget);
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
    super.build(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: const MinimalAppBar(title: 'Dashboard'),
      body: RefreshIndicator(
        onRefresh: _fetchTransactions,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildMonthSelector(),
              const SizedBox(height: 8),
              // Summary stats (responsive)
              _buildResponsiveStats(theme),
              const SizedBox(height: 12),
              _buildIncomeExpensesChart(),
              const SizedBox(height: 12),
              _buildIncomesSection(),
              const SizedBox(height: 12),
              _buildExpensesSection(),
            ],
          ),
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

  Widget _buildExpensesSection() {
    var expenseTx =
        _transactions.where((t) => (t['debit'] ?? 0) > 0).toList();
    if (expenseTx.isEmpty) return Container();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Expenses',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DataTable(
              horizontalMargin: 12,
              headingRowHeight: 28,
              columns: const [
                DataColumn(label: Text('Description')),
                DataColumn(label: Text('Amount')),
              ],
              rows: expenseTx.map((t) {
                return DataRow(cells: [
                  DataCell(Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        t['description'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        t['transactionDate'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  )),
                  DataCell(Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      _currencyFormat.format(t['debit'] ?? 0),
                      style: const TextStyle(color: Colors.red),
                    ),
                  )),
                ]);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveStats(ThemeData theme) {
    return LayoutBuilder(builder: (context, constraints) {
      final double width = constraints.maxWidth;
      // Determine number of columns based on available width
      int columns = 1;
      if (width >= 1000) {
        columns = 3;
      } else if (width >= 680) {
        columns = 2;
      }
      const spacing = 8.0;
      final itemWidth = (width - spacing * (columns - 1)) / columns;

      final tiles = [
        StatCard(
          label: 'Income',
          amount: _totalIncome,
          color: theme.colorScheme.tertiary,
          icon: Icons.arrow_downward,
        ),
        StatCard(
          label: 'Expenses',
          amount: _totalExpenses,
          color: theme.colorScheme.error,
          icon: Icons.arrow_upward,
        ),
        StatCard(
          label: 'Balance',
          amount: _balance,
          color: theme.colorScheme.primary,
          icon: Icons.account_balance_wallet_outlined,
        ),
      ];

      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: tiles
            .map((t) => SizedBox(width: itemWidth.clamp(220, 420), child: t))
            .toList(),
      );
    });
  }

  Widget _buildIncomesSection() {
    var incomeTx =
        _transactions.where((t) => (t['credit'] ?? 0) > 0).toList();
    if (incomeTx.isEmpty) return Container();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Incomes',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DataTable(
              horizontalMargin: 12,
              headingRowHeight: 28,
              columns: const [
                DataColumn(label: Text('Description')),
                DataColumn(label: Text('Amount')),
              ],
              rows: incomeTx.map((t) {
                return DataRow(cells: [
                  DataCell(Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        t['description'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        t['transactionDate'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  )),
                  DataCell(Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      _currencyFormat.format(t['credit'] ?? 0),
                      style: const TextStyle(color: Colors.green),
                    ),
                  )),
                ]);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
