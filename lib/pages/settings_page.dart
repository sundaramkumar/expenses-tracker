import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.red,
        toolbarHeight: 45,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.grey[200],
        child: Center(
          child: Text(
            'Settings Page',
          ),
        ),
      ),
    );
  }
}
