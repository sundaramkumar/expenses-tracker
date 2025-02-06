import 'package:expenses_tracker/pages/signup_page.dart';
import 'package:expenses_tracker/styles/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:expenses_tracker/pages/dashboard_page.dart';
import 'package:expenses_tracker/pages/reports_page.dart';
import 'package:expenses_tracker/pages/expense_page.dart';
import 'package:expenses_tracker/pages/transactions_page.dart';
import 'package:expenses_tracker/pages/settings_page.dart';

import 'package:expenses_tracker/pages/login_page.dart';

class HomePage extends StatefulWidget {
  final Widget body;
  final int currentIndex;

  HomePage({required this.body, required this.currentIndex});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _children = [
    // LoginPage(),
    DashboardPage(), //0
    ReportsPage(), //1
    ExpensePage(), //2
    TransactionsPage(), //3
    SettingsPage(), //4
    SignUpPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(
          body: _children[index],
          currentIndex: index,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Expenses Tracker'),
      //   backgroundColor: Colors.red,
      //   foregroundColor: Colors.white,
      // ),
      body: widget.body,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_kanban),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add New',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: widget.currentIndex,
        selectedItemColor: Colors.amber[800],
        showUnselectedLabels: true, // show all the labels
        type: BottomNavigationBarType.fixed,
        backgroundColor: Styles.bottomNavBgColor,
        unselectedItemColor: Colors.white,
        onTap: _onItemTapped,
      ),
    );
  }
}
