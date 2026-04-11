import 'package:flutter/material.dart';

class SnackBarAlert {
  static void show(BuildContext context, String content) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(content),
        action: SnackBarAction(label: 'Close', onPressed: () => {}),
        duration: const Duration(seconds: 5),
      ),
    );
  }
}
