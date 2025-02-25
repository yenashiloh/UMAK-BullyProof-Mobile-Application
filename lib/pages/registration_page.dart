import 'dart:async';
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
  final idNumberController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureCPassword = true;
  bool _showValidations = false;
  bool _isLoading = false; // New loading state
  String? _selectedRole;
  String? _selectedProgramOrPosition;

  final List<String> _roles = ["Student", "Employee"];

  // Validation states
  bool get isFullnameValid => fullnameController.text.isNotEmpty;
  bool get isEmailValid => isValidUmakEmail(emailController.text);
  bool get isContactValid => contactController.text.length == 11;
  bool get isPasswordValid =>
      _checkPasswordRequirements(passwordController.text);
  bool get doPasswordsMatch =>
      passwordController.text == cpasswordController.text;
  bool get isIdnumberValid => idNumberController.text.isNotEmpty;
  bool get isRoleSelected => _selectedRole != null;
  bool get isProgramOrPositionSelected => _selectedProgramOrPosition != null;

  // Password requirements
  final Map<String, bool> _passwordRequirements = {
    "length": false,
    "uppercase": false,
    "lowercase": false,
    "number": false,
    "special": false,
  };

  final List<String> _studentYearLevels = [
    'Grade 11',
    'Grade 12',
    '1st Year College',
    '2nd Year College',
    '3rd Year College',
    '4th Year College',
    '5th Year College'
  ];

  final List<String> _employeePositions = [
    'Administrative Assistant',
    'Clerical Worker',
    'Clerk',
    'Clerk Staff',
    'Executive Assistant',
    'Faculty',
    'Office Manager',
    'Program Coordinator'
  ];

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
    idNumberController
        .addListener(() => _showValidations ? setState(() {}) : null);
  }

  @override
  void dispose() {
    fullnameController.dispose();
    emailController.dispose();
    contactController.dispose();
    passwordController.dispose();
    cpasswordController.dispose();
    idNumberController.dispose();
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
    bool canResend = false;
    int remainingSeconds = 60;
    Timer? countdownTimer;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            countdownTimer ??=
                Timer.periodic(const Duration(seconds: 1), (timer) {
              setState(() {
                if (remainingSeconds > 0) {
                  remainingSeconds--;
                } else {
                  canResend = true;
                  timer.cancel();
                }
              });
            });

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
                    TweenAnimationBuilder(
                      duration: const Duration(seconds: 1),
                      tween: Tween<double>(begin: 0, end: 1),
                      builder: (context, double value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
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
                        );
                      },
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
                    Text(
                      "We've sent a verification link to ${emailController.text}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Please verify your email to complete the registration process.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black45,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: canResend
                          ? () async {
                              setState(() {
                                canResend = false;
                                remainingSeconds = 60;
                              });

                              countdownTimer?.cancel();
                              countdownTimer = Timer.periodic(
                                const Duration(seconds: 1),
                                (timer) {
                                  setState(() {
                                    if (remainingSeconds > 0) {
                                      remainingSeconds--;
                                    } else {
                                      canResend = true;
                                      timer.cancel();
                                    }
                                  });
                                },
                              );

                              try {
                                var response = await http.post(
                                  Uri.parse(resendVerification),
                                  headers: {"Content-Type": "application/json"},
                                  body: jsonEncode(
                                      {"email": emailController.text}),
                                );

                                var jsonResponse = jsonDecode(response.body);
                                if (jsonResponse['status']) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Verification email resent successfully'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(jsonResponse['message'] ??
                                          'Failed to resend verification email'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } catch (e) {
                                print('Error resending verification: $e');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Failed to resend verification email'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          : null,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        backgroundColor: canResend
                            ? const Color(0xFF1E3A8A).withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.refresh_rounded,
                            size: 18,
                            color: canResend
                                ? const Color(0xFF1E3A8A)
                                : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            canResend
                                ? "Resend Verification"
                                : "Resend in ${remainingSeconds}s",
                            style: TextStyle(
                              color: canResend
                                  ? const Color(0xFF1E3A8A)
                                  : Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        countdownTimer?.cancel();
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
                          horizontal: 32,
                          vertical: 16,
                        ),
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
    if (!_showValidations || _isLoading) {
      return const SizedBox.shrink(); // Hide during loading
    }

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
          if (!isIdnumberValid)
            _buildValidationText('UMak ID No. is required', false),
          if (!isRoleSelected)
            _buildValidationText('Please select an account type', false),
          if (!isProgramOrPositionSelected)
            _buildValidationText('Please select a program or position', false),
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
        !isIdnumberValid ||
        !isRoleSelected ||
        !isProgramOrPositionSelected) {
      return;
    }

    setState(() {
      _isLoading = true;
      _showValidations = false;
    });

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
        "idnumber": idNumberController.text,
        "type": _selectedRole,
        "position": _selectedProgramOrPosition,
      };

      var response = await http.post(
        Uri.parse(registration),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(regBody),
      );

      Navigator.of(context).pop();

      var jsonResponse = jsonDecode(response.body);

      if (jsonResponse['status']) {
        setState(() {
          _showValidations = false; // Reset validations on success
        });
        _successMessage(context);
        _showVerificationDialog();
      } else {
        _errorMessage(
            context, jsonResponse['message'] ?? "Registration Failed");
      }
    } catch (e) {
      Navigator.of(context).pop();
      _errorMessage(context, "Registration failed. Please try again later.");
    } finally {
      setState(() {
        _isLoading = false;
        // Do not reset _showValidations here on error to keep showing validations if needed
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey[100]!,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 800),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Image.asset(
                              'assets/user_logo.png',
                              width: 90,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: const Text(
                          "Create Account",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        "Please fill the details and create account",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    UserTextfield(
                      controller: fullnameController,
                      labelText: 'Full Name *',
                      hintText: 'Enter your full name',
                      obscureText: false,
                      errorText: _showValidations && !isFullnameValid
                          ? "Field cannot be empty"
                          : null,
                    ),
                    const SizedBox(height: 12),
                    UserTextfield(
                      controller: emailController,
                      labelText: 'Email *',
                      hintText: 'your_umakemail@umak.edu.ph',
                      obscureText: false,
                      errorText: _showValidations && !isEmailValid
                          ? "Valid UMak email required"
                          : null,
                    ),
                    const SizedBox(height: 12),
                    UserTextfield(
                      controller: contactController,
                      labelText: 'Contact No. *',
                      hintText: '+09',
                      obscureText: false,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(11),
                      ],
                      errorText: _showValidations && !isContactValid
                          ? "Must be 11 digits"
                          : null,
                    ),
                    const SizedBox(height: 12),
                    UserTextfield(
                      controller: passwordController,
                      labelText: 'Password *',
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
                      errorText: _showValidations && !isPasswordValid
                          ? "Check requirements"
                          : null,
                    ),
                    const SizedBox(height: 12),
                    UserTextfield(
                      controller: cpasswordController,
                      labelText: 'Confirm Password *',
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
                      errorText: _showValidations && !doPasswordsMatch
                          ? "Passwords do not match"
                          : null,
                    ),
                    const SizedBox(height: 12),
                    UserTextfield(
                      controller: idNumberController,
                      labelText: 'ID No. *',
                      hintText: 'Enter your UMak ID number',
                      obscureText: false,
                      errorText: _showValidations && !isIdnumberValid
                          ? "Field cannot be empty"
                          : null,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: DropdownButtonFormField<String>(
                          value: _selectedRole,
                          hint: Text(
                            'Register As',
                            style: TextStyle(color: Colors.grey[500]),
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
                              _selectedProgramOrPosition = null;
                            });
                          },
                          decoration: InputDecoration(
                            label: RichText(
                              text: TextSpan(
                                children: [
                                  const TextSpan(
                                    text: 'Register As',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Color.fromRGBO(21, 72, 137, 0.7),
                                    ),
                                  ),
                                  WidgetSpan(
                                    child: Tooltip(
                                      message: 'Required field',
                                      child: Transform.translate(
                                        offset: const Offset(0, -2),
                                        child: const Text(
                                          ' *',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            shadows: [
                                              Shadow(
                                                color: Colors.redAccent,
                                                offset: Offset(0, 0),
                                                blurRadius: 2,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.auto,
                            labelStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Color.fromRGBO(21, 72, 137, 0.7),
                            ),
                            errorText: _showValidations && !isRoleSelected
                                ? "Selection required"
                                : null,
                            border: OutlineInputBorder(
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
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color.fromRGBO(21, 72, 137, 1),
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.fromLTRB(
                                30.0, 15.0, 30.0, 15.0),
                          ),
                          style: const TextStyle(color: Colors.black87),
                          isExpanded: true,
                          dropdownColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_selectedRole != null)
                      SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: DropdownButtonFormField<String>(
                            value: _selectedProgramOrPosition,
                            hint: Text(
                              _selectedRole == 'Employee'
                                  ? 'Position'
                                  : 'Program/Year Level',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                            items: (_selectedRole == 'Employee'
                                    ? _employeePositions
                                    : _studentYearLevels)
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedProgramOrPosition = newValue;
                              });
                            },
                            decoration: InputDecoration(
                              label: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: _selectedRole == 'Employee'
                                          ? 'Position'
                                          : 'Program/Year Level',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Color.fromRGBO(21, 72, 137, 0.7),
                                      ),
                                    ),
                                    WidgetSpan(
                                      child: Tooltip(
                                        message: 'Required field',
                                        child: Transform.translate(
                                          offset: const Offset(0, -2),
                                          child: const Text(
                                            ' *',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              shadows: [
                                                Shadow(
                                                  color: Colors.redAccent,
                                                  offset: Offset(0, 0),
                                                  blurRadius: 2,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              floatingLabelBehavior: FloatingLabelBehavior.auto,
                              labelStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Color.fromRGBO(21, 72, 137, 0.7),
                              ),
                              errorText: _showValidations &&
                                      !isProgramOrPositionSelected
                                  ? "Selection required"
                                  : null,
                              border: OutlineInputBorder(
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
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color.fromRGBO(21, 72, 137, 1),
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.fromLTRB(
                                  30.0, 15.0, 30.0, 15.0),
                            ),
                            style: const TextStyle(color: Colors.black87),
                            isExpanded: true,
                            dropdownColor: Colors.white,
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    AnimatedOpacity(
                      opacity: _showValidations && !_isLoading ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: _buildValidations(),
                    ),
                    const SizedBox(height: 16),
                    RegisterBtn(
                      onPressed: _isLoading
                          ? () {}
                          : registerUser, // Use no-op function when loading
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Already have an account? ",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            TextSpan(
                              text: "Login",
                              style: const TextStyle(
                                color: Color(0xFF1E3A8A),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = _onLoginPressed,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
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
