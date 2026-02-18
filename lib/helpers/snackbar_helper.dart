import 'package:flutter/material.dart';

/// Shows a SnackBar on the current scaffold.
/// Centralised so SnackBar styling is consistent across the whole app.
void showSnackBar({
  required BuildContext context,
  required String message,
  required Color color,
  Duration duration = const Duration(seconds: 3),
}) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
}
