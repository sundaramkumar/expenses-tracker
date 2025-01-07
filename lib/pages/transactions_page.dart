import 'package:expenses_tracker/pages/expense_page.dart';
import 'package:expenses_tracker/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import '../databases/database_helper.dart';

class TransactionsPage extends StatefulWidget {
  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _transactions = [];
  final NumberFormat _currencyFormat =
      NumberFormat.currency(symbol: '', decimalDigits: 2);

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    final transactions = await dbHelper.getExpenses();
    setState(() {
      _transactions = transactions;
    });
  }

  void _confirmDelete(BuildContext context, int transactionId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this transaction?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                _deleteTransaction(transactionId);
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteTransaction(int transactionId) async {
    await dbHelper.deleteExpense(transactionId);
    _fetchTransactions();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Transaction deleted successfully!'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LiquidPullToRefresh(
      color: Colors.red,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      springAnimationDurationInMilliseconds: 700,
      height: 200,
      onRefresh: _fetchTransactions,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Transactions'),
          backgroundColor: Colors.red,
          toolbarHeight: 45,
          foregroundColor: Colors.white,
        ),
        body: Container(
          color: Colors.grey[200],
          child: CustomScrollView(
            scrollDirection: Axis.vertical,
            slivers: <Widget>[
              SliverPadding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                sliver: SliverFixedExtentList(
                  itemExtent: 172.0,
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        _buildTransactionRow(_transactions[index]),
                    childCount: _transactions.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionRow(Map<String, dynamic> transaction) {
    final transactionCardContent = Container(
      margin: EdgeInsets.all(7.0),
      constraints: BoxConstraints.expand(),
      child: Container(
        // height: 4.0,
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(transaction['categoryName'],
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 5.0),
                    Text(transaction['subCategoryName'].toString()),
                    // SizedBox(height: 5.0),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        // SizedBox(width: 5.0),
                        Text(
                          transaction['transactionDate'].toString(),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 5.0),
                    Text(
                      transaction['credit'] > 0
                          ? _currencyFormat
                              .format(transaction['credit'])
                              .toString()
                              .padLeft(10, ' ')
                          : _currencyFormat
                              .format(transaction['debit'])
                              .toString()
                              .padLeft(13, ' '),
                      textAlign: TextAlign.right,
                    ),
                    // SizedBox(height: 5.0),
                  ],
                ),
              ],
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                // Text('Amount to give:'),
                Flexible(
                  child: Text(transaction['description'],
                      softWrap: true, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Image.asset(
                            transaction['credit'] > 0
                                ? 'assets/icons/income.png'
                                : 'assets/icons/expense.png',
                            height: 30.0),
                      ]),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        SizedBox(height: 5),
                        Row(
                          children: [],
                        ),
                      ])
                ]),
          ],
        ),
      ),
    );

    final transactionCard = Container(
      child: transactionCardContent,
      height: 140.0,
      decoration: BoxDecoration(
        color: Color(0xFFFFFFFF),
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10.0,
            offset: Offset(0.0, 10.0),
          ),
        ],
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(left: 25.0, right: 25, top: 25),
      child: Slidable(
        endActionPane: ActionPane(motion: const StretchMotion(), children: [
          CustomSlidableAction(
            onPressed: (context) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(
                    body: ExpensePage(expense: transaction),
                    currentIndex: 2,
                  ),
                ),
              );
            },
            backgroundColor: Colors.grey,
            foregroundColor: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              bottomLeft: Radius.circular(10),
            ),
            child: Icon(
              Icons.edit,
              color: Colors.white,
              size: 30,
            ),
          ),
          CustomSlidableAction(
            onPressed: (context) {
              _confirmDelete(context, transaction['id']);
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
            child: Icon(
              Icons.delete,
              color: Colors.white,
              size: 30,
            ),
          )
        ]),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(10),
          ),
          child: transactionCard,
        ),
      ),
    );
  }
}
