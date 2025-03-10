import 'package:flutter/material.dart';

class LoginBtn extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const LoginBtn(
      {super.key,
      required this.onPressed,
      this.text = "Login"});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
            ),
          ),
        ),
      ),
    );
  }
}
