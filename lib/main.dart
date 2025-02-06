import 'package:expenses_tracker/pages/dashboard_page.dart';
import 'package:expenses_tracker/pages/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:expenses_tracker/pages/home_page.dart';
import 'package:expenses_tracker/pages/transactions_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expenses Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
      // home: HomePage(
      //   body: SplashScreen(),
      //   currentIndex: 0,
      // ),
    );
  }
}
