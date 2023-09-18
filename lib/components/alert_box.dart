import 'package:flutter/material.dart';

class CustomDialog {
  final String title;
  final String content;

  CustomDialog({
    required this.title,
    required this.content,
  });

  void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Okay'),
            ),
          ],
        );
      },
    );
  }
}
