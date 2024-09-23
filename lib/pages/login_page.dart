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
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      var regBody = {
        "email": emailController.text,
        "password": passwordController.text,
      };

      var response = await http.post(Uri.parse(login),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(regBody));

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
        // ignore: avoid_print
        print('login failed');
      }
    } else {}
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
                  'assets/ob_logo.png',
                  width: 130,
                ),
                const Text(
                  'BullyProof',
                  style: TextStyle(
                    color: Color.fromRGBO(19, 56, 98, 1),
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 50),
                // email
                UserTextfield(
                  controller: emailController,
                  labelText: 'Email',
                  hintText: 'your_umakemail@umak.edu.ph',
                  obscureText: false,
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
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: _togglePasswordVisibility,
                  ),
                ),
                const SizedBox(height: 20),
                LoginBtn(
                  onPressed: loginUser,
                ),
                const SizedBox(height: 20),
                const Text("Forgot password?"),
                const SizedBox(height: 20),
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                          text: "Don't you have an account? ",
                          style: TextStyle(
                            color: Colors.black,
                          )),
                      TextSpan(
                        text: "Create account",
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
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
}
