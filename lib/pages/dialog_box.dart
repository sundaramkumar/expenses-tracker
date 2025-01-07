import "package:flutter/material.dart";
import "../utils/task_button.dart";

class DialogBox extends StatelessWidget {
  final taskInputController;
  VoidCallback onSave;
  VoidCallback onCancel;
  final dialogTitle;

  DialogBox({
    super.key,
    required this.taskInputController,
    required this.onSave,
    required this.onCancel,
    this.dialogTitle,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[300],
      content: Container(
        height: 135,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              dialogTitle ?? "Add New Category",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              textAlign: TextAlign.center,
            ),
            TextField(
              autofocus: true,
              controller: taskInputController,
              decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  hintText: "Enter Category name",
                  hintStyle: TextStyle(color: Colors.grey)),
            ),
            const SizedBox(height: 10),
            Row(
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
                // TaskButton(
                //   text: "Cancel",
                //   onPressed: onCancel,
                // ),

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
                // TaskButton(
                //   text: "Save",
                //   onPressed: onSave,
                // )
              ],
            )
          ],
        ),
      ),
    );
  }
}
