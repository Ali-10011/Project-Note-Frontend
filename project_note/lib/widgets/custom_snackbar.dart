import 'package:flutter/material.dart';

  void fireSnackBar(String message, Color snackbarColor, Color textColor, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: snackbarColor,
      content: Text(
        message,
        style: TextStyle(color: textColor),
      ),
    ));
  }
