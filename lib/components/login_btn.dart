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
          color: const Color.fromRGBO(22, 71, 137, 1),
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
