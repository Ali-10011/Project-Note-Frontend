import 'package:flutter/material.dart';

void fireSnackBar(String message, Color snackbarColor, Color textColor,
    BuildContext context) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: snackbarColor,
      content: Text(
        message,
        style: TextStyle(color: textColor),
      ),
      duration: const Duration(milliseconds: 1500),
  
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
    ),
  );
}
