import 'dart:convert';

import 'package:bully_proof_umak/components/login_btn.dart';
import 'package:bully_proof_umak/components/user_textfield.dart';
import 'package:bully_proof_umak/config.dart';
import 'package:bully_proof_umak/main.dart';
import 'package:bully_proof_umak/pages/registration_page.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool isEmailEmpty = false;
  bool isPasswordEmpty = false;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    initSharedPref();
  }

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _onCreateAccountPressed() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  void loginUser() async {
    setState(() {
      isEmailEmpty = emailController.text.isEmpty;
      isPasswordEmpty =
          passwordController.text.isEmpty;
    });

    if (!isEmailEmpty && !isPasswordEmpty) {
      var regBody = {
        "email": emailController.text,
        "password": passwordController.text,
      };

      var response = await http.post(
        Uri.parse(login),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(regBody),
      );

      var jsonResponse = jsonDecode(response.body);

      if (jsonResponse['status']) {
        var myToken = jsonResponse['token'];
        prefs.setString('token', myToken);
        // ignore: use_build_context_synchronously
        _successMessage(context);
        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              token: myToken,
            ),
          ),
        );
      } else {
        // ignore: use_build_context_synchronously
        _errorMessage(context, jsonResponse['message'] ?? "Login Failed");
      }
    } else {
      setState(() {
        isEmailEmpty = emailController.text.isEmpty;
        isPasswordEmpty =
            passwordController.text.isEmpty;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 50),
                // logo
                Image.asset(
                  'assets/user_logo.png',
                  width: 130,
                ),
                const SizedBox(height: 50),
                const Text(
                  "Login here",
                  style: TextStyle(
                    color: Color(0xFF1E3A8A),
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Please login to continue using our app",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 40),
                // email
                UserTextfield(
                  controller: emailController,
                  labelText: 'Email',
                  hintText: 'your_umakemail@umak.edu.ph',
                  obscureText: false,
                  errorText: isEmailEmpty ? "Field cannot be empty" : null,
                ),
                const SizedBox(height: 20),
                // password
                UserTextfield(
                  controller: passwordController,
                  labelText: 'Password',
                  hintText: '•••••••••••••',
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: _togglePasswordVisibility,
                  ),
                  errorText: isPasswordEmpty ? "Field cannot be empty" : null,
                ),
                const SizedBox(height: 20),
                LoginBtn(
                  onPressed: loginUser,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Forgot password?",
                  style: TextStyle(color: Color(0xFF7A7A7A), fontSize: 16),
                ),
                const SizedBox(height: 10),
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                          text: "Don't you have an account? ",
                          style: TextStyle(
                            color: Color(0xFF7A7A7A),
                            fontSize: 15,
                          )),
                      TextSpan(
                        text: "Create account",
                        style: const TextStyle(
                          color: Color(0xFF1E3A8A),
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = _onCreateAccountPressed,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _successMessage(BuildContext context) {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Container(
        padding: const EdgeInsets.all(8),
        height: 80,
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 81, 146, 83),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 40,
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Success",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Login successful!",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
    ));
  }

  void _errorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Container(
        padding: const EdgeInsets.all(8),
        height: 80,
        decoration: const BoxDecoration(
          color: Color(0xFFBF5A4E),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 40,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Login Failed",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    message,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
    ));
  }
}
