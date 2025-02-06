import 'package:expenses_tracker/pages/categories_page.dart';
import 'package:expenses_tracker/pages/subcategories_page.dart';
import 'package:expenses_tracker/pages/userprofile_page.dart';
import 'package:flutter/material.dart';
import 'package:text_scroll/text_scroll.dart';
// import '../databases/database_helper.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  // final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final availableHeight =
        mediaQuery.size.height - mediaQuery.padding.top - kToolbarHeight;
    print(availableHeight);
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.red,
        toolbarHeight: 45,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Container(
          height: availableHeight,
          color: Colors.grey[200],
          child: Column(
            children: [
              SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: 210, // Fixed width
                  height: 135,
                  child: Card(
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        Icon(Icons.person, size: 50),
                        ListTile(
                          title:
                              Text('User Profile', textAlign: TextAlign.center),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UserProfilePage()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: 210, // Fixed width
                  height: 135,
                  child: Card(
                    child: Column(
                      children: [
                        SizedBox(height: 15),
                        Icon(Icons.category, size: 50),
                        ListTile(
                          title:
                              Text('Categories', textAlign: TextAlign.center),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CategoriesPage()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: 210, // Fixed width
                  height: 135,
                  child: Card(
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        Icon(Icons.subdirectory_arrow_right, size: 50),
                        ListTile(
                          title: Text('Subcategories',
                              textAlign: TextAlign.center),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SubcategoriesPage()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                            20.0), // Set the border radius here
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    TextScroll(
                      textAlign: TextAlign.end,
                      'Daily Expenses Tracker developed By Kumar Sundaram. Copyright © 2025. All rights reserved.',
                      velocity: const Velocity(pixelsPerSecond: Offset(25, 0)),
                      delayBefore: const Duration(milliseconds: 500),
                      // numberOfReps: 5,
                      pauseBetween: const Duration(milliseconds: 50),
                      style: const TextStyle(color: Colors.black, fontSize: 10),
                      selectable: true,
                      // mode: TextScrollMode.bouncing,
                      // overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // TextScroll('Developed By Kumar Sundaram'),
              TextScroll(
                textAlign: TextAlign.end,
                'Daily Expenses Tracker developed By Kumar Sundaram. Copyright © 2025. All rights reserved.',
                velocity: const Velocity(pixelsPerSecond: Offset(25, 0)),
                delayBefore: const Duration(milliseconds: 500),
                // numberOfReps: 5,
                pauseBetween: const Duration(milliseconds: 50),
                style: const TextStyle(color: Colors.black, fontSize: 10),
                selectable: true,
                // mode: TextScrollMode.bouncing,
                // overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
