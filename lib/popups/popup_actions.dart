import 'package:flutter/material.dart';

class PopupActions {
  static void showPopup(BuildContext context, String title, Function(String) onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Action"),
          content: Text("Are you sure you want to $title?"),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm(title);
              },
            ),
          ],
        );
      },
    );
  }

  static void handleAction(String title) {
    switch (title) {
      case 'Stop Taking Orders':
        // Call API to stop taking orders
        break;
      case 'Stop Taking Cash Orders':
        // Call API to stop taking cash orders
        break;
      case 'Refresh':
        // Call API to refresh data
        break;
      default:
        // Handle default or unknown case
        break;
    }
  }
}
