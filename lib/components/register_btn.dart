import 'package:flutter/material.dart';

class RegisterBtn extends StatelessWidget {
  final VoidCallback onPressed;

  const RegisterBtn({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(22, 71, 137, 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Text(
            "Create Account",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
            ),
          ),
        ),
      ),
    );
  }
}
