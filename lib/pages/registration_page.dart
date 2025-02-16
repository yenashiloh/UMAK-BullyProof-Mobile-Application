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
  bool _showValidations = false;
  String? _selectedRole;

  final List<String> _roles = ["Student", "Professor", "Staff"];

  // Validation states
  bool get isFullnameValid => fullnameController.text.isNotEmpty;
  bool get isEmailValid => isValidUmakEmail(emailController.text);
  bool get isContactValid => contactController.text.length == 11;
  bool get isPasswordValid =>
      _checkPasswordRequirements(passwordController.text);
  bool get doPasswordsMatch =>
      passwordController.text == cpasswordController.text;
  bool get isRoleSelected => _selectedRole != null;

  // Password requirements
  final Map<String, bool> _passwordRequirements = {
    "length": false,
    "uppercase": false,
    "lowercase": false,
    "number": false,
    "special": false,
  };

  @override
  void initState() {
    super.initState();
    // Add listeners to update validations in real-time once shown
    fullnameController
        .addListener(() => _showValidations ? setState(() {}) : null);
    emailController
        .addListener(() => _showValidations ? setState(() {}) : null);
    contactController
        .addListener(() => _showValidations ? setState(() {}) : null);
    passwordController.addListener(() {
      if (_showValidations) {
        _updatePasswordRequirements();
        setState(() {});
      }
    });
    cpasswordController
        .addListener(() => _showValidations ? setState(() {}) : null);
  }

  @override
  void dispose() {
    fullnameController.dispose();
    emailController.dispose();
    contactController.dispose();
    passwordController.dispose();
    cpasswordController.dispose();
    super.dispose();
  }

  bool isValidUmakEmail(String email) {
    return email.toLowerCase().endsWith('@umak.edu.ph');
  }

  bool _checkPasswordRequirements(String password) {
    return password.length > 8 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password) &&
        RegExp(r'[!@#\$&*~.]').hasMatch(password);
  }

  void _updatePasswordRequirements() {
    final password = passwordController.text;
    setState(() {
      _passwordRequirements["length"] = password.length > 8;
      _passwordRequirements["uppercase"] = RegExp(r'[A-Z]').hasMatch(password);
      _passwordRequirements["lowercase"] = RegExp(r'[a-z]').hasMatch(password);
      _passwordRequirements["number"] = RegExp(r'[0-9]').hasMatch(password);
      _passwordRequirements["special"] =
          RegExp(r'[!@#\$&*~.]').hasMatch(password);
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

  void _onLoginPressed() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void _showVerificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 5,
                  blurRadius: 15,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mark_email_unread_rounded,
                    color: Color(0xFF1E3A8A),
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Verify Your Email",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "We've sent a verification link to your email address. Please verify your email to complete the registration process.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Continue to Login",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildValidationText(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.error,
            color: isValid ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isValid ? Colors.green : Colors.red,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidations() {
    if (!_showValidations) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isFullnameValid)
            _buildValidationText('Full name is required', false),
          if (!isEmailValid)
            _buildValidationText(
                'Valid UMak email (@umak.edu.ph) is required', false),
          if (!isContactValid)
            _buildValidationText('Contact number must be 11 digits', false),
          if (!isRoleSelected)
            _buildValidationText('Please select an account type', false),

          // Password requirements
          if (passwordController.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Password Requirements:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 4),
            _buildValidationText(
                'At least 8 characters', _passwordRequirements["length"]!),
            _buildValidationText(
                'One uppercase letter', _passwordRequirements["uppercase"]!),
            _buildValidationText(
                'One lowercase letter', _passwordRequirements["lowercase"]!),
            _buildValidationText(
                'One number', _passwordRequirements["number"]!),
            _buildValidationText('One special character (!@#\$&*~.)',
                _passwordRequirements["special"]!),
          ],

          if (cpasswordController.text.isNotEmpty && !doPasswordsMatch)
            _buildValidationText('Passwords do not match', false),
        ],
      ),
    );
  }

  void registerUser() async {
    setState(() {
      _showValidations = true;
    });

    if (!isFullnameValid ||
        !isEmailValid ||
        !isContactValid ||
        !isPasswordValid ||
        !doPasswordsMatch ||
        !isRoleSelected) {
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: Color(0xFF1E3A8A),
                ),
                SizedBox(height: 16),
                Text(
                  "Creating your account...",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    try {
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

      // ignore: use_build_context_synchronously
      Navigator.of(context).pop(); // Close loading dialog

      var jsonResponse = jsonDecode(response.body);

      if (jsonResponse['status']) {
        // ignore: use_build_context_synchronously
        _successMessage(context);
        // ignore: use_build_context_synchronously
        _showVerificationDialog(); // Show verification dialog before redirecting
      } else {
        // ignore: use_build_context_synchronously
        _errorMessage(
            context, jsonResponse['message'] ?? "Registration Failed");
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop(); // Close loading dialog
      // ignore: use_build_context_synchronously
      _errorMessage(context, "Registration failed. Please try again later.");
    }
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
                  ),
                  const SizedBox(height: 20),
                  UserTextfield(
                    controller: emailController,
                    hintText: 'your_umakemail@umak.edu.ph',
                    labelText: 'Email',
                    obscureText: false,
                  ),
                  const SizedBox(height: 20),
                  UserTextfield(
                    controller: contactController,
                    hintText: '+09',
                    labelText: 'Contact No.',
                    obscureText: false,
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
                          _selectedRole = newValue;
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
                      ),
                      style: const TextStyle(
                        fontSize: 18,
                        color: Color.fromRGBO(21, 72, 137, 1),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildValidations(),
                  const SizedBox(height: 30),
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
                          ),
                        ),
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
