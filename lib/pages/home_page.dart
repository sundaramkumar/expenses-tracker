// import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:expenses_tracker/pages/dashboard_page.dart';
import 'package:expenses_tracker/pages/expense_page.dart';
import 'package:expenses_tracker/pages/reports_page.dart';
import 'package:expenses_tracker/pages/settings_page.dart';
import 'package:expenses_tracker/pages/transactions_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  // final NotchBottomBarController _pageController = NotchBottomBarController();

  final List<Widget> _children = [
    DashboardPage(),
    ReportsPage(),
    ExpensePage(),
    TransactionsPage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      print(_selectedIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses Tracker'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.blueAccent,
        // color: Colors.grey[200],
        child: _children[_selectedIndex],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        color: Colors.white,
        backgroundColor: Colors.grey[200]!,
        animationDuration: Duration(milliseconds: 300),
        // buttonBackgroundColor: Colors.red,
        height: 50,
        items: <Widget>[
          Icon(
            Icons.home,
            size: 30,
            semanticLabel: 'Home',
          ),
          Icon(Icons.view_kanban, size: 30),
          Icon(Icons.add_circle, size: 30),
          Icon(Icons.list_alt, size: 30),
          Icon(Icons.settings, size: 30),
        ],
        onTap: _onItemTapped,

        // bottomNavigationBar: BottomNavigationBar(
        //   showUnselectedLabels: true, // show all the labels
        //   type: BottomNavigationBarType.fixed,
        //   backgroundColor: Colors.red,
        //   unselectedItemColor: Colors.white, // show all the labels in white
        //   currentIndex: _selectedIndex,
        //   selectedItemColor: Colors.amber[300],
        //   onTap: _onItemTapped,
        //   items: const <BottomNavigationBarItem>[
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.home, color: Color.fromARGB(255, 255, 255, 255)),
        //       label: 'Home',
        //       backgroundColor: Colors.red,
        //     ),
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.view_kanban,
        //           color: Color.fromARGB(255, 255, 255, 255)),
        //       label: 'Reports',
        //       backgroundColor: Colors.red,
        //     ),
        //     BottomNavigationBarItem(
        //       // add new expense
        //       icon: Icon(Icons.add_circle,
        //           color: Color.fromARGB(255, 255, 255, 255)),
        //       label: ' ',
        //       backgroundColor: Colors.red,
        //     ),
        //     BottomNavigationBarItem(
        //       icon:
        //           Icon(Icons.list_alt, color: Color.fromARGB(255, 255, 255, 255)),
        //       label: 'Reports',
        //       backgroundColor: Colors.red,
        //     ),
        //     BottomNavigationBarItem(
        //       icon:
        //           Icon(Icons.settings, color: Color.fromARGB(255, 255, 255, 255)),
        //       label: 'Settings',
        //       backgroundColor: Colors.red,
        //     ),
        //   ],
        // ),
      ),
    );
  }
}
