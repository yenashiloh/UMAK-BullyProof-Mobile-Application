import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UserTextfield extends StatelessWidget {
  final TextEditingController controller;
  final String hintText, labelText;
  final bool obscureText;
  final Widget? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final String? errorText;
  final FocusNode? focusNode;

  const UserTextfield(
      {super.key,
      required this.controller,
      required this.hintText,
      required this.labelText,
      required this.obscureText,
      this.suffixIcon,
      this.inputFormatters,
      this.validator,
      this.errorText,
      this.focusNode});

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
            inputFormatters: inputFormatters,
            focusNode: focusNode,
            decoration: InputDecoration(
              labelText: labelText,
              floatingLabelBehavior: FloatingLabelBehavior.auto,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Color.fromRGBO(21, 72, 137, 0.7),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color.fromRGBO(21, 72, 137, 1),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color.fromRGBO(21, 72, 137, 1),
                ),
              ),
              fillColor: Colors.white,
              filled: true,
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.grey.withOpacity(0.5),
              ),
              contentPadding: const EdgeInsets.fromLTRB(30.0, 22.0, 30.0, 22.0),
              suffixIcon: suffixIcon,
            ),
          ),
          if (errorText != null) ...[
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.only(
                  left: 30.0),
              child: Text(
                errorText!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
