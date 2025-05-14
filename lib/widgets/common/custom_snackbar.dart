import 'package:flutter/material.dart';

class CustomSnackBar {
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 150,
          left: 16,
          right: 16,
        ),
      ),
    );
  }

  static void showError(BuildContext context, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lỗi: $error'),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 150,
          left: 16,
          right: 16,
        ),
      ),
    );
  }
}
