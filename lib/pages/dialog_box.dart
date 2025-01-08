import "package:flutter/material.dart";
import "../utils/task_button.dart";
import '../databases/database_helper.dart';

class DialogBox extends StatelessWidget {
  final taskInputController;
  VoidCallback onSave;
  VoidCallback onCancel;
  final dialogTitle;
  String dialogType;

  DialogBox({
    super.key,
    required this.taskInputController,
    required this.onSave,
    required this.onCancel,
    this.dialogTitle,
    this.dialogType = 'CATEGORY',
  });

  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _categories = [];
  int? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    // _loadCategories();
    return AlertDialog(
      backgroundColor: Colors.grey[300],
      content: Container(
        height: dialogType == 'CATEGORY' ? 155 : 220,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              dialogTitle ?? "Add New Category",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              textAlign: TextAlign.center,
            ),
            _buildBody(context),
            const SizedBox(height: 10),
            _buildButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (dialogType == 'CATEGORY') {
      return TextField(
        autofocus: true,
        maxLength: 25,
        controller: taskInputController,
        decoration: const InputDecoration(
            border: UnderlineInputBorder(),
            hintText: "Enter Category name",
            hintStyle: TextStyle(color: Colors.grey)),
      );
    } else {
      return FutureBuilder(
        future: _loadCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              children: [
                DropdownButtonFormField<int>(
                  value: _selectedCategory,
                  decoration: InputDecoration(labelText: 'Category'),
                  items: _categories.map((category) {
                    return DropdownMenuItem<int>(
                      value: category['categoryId'],
                      child: Text(category['categoryName']),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    _selectedCategory = newValue!;
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a category.';
                    }
                    return null;
                  },
                ),
                TextField(
                  autofocus: true,
                  maxLength: 25,
                  controller: taskInputController,
                  decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      hintText: "Enter SubCategory name",
                      hintStyle: TextStyle(color: Colors.grey)),
                ),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      );
    }
  }

  Widget _buildButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        //save button
        ElevatedButton(
          onPressed: onCancel,
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade300,
              foregroundColor: Colors.white,
              // padding:
              //     EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              textStyle: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.normal,
                  color: Colors.white)),
          child: Text('Cancel'),
        ),
        //space
        const SizedBox(width: 10),
        //cancel button
        ElevatedButton(
          onPressed: onSave,
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade500,
              foregroundColor: Colors.white,
              // padding:
              //     EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              textStyle: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.normal,
                  color: Colors.white)),
          child: Text('Save'),
        )
      ],
    );
  }

  Future<void> _loadCategories() async {
    List<Map<String, dynamic>> categories = await _dbHelper.getCategories();
    _categories = categories;
  }
}
