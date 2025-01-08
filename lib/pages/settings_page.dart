import 'package:expenses_tracker/pages/categories_page.dart';
import 'package:expenses_tracker/pages/subcategories_page.dart';
import 'package:expenses_tracker/pages/userprofile_page.dart';
import 'package:flutter/material.dart';
// import '../databases/database_helper.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  // final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.red,
        toolbarHeight: 45,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.grey[200],
        child: ListView(
          children: [
            SizedBox(height: 20),
            Center(
              child: SizedBox(
                width: 165, // Fixed width
                height: 130,
                child: Card(
                  child: Column(
                    children: [
                      SizedBox(height: 15),
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
                width: 165, // Fixed width
                height: 130,
                child: Card(
                  child: Column(
                    children: [
                      SizedBox(height: 15),
                      Icon(Icons.category, size: 50),
                      ListTile(
                        title: Text('Categories', textAlign: TextAlign.center),
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
                width: 165, // Fixed width
                height: 130,
                child: Card(
                  child: Column(
                    children: [
                      SizedBox(height: 15),
                      Icon(Icons.subdirectory_arrow_right, size: 50),
                      ListTile(
                        title:
                            Text('Subcategories', textAlign: TextAlign.center),
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
            SizedBox(height: 100),
            Center(child: Text('Developed By Kumar Sundaram')),
          ],
        ),
      ),
    );
  }
}
