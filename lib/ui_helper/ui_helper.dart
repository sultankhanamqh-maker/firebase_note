import 'package:flutter/material.dart';

InputDecoration myDecor({
  required String hint,
  required String label,
  bool isPassword = false,
  VoidCallback? onTap,
  bool passWordVisible = false,
}) {
  return InputDecoration(
    hintText: hint,
    labelText: label,
    suffixIcon: isPassword
        ? IconButton(
            onPressed: onTap,
            icon: passWordVisible
                ? Icon(Icons.visibility)
                : Icon(Icons.visibility_off),
          )
        : null,
    alignLabelWithHint: true,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
  );
}
