import 'package:expenses_tracker/pages/login_page.dart';
import 'package:expenses_tracker/pages/signup_page.dart';
import 'package:expenses_tracker/styles/app_styles.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3), () {});
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignUpPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context)
            .size
            .width, // Set the width to the screen's width
        height: MediaQuery.of(context)
            .size
            .height, // Set the height to the screen's height

        padding: EdgeInsets.zero,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/logo.png", width: 100, height: 100),
            const SizedBox(height: 20),
            Text(
              'Expenses Tracker',
              style: Styles.logo,
            ),
            Text(
              'Track Smart, Spend Wise.',
              style: Styles.splashBody,
            ),
          ],
        ),
      ),
    );
  }
}
