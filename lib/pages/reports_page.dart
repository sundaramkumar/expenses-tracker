import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../databases/database_helper.dart';
import '../utils/widgets/app_bars.dart';
import '../utils/widgets/primary_button.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});
  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  late DateTime _fromDate;
  late DateTime _toDate;
  String _filterOption = 'Expenses';
  List<Map<String, dynamic>> _transactions = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final NumberFormat _currencyFormat =
      NumberFormat.currency(symbol: '', decimalDigits: 2);
  List<FlSpot> _expenseSpots = [];
  List<String> dateLabels = [];
  Map<String, double> categoryExpenses = {};
  double maxExpense = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Default to current month
    final now = DateTime.now();
    _fromDate = DateTime(now.year, now.month, 1);
    _toDate = DateTime(now.year, now.month + 1, 0);
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    setState(() {
      _isLoading = true;
    });

    final transactions = await _dbHelper.getExpensesByDateRange(
        _fromDate.subtract(const Duration(days: 1)), _toDate);
    
    final filteredTransactions = transactions.where((transaction) {
      if (_filterOption == 'Both') return true;
      if (_filterOption == 'Income') return transaction['credit'] > 0;
      if (_filterOption == 'Expenses') return transaction['debit'] > 0;
      return false;
    }).toList();

    // Calculate daily expenses for line chart
    final Map<String, double> dailyExpenses = {};
    final List<FlSpot> expenseSpots = [];
    final List<String> labels = [];
    int index = 0;

    filteredTransactions.where((txn) => txn['debit'] > 0).forEach((txn) {
      String dateKey = txn['transactionDate'];
      dailyExpenses.update(dateKey, (value) => value + txn['debit'].toDouble(),
          ifAbsent: () => txn['debit'].toDouble());
    });

    dailyExpenses.forEach((date, amount) {
      expenseSpots.add(FlSpot(index.toDouble(), amount));
      labels.add(date);
      index++;
    });

    // Calculate category-wise expenses
    final Map<String, double> catExpenses = {};
    for (var txn in filteredTransactions.where((t) => t['debit'] > 0)) {
      String category = txn['categoryName'] ?? 'Other';
      double amount = txn['debit'].toDouble();
      catExpenses.update(category, (value) => value + amount,
          ifAbsent: () => amount);
    }

    setState(() {
      _transactions = filteredTransactions;
      _expenseSpots = expenseSpots;
      dateLabels = labels;
      categoryExpenses = catExpenses;
      maxExpense = dailyExpenses.isNotEmpty
          ? dailyExpenses.values.reduce((a, b) => a > b ? a : b)
          : 100;
      _isLoading = false;
    });
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
      appBar: const MinimalAppBar(title: 'Reports'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectDate(context, true),
                    icon: const Icon(Icons.date_range),
                    label: Text(DateFormat('MMM dd, yyyy').format(_fromDate)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectDate(context, false),
                    icon: const Icon(Icons.date_range),
                    label: Text(DateFormat('MMM dd, yyyy').format(_toDate)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'Both', label: Text('Both')),
                ButtonSegment(value: 'Income', label: Text('Income')),
                ButtonSegment(value: 'Expenses', label: Text('Expenses')),
              ],
              selected: {_filterOption},
              onSelectionChanged: (s) {
                setState(() => _filterOption = s.first);
              },
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: PrimaryButton(
                text: 'Fetch',
                icon: Icons.refresh,
                onPressed: _fetchTransactions,
              ),
            ),
            const SizedBox(height: 12),
            if (_expenseSpots.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'No data for selected range',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              )
            else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 260,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withValues(alpha: 0.15),
                            strokeWidth: 1,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: true, reservedSize: 36)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final idx = value.toInt();
                                if (idx < 0 || idx >= dateLabels.length) {
                                  return const SizedBox.shrink();
                                }
                                return Text(
                                  DateFormat('MM-dd')
                                      .format(DateTime.parse(dateLabels[idx])),
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData:
                            FlBorderData(show: true, border: Border.all(color: Colors.transparent)),
                        lineBarsData: [
                          LineChartBarData(
                            spots: _expenseSpots,
                            isCurved: true,
                            barWidth: 3.5,
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.6),
                              ],
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.25),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            dotData: const FlDotData(show: false),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text('Max: ${_currencyFormat.format(maxExpense)}'),
            ),
          ],
        ),
      ),
    );
  }
}
