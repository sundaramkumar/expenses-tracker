import "package:flutter/material.dart";

class TaskButton extends StatelessWidget {
  final String text;

  VoidCallback onPressed;
  TaskButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      color: Theme.of(context).primaryColor,
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
