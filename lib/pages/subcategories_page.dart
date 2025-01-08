import 'package:expenses_tracker/databases/database_helper.dart';
import 'package:expenses_tracker/pages/dialog_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../databases/subcategory.dart';
import "../utils/string_extension.dart";

class SubcategoriesPage extends StatefulWidget {
  @override
  State<SubcategoriesPage> createState() => _SubcategoriesPageState();
}

class _SubcategoriesPageState extends State<SubcategoriesPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  var _subCategoryNamecontroller = TextEditingController();

  List<Subcategory> _subCategories = [];
  var _selectedSubCategory;

  @override
  void initState() {
    super.initState();
    _fetchSubCategories();
  }

  Future<void> _fetchSubCategories() async {
    final subCategories = await _dbHelper.getSubcategoriesList();
    setState(() {
      _subCategories = subCategories;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subcategories'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewSubCategory,
        backgroundColor: Colors.redAccent,
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      body: Container(
        color: Colors.grey[200],
        child: Container(
          child: _buildSubCategoryRows(context, _subCategories),
        ),
      ),
    );
  }

  Widget _buildSubCategoryRows(BuildContext context, subCategories) {
    return ListView.builder(
        itemCount: subCategories.length,
        itemBuilder: (context, index) {
          return Padding(
              padding: const EdgeInsets.only(left: 25.0, right: 25, top: 10),
              child: Container(
                height: 35,
                decoration: BoxDecoration(
                    // color: Colors.black,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.grey.shade300)),
                // child: _buildCategoryCard(subCategories[index]),
                child: Slidable(
                  endActionPane:
                      ActionPane(motion: const StretchMotion(), children: [
                    CustomSlidableAction(
                      onPressed: (context) {
                        _editSubCategory(context, subCategories[index]);
                        setState(() {
                          _selectedSubCategory = subCategories[index];
                        });
                      },
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(5),
                        bottomLeft: Radius.circular(5),
                      ),
                      child: Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 15,
                      ),
                    ),
                    CustomSlidableAction(
                      onPressed: (context) {
                        _confirmDelete(context, subCategories[index]);
                      },
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(5),
                        bottomRight: Radius.circular(5),
                      ),
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 15,
                      ),
                    )
                  ]),
                  child: _buildSubCategoryCard(subCategories[index]),
                ),
              ));
        });
  }

  Widget _buildSubCategoryCard(subCategory) {
    print(subCategory.subCategoryName);
    return Row(
      children: [
        SizedBox(width: 10),
        Icon(Icons.category, size: 15),
        SizedBox(width: 10),
        Text(subCategory.subCategoryName)
      ],
    );
  }

  void _addNewSubCategory() {
    _subCategoryNamecontroller.text = '';
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          dialogTitle: 'Add New SubCategory',
          dialogType: 'SUBCATEGORY',
          taskInputController: _subCategoryNamecontroller,
          onSave: saveNewSubCategory,
          onCancel: () => Navigator.of(context).pop(),
        );
      },
    ); // Add your logic to add a new category here
  }

  void saveNewSubCategory() {
    _dbHelper.addSubCategory(
        1,
        _subCategoryNamecontroller.text
            .replaceAll(RegExp('[^A-Za-z0-9]'), '')
            .capitalize());
    _fetchSubCategories();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Subcategory added successfully!'),
        backgroundColor: Colors.grey[800],
      ),
    );
    Navigator.of(context).pop();
  }

  void _editSubCategory(BuildContext context, subCategory) {
    _subCategoryNamecontroller.text = subCategory.subCategoryName;
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          dialogTitle: 'Edit Sub Category',
          taskInputController: _subCategoryNamecontroller, //.text.toString(),
          // fieldValue: category.categoryName,
          onSave: editSubCategory,
          onCancel: () => Navigator.of(context).pop(),
        );
      },
    ); // Add your logic to add a new category here
  }

  void editSubCategory() async {
    await _dbHelper.updateSubCategory(
        _selectedSubCategory.subCategoryId,
        _subCategoryNamecontroller.text
            .replaceAll(RegExp('[^A-Za-z0-9]'), '')
            .capitalize());
    _fetchSubCategories();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Subcategory updated successfully!'),
        backgroundColor: Colors.grey[800],
      ),
    );
    Navigator.of(context).pop();
  }

  void _confirmDelete(BuildContext context, subCategory) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete? '),
          content: Text(
              'Are you sure you want to delete this sub category?. This will delete all related transactions and cannot be undone'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                _deleteSubCategory(context, subCategory.subCategoryId);
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteSubCategory(BuildContext context, int subCategoryId) async {
    await _dbHelper.deleteSubCategory(subCategoryId);
    _fetchSubCategories();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('SubCategory deleted successfully!'),
        backgroundColor: Colors.grey,
      ),
    );
  }
}
