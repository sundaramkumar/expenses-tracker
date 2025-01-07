import 'package:expenses_tracker/pages/categories_page.dart';
import 'package:expenses_tracker/pages/subcategories_page.dart';
import 'package:expenses_tracker/pages/userprofile_page.dart';
import 'package:flutter/material.dart';
import '../databases/database_helper.dart';

class SettingsPage extends StatelessWidget {
  final DatabaseHelper _dbHelper = DatabaseHelper();

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
        child: ListView(
          children: [
            SizedBox(height: 20),
            Card(
              child: ListTile(
                shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(15.0)),
                leading: Icon(Icons.person),
                title: Text('User Profile'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserProfilePage()),
                  );
                },
              ),
            ),
            Card(
              child: ListTile(
                shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(15.0)),
                leading: Icon(Icons.category),
                title: Text('Categories'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CategoriesPage()),
                  );
                },
              ),
            ),
            Card(
              child: ListTile(
                shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(15.0)),
                leading: Icon(Icons.subdirectory_arrow_right),
                title: Text('Subcategories'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SubcategoriesPage()),
                  );
                },
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
