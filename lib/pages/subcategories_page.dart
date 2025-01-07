import 'package:expenses_tracker/databases/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import '../databases/subcategory.dart';

class SubcategoriesPage extends StatelessWidget {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subcategories'),
      ),
      body: FutureBuilder<List<Subcategory>>(
        future: _dbHelper.getSubcategoriesList(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var subcategories = snapshot.data;
          return ListView.builder(
            itemCount: subcategories!.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(subcategories[index].name),
              );
            },
          );
        },
      ),
    );
  }
}
