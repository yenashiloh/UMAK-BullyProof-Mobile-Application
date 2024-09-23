import 'dart:convert';
import 'package:bully_proof_umak/components/register_btn.dart';
import 'package:bully_proof_umak/components/user_textfield.dart';
import 'package:bully_proof_umak/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;
import 'package:bully_proof_umak/config.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final fullnameController = TextEditingController();
  final emailController = TextEditingController();
  final contactController = TextEditingController();
  final passwordController = TextEditingController();
  final cpasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureCPassword = true;
  bool _isNotValidate = false;
  bool _doPasswordsMatch = true;
  bool _isRoleNotSelected = false;
  bool _isContactInvalid = false;

  bool isFullnameEmpty = false;
  bool isEmailEmpty = false;
  bool isContactEmpty = false;
  bool isPasswordEmpty = false;
  bool isCPasswordEmpty = false;

  String? _selectedRole;

  final List<String> _roles = ["Student", "Parent", "Professor", "Staff"];

  @override
  void initState() {
    super.initState();
    // Add listener to cpasswordController
    cpasswordController.addListener(_validatePasswords);
  }

  void _validatePasswords() {
    setState(() {
      _doPasswordsMatch = passwordController.text == cpasswordController.text;
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleCPasswordVisibility() {
    setState(() {
      _obscureCPassword = !_obscureCPassword;
    });
  }

  // void _onCreateAccountPressed() {
  //   Navigator.pushReplacement(
  //     context,
  //     MaterialPageRoute(builder: (context) => const LoginPage()),
  //   );
  // }

  void _onLoginPressed() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void registerUser() async {
    setState(() {
      isFullnameEmpty = fullnameController.text.isEmpty;
      isEmailEmpty = emailController.text.isEmpty;
      isContactEmpty = contactController.text.isEmpty;
      isPasswordEmpty = passwordController.text.isEmpty;
      isCPasswordEmpty = cpasswordController.text.isEmpty;

      _isContactInvalid =
          contactController.text.length != 11 && !isContactEmpty;
      _isRoleNotSelected = _selectedRole == null;

      _isNotValidate = isFullnameEmpty ||
          isEmailEmpty ||
          isContactEmpty ||
          isPasswordEmpty ||
          isCPasswordEmpty;
    });

    if (_isNotValidate ||
        _isContactInvalid ||
        _isRoleNotSelected ||
        !_doPasswordsMatch) {
      return;
    }

    var regBody = {
      "fullname": fullnameController.text,
      "email": emailController.text,
      "contact": contactController.text,
      "password": passwordController.text,
      "type": _selectedRole,
    };

    var response = await http.post(
      Uri.parse(registration),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(regBody),
    );

    var jsonResponse = jsonDecode(response.body);

    if (jsonResponse['status']) {
      // ignore: use_build_context_synchronously
      _successMessage(context);
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: const Center(
              child: Text("Registration failed!"),
            ),
          ),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 50),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    // Dispose the controllers
    fullnameController.dispose();
    emailController.dispose();
    contactController.dispose();
    passwordController.dispose();
    cpasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 50.0),
              child: Column(
                children: [
                  const SizedBox(height: 50),
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
                  const SizedBox(height: 40),
                  const Text(
                    'Sign up',
                    style: TextStyle(
                      color: Color.fromRGBO(19, 56, 98, 1),
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 40),
                  UserTextfield(
                    controller: fullnameController,
                    hintText: 'Enter your full name',
                    labelText: 'Full Name',
                    obscureText: false,
                    errorText: isFullnameEmpty ? "Field cannot be empty" : null,
                  ),
                  const SizedBox(height: 20),
                  UserTextfield(
                    controller: emailController,
                    hintText: 'your_umakemail@umak.edu.ph',
                    labelText: 'Email',
                    obscureText: false,
                    errorText: isEmailEmpty ? "Field cannot be empty" : null,
                  ),
                  const SizedBox(height: 20),
                  UserTextfield(
                    controller: contactController,
                    hintText: '+09',
                    labelText: 'Contact No.',
                    obscureText: false,
                    errorText: isContactEmpty
                        ? "Field cannot be empty"
                        : _isContactInvalid
                            ? "Contact number must be 11 digits"
                            : null,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(11),
                    ],
                  ),
                  const SizedBox(height: 20),
                  UserTextfield(
                    controller: passwordController,
                    labelText: 'Password',
                    hintText: '•••••••••••••',
                    obscureText: _obscurePassword,
                    errorText: isPasswordEmpty ? "Field cannot be empty" : null,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: _togglePasswordVisibility,
                    ),
                  ),
                  const SizedBox(height: 20),
                  UserTextfield(
                    controller: cpasswordController,
                    labelText: 'Confirm Password',
                    hintText: '•••••••••••••',
                    obscureText: _obscureCPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureCPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: _toggleCPasswordVisibility,
                    ),
                    errorText: isCPasswordEmpty
                        ? "Field cannot be empty"
                        : !_doPasswordsMatch
                            ? "Passwords do not match"
                            : null,
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: DropdownButtonFormField<String>(
                      value: _selectedRole,
                      hint: const Text(
                        'Account type',
                        style: TextStyle(
                          color: Color.fromRGBO(21, 71, 137, 0.5),
                        ),
                      ),
                      items: _roles.map((String role) {
                        return DropdownMenuItem<String>(
                          value: role,
                          child: Text(role),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedRole = newValue; // Update selected role
                          _isRoleNotSelected = false;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Register As',
                        labelStyle: const TextStyle(
                          color: Color.fromRGBO(21, 72, 137, 1),
                          fontWeight: FontWeight.w600,
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
                        contentPadding:
                            const EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0),
                        fillColor: Colors.white,
                        filled: true,
                        errorText: _isRoleNotSelected
                            ? "Please select an account type"
                            : null,
                      ),
                      style: const TextStyle(
                        fontSize: 18,
                        color: Color.fromRGBO(21, 72, 137, 1),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  RegisterBtn(
                    onPressed: registerUser,
                  ),
                  const SizedBox(height: 20),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                            text: "Already have an account? ",
                            style: TextStyle(
                              color: Colors.black,
                            )),
                        TextSpan(
                          text: "Login",
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = _onLoginPressed,
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
                    "Registration successful!",
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
