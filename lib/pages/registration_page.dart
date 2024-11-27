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
  bool _isPasswordFocused = false;

  String? _selectedRole;

  final List<String> _roles = ["Student", "Parent", "Professor", "Staff"];
  List<String> _passwordErrors = [];

  final FocusNode _passwordFocusNode = FocusNode();
  bool _isPasswordValid = false;

  @override
  void initState() {
    super.initState();
    passwordController.addListener(_validatePassword);
    cpasswordController.addListener(_validatePasswords);

    _passwordFocusNode.addListener(() {
      setState(() {
        _isPasswordFocused = _passwordFocusNode.hasFocus;
        if (!_isPasswordFocused) {
          _isPasswordValid = false;
        }
      });
    });
  }

  void _validatePasswords() {
    setState(() {
      _doPasswordsMatch = passwordController.text == cpasswordController.text;
    });
    _validatePassword();
  }

  void _validatePassword() {
    setState(() {
      final password = passwordController.text;
      List<String> errors = [];

      if (password.length <= 8) {
        errors.add("Password must be over 8 characters");
      }
      if (!RegExp(r'[A-Z]').hasMatch(password)) {
        errors.add("Password must contain 1 uppercase letter");
      }
      if (!RegExp(r'[a-z]').hasMatch(password)) {
        errors.add("Password must contain 1 lowercase letter");
      }
      if (!RegExp(r'[0-9]').hasMatch(password)) {
        errors.add("Password must contain 1 number");
      }
      if (!RegExp(r'[!@#\$&*~]').hasMatch(password)) {
        errors.add("Password must contain 1 special character");
      }

      // Update the state with the error messages
      _passwordErrors = errors;
      _isPasswordValid = errors.isEmpty;
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
        !_doPasswordsMatch ||
        !_isPasswordValid) {
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
      _errorMessage(context, jsonResponse['message'] ?? "Registration Failed");
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
    _passwordFocusNode.dispose();
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
                    'assets/user_logo.png',
                    width: 130,
                  ),
                  const SizedBox(height: 50),
                  const Text(
                    "Create Account",
                    style: TextStyle(
                      color: Color(0xFF1E3A8A),
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Please fill the details and create account",
                    style: TextStyle(
                      fontSize: 18,
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
                    focusNode: _passwordFocusNode,
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
                  const SizedBox(height: 5),
                  if (_isPasswordFocused && !_isPasswordValid) ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _passwordErrors.map((error) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 120.0),
                          child: Text(
                            error,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 12),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
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
                  const SizedBox(height: 50),
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
                            color: Color(0xFF1E3A8A),
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

  void _successMessage(BuildContext context) {
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
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Success',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Registration successful!',
                      style: TextStyle(
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
                      'Registration Failed',
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
}
