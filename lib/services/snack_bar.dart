import 'package:flutter/material.dart';

class SnackBarService {
  static const errorColor = Colors.red;
  static const okColor = Colors.green;

  static Future<void> showSnackBar(
      BuildContext context, String message, bool error) async {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: error ? errorColor : okColor,
      duration: const Duration(seconds: 2),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
