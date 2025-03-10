import 'dart:convert';

import 'package:bully_proof_umak/components/login_btn.dart';
import 'package:bully_proof_umak/components/user_textfield.dart';
import 'package:bully_proof_umak/config.dart';
import 'package:bully_proof_umak/main.dart';
import 'package:bully_proof_umak/pages/registration_page.dart';
import 'package:bully_proof_umak/pages/forgot_password_page.dart'; // New import
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
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
      isPasswordEmpty = passwordController.text.isEmpty;
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

        Map<String, dynamic> decodedToken = JwtDecoder.decode(myToken);
        print('Decoded Token: $decodedToken');

        _successMessage(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              token: myToken,
            ),
          ),
        );
      } else {
        _errorMessage(context, jsonResponse['message'] ?? "Login Failed");
      }
    } else {
      setState(() {
        isEmailEmpty = emailController.text.isEmpty;
        isPasswordEmpty = passwordController.text.isEmpty;
      });
    }
  }

  void _successMessage(BuildContext context,
      [String message = 'Login successful!']) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green[600]!, Colors.green[400]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Success',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
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
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _errorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red[600]!, Colors.red[400]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Login Failed',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      maxLines: 3,
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
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                  Center(
                          child: ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                            child: const Text(
                              "BullyProof",
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
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
                    hintText: 'your_email@umak.edu.ph',
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
                    text: 'Login',
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ForgotPasswordPage()),
                      );
                    }, // Navigate to ForgotPasswordPage
                    child: const Text(
                      "Forgot password?",
                      style: TextStyle(color: Color(0xFF7A7A7A), fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 10),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                            text: "Don't have an account? ",
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
      ),
    );
  }
}
