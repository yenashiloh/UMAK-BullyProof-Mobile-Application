import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bully_proof_umak/splash_screen.dart';
import 'package:bully_proof_umak/components/profile_avatar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bully_proof_umak/config.dart';
import 'package:flutter/services.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final bool isLoading;
  final String token;
  final String userId;

  const ProfileScreen({
    super.key,
    this.userData,
    required this.isLoading,
    required this.token,
    required this.userId,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String userName;
  late String userEmail;
  late String userContact;
  late String userStudentNumber;
  late String userType;
  late String userPosition;

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  @override
  void didUpdateWidget(ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.userData != oldWidget.userData) {
      _initializeUserData();
    }
  }

  void _initializeUserData() {
    setState(() {
      userName = widget.userData?['fullname'] ?? "John Doe";
      userEmail = widget.userData?['email'] ?? "john.doe@umak.edu.ph";
      userContact = widget.userData?['contact'] ?? "+63 912 345 6789";
      userStudentNumber = widget.userData?['idnumber'] ?? "A123456789";
      userType = widget.userData?['type'] ?? "N/A";
      userPosition = widget.userData?['position'] ?? "N/A";
    });
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const SplashScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  Future<void> _updateProfile(
      String name, String email, String contact, String studentNumber) async {
    final updateUrl = '${url}users/${widget.userId}';
    try {
      final response = await http.put(
        Uri.parse(updateUrl),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'fullname': name,
          'email': email,
          'contact': contact,
          'idnumber': studentNumber,
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            userName = name;
            userEmail = email;
            userContact = contact;
            userStudentNumber = studentNumber;
          });
          _showSuccessDialog();
        }
      } else {
        throw Exception('Failed to update profile: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    }
  }

  void _showSuccessDialog() {
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.shade100,
                  ),
                  child: Icon(
                    Icons.check,
                    size: 40,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Profile Updated',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Changes saved successfully!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 32,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade700,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      'Got it',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  void _showEditProfile() {
    if (mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.8,
          maxChildSize: 0.8,
          builder: (context, scrollController) => EditProfileModal(
            initialName: userName,
            initialEmail: userEmail,
            initialContact: userContact,
            initialStudentNumber: userStudentNumber,
            initialUserType: userType,
            initialPosition: userPosition,
            onSave: (name, email, contact, studentNumber) async {
              await _updateProfile(name, email, contact, studentNumber);
            },
          ),
        ),
      );
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData icon, VoidCallback? onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.grey[600], size: 22),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'My profile',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: _showEditProfile,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Stack(
                            children: [
                              ProfileAvatar(
                                imageUrl: null,
                                name: userName,
                                size: 60,
                              ),
                              Positioned(
                                right: -2,
                                bottom: -2,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  // child: Icon(
                                  //   Icons.camera_alt,
                                  //   color: Colors.grey[600],
                                  //   size: 14,
                                  // ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'ID number: $userStudentNumber',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      _buildInfoRow('Email', userEmail),
                      _buildInfoRow('Contact', userContact),
                      _buildInfoRow(
                        userType.toLowerCase() == 'student'
                            ? 'Year Level'
                            : 'Position',
                        userPosition,
                      ),
                      _buildInfoRow('Type', userType),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                _buildMenuItem('Password settings', Icons.lock_outline, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PasswordSettingsScreen(
                            token: widget.token, userId: widget.userId)),
                  );
                }),
                _buildMenuItem('About us', Icons.info_outline, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AboutUsScreen()),
                  );
                }),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      'Log out',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.red.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Password Settings Screen
class PasswordSettingsScreen extends StatefulWidget {
  final String token;
  final String userId;

  const PasswordSettingsScreen({
    super.key,
    required this.token,
    required this.userId,
  });

  @override
  State<PasswordSettingsScreen> createState() => _PasswordSettingsScreenState();
}

class _PasswordSettingsScreenState extends State<PasswordSettingsScreen> {
  late TextEditingController currentPasswordController;
  late TextEditingController newPasswordController;
  late TextEditingController confirmPasswordController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    currentPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    // Validation
    if (currentPasswordController.text.isEmpty ||
        newPasswordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      _showModernSnackBar('All fields are required', Colors.red);
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      _showModernSnackBar('New passwords do not match', Colors.orange);
      return;
    }

    // Regex for password: at least 8 characters, 1 uppercase, 1 lowercase, 1 number, 1 special character
    final passwordRegex = RegExp(
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*])[A-Za-z\d!@#$%^&*]{8,}$');
    if (!passwordRegex.hasMatch(newPasswordController.text)) {
      _showModernSnackBar(
          'Password must be at least 8 characters with one uppercase, one lowercase, one number, and one special character (!@#\$%^&*)',
          Colors.orange);
      return;
    }

    setState(() => isLoading = true);

    final updateUrl = '${url}users/${widget.userId}/change-password';
    try {
      final response = await http.put(
        Uri.parse(updateUrl),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'currentPassword': currentPasswordController.text,
          'newPassword': newPasswordController.text,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        if (mounted) {
          _showModernSnackBar('Password updated successfully', Colors.green);
          Navigator.pop(context);
        }
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Unknown error';
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (mounted) {
        _showModernSnackBar('Error: $e', Colors.red);
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // Modern SnackBar function
  void _showModernSnackBar(String message, Color backgroundColor) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(
                Icons.info_outline,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
          backgroundColor: backgroundColor.withOpacity(0.9),
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
          animation: CurvedAnimation(
            parent: const AlwaysStoppedAnimation(1),
            curve: Curves.easeInOut,
          ),
        ),
      );
    }
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool obscureText = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        title: const Text(
          'Password Settings',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                        'Current Password', currentPasswordController),
                    _buildTextField('New Password', newPasswordController),
                    _buildTextField(
                        'Confirm New Password', confirmPasswordController),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _updatePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// About Us Screen
class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        title: const Text(
          'About Us',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About Bully-Proof UMaK',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Bully-Proof UMaK is an initiative by the University of Makati to combat cyberbullying and create a safe, inclusive online and on-campus environment for all students. Our mission is to prevent digital harassment, provide support to those affected, and promote a culture of respect, empathy, and responsible online behavior.\n\n'
                  'Contact us at: bullyproofumak@gmail.com\n'
                  'Phone: +63 2 123 4567\n'
                  'Version: 1.0.0',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// EditProfileModal
class EditProfileModal extends StatefulWidget {
  final String initialName;
  final String initialEmail;
  final String initialContact;
  final String initialStudentNumber;
  final String initialUserType;
  final String initialPosition;
  final Function(String, String, String, String) onSave;

  const EditProfileModal({
    super.key,
    required this.initialName,
    required this.initialEmail,
    required this.initialContact,
    required this.initialStudentNumber,
    required this.initialUserType,
    required this.initialPosition,
    required this.onSave,
  });

  @override
  State<EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<EditProfileModal> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController contactController;
  late TextEditingController studentNumberController;
  late TextEditingController positionController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.initialName);
    emailController = TextEditingController(text: widget.initialEmail);
    contactController = TextEditingController(text: widget.initialContact);
    studentNumberController =
        TextEditingController(text: widget.initialStudentNumber);
    positionController = TextEditingController(text: widget.initialPosition);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    contactController.dispose();
    studentNumberController.dispose();
    positionController.dispose();
    super.dispose();
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
    bool enabled = true,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: enabled ? Colors.white : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              enabled: enabled,
              maxLength: maxLength,
              inputFormatters: inputFormatters,
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: enabled ? Colors.white : Colors.grey[200],
                counterText: maxLength != null ? "" : null,
              ),
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _saveChanges() {
    // Validation for Full Name
    if (nameController.text.trim().isEmpty) {
      _showErrorSnackBar('Full Name cannot be empty');
      return;
    }

    // Validation for Contact Number
    if (contactController.text.trim().isEmpty) {
      _showErrorSnackBar('Contact Number cannot be empty');
      return;
    }
    if (contactController.text.length < 11) {
      _showErrorSnackBar('Contact Number must be at least 11 digits');
      return;
    }
    if (!contactController.text.startsWith('09')) {
      _showErrorSnackBar('Please enter a valid contact number');
      return;
    }

    // If all validations pass, proceed with saving
    widget.onSave(
      nameController.text,
      emailController.text,
      contactController.text,
      studentNumberController.text,
    );
    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: Colors.red.withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final positionLabel = widget.initialUserType.toLowerCase() == 'student'
        ? 'Year Level'
        : 'Position';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade900, Colors.blue.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      if (mounted) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                  const Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildTextField('Full Name', nameController),
                    _buildTextField('Email', emailController,
                        keyboardType: TextInputType.emailAddress,
                        enabled: false),
                    _buildTextField(
                      'Contact Number',
                      contactController,
                      keyboardType: TextInputType.phone,
                      maxLength: 11,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    _buildTextField('ID Number', studentNumberController,
                        enabled: false),
                    _buildTextField(positionLabel, positionController,
                        enabled: false),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 0),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
