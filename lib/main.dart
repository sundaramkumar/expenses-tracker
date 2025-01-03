import 'package:expenses_tracker/pages/home_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ExpensesTracker());
}

class ExpensesTracker extends StatelessWidget {
  const ExpensesTracker({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expenses Tracker',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
