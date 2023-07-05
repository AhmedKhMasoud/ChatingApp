import 'package:flutter/material.dart';

// calling when need to display message to user
void displaySnackBarMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
      ),
    ),
  );

}
