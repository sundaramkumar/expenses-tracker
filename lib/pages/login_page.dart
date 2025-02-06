import 'package:expenses_tracker/databases/database_helper.dart';
import 'package:expenses_tracker/pages/dashboard_page.dart';
import 'package:expenses_tracker/pages/home_page.dart';
import 'package:expenses_tracker/pages/signup_page.dart';
import 'package:flutter/material.dart';

import '../styles/app_styles.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final DatabaseHelper dbHelper = DatabaseHelper();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.lock, size: 40, color: Colors.black),
                    Text(
                      'Log In',
                      style: Styles.heading,
                      textAlign: TextAlign.center,
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to login page
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignUpPage()),
                        );
                      },
                      child: Text(
                        'Sign Up',
                        style: Styles.headingLinks,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Text('Welcome back! You\'ve been missed',
                    style: Styles.bodyContnt),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    filled: true,
                    fillColor: Styles.inputFillColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    filled: true,
                    fillColor: Styles.inputFillColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    suffixIcon: TextButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      child: Text(
                        _obscurePassword ? 'Show' : 'Hide',
                        style: TextStyle(
                          color: Styles.bodyTextColor,
                        ),
                      ),
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Navigator.pushReplacement(
                    //   context,
                    //   MaterialPageRoute(
                    //       builder: (context) => HomePage(
                    //             body: DashboardPage(),
                    //             currentIndex: 0,
                    //           )),
                    // );
                    if (_formKey.currentState!.validate()) {
                      // Handle login logic here
                      loginUser();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Styles.btnBackgroundColor,
                    foregroundColor: Styles.btnForegroundColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Log In',
                    style: Styles.button,
                  ),
                ),
                // const SizedBox(height: 16),
                // TextButton(
                //   onPressed: () {
                //     // Handle forgot password logic
                //   },
                //   child: Text(
                //     'Forgot your password?',
                //     style: Styles.links,
                //   ),
                // ),
                const SizedBox(height: 16),
                Divider(
                  color: Styles.bodyTextColor,
                  thickness: 1,
                ),
                const SizedBox(height: 16),
                Text(
                  'Or log in with',
                  style: Styles.bodyContnt,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/google.png', height: 40),
                    const SizedBox(width: 16),
                    Image.asset('assets/images/apple.png', height: 40),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void loginUser() {
    String email = _emailController.text;
    String password = _passwordController.text;

    dbHelper.loginUser(email, password).then((user) {
      print('user $user');
      if (user != null) {
        // Login successful
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => HomePage(
                    body: DashboardPage(),
                    currentIndex: 0,
                  )),
        );
      } else {
        // Login failed
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              // backgroundColor: Styles.appBgColor,
              // alignment: Alignment.center,
              title: Text('Login Failed', style: Styles.subHeadingSmall),
              content: Text(
                'Invalid email or password.',
                style: Styles.errorText,
              ),
              actions: <Widget>[
                TextButton(
                    style: Styles.cancelButtonStyle,
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
              ],
            );
          },
        );
      }
    }).catchError((error) {});
    // .whenComplete(() => dbHelper.close());
  }
}
