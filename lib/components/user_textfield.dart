import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UserTextfield extends StatelessWidget {
  final TextEditingController controller;
  final String hintText, labelText;
  final bool obscureText;
  final Widget? suffixIcon; // Optional parameter for suffix icon
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final String? errorText; // Parameter for error text

  const UserTextfield({
    super.key,
    required this.controller,
    required this.hintText,
    required this.labelText,
    required this.obscureText,
    this.suffixIcon, // Initialize the suffix icon
    this.inputFormatters, // Initialize input formatters
    this.validator, // Initialize validator
    this.errorText, // Initialize error text
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            obscureText: obscureText,
            inputFormatters: inputFormatters, // Apply input formatters
            decoration: InputDecoration(
              labelText: labelText,
              floatingLabelBehavior: FloatingLabelBehavior.auto, // Label floats on focus
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Color.fromRGBO(21, 72, 137, 0.7), // Active label opacity
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(
                  color: Color.fromRGBO(21, 72, 137, 1),
                ),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color.fromRGBO(21, 72, 137, 1),
                ),
              ),
              fillColor: Colors.white,
              filled: true,
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.grey.withOpacity(0.5),
              ),
              contentPadding: const EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0),
              suffixIcon: suffixIcon, // Add the suffix icon here
            ),
          ),
          // Error text display
          if (errorText != null) ...[
            const SizedBox(height: 5),
            Text(
              errorText!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}