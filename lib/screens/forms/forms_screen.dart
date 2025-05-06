// screens/forms/forms_screen.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bully_proof_umak/config.dart';
import 'package:bully_proof_umak/screens/report-incidents/report_screen.dart';
import 'package:bully_proof_umak/models/form_model.dart';
import 'package:bully_proof_umak/services/form_service.dart';
import 'package:bully_proof_umak/screens/forms/form_view_screen.dart';

class FormsScreen extends StatefulWidget {
  final String? token;
  final String? userId;
  final VoidCallback? onNavigateToHistory;

  const FormsScreen({
    super.key,
    this.token,
    this.userId,
    this.onNavigateToHistory,
  });

  @override
  State<FormsScreen> createState() => _FormsScreenState();
}

class _FormsScreenState extends State<FormsScreen> {
  bool _isLoading = false;
  List<FormModel> _forms = [];

  @override
  void initState() {
    super.initState();
    _fetchForms();
  }

  Future<void> _fetchForms() async {
    if (widget.token == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final forms = await FormService.fetchForms(widget.token!);

      setState(() {
        _forms = forms;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorMessage('Failed to load forms. Please try again later.');
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openForm(FormModel form) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormViewScreen(
          form: form,
          token: widget.token ?? '',
          userId: widget.userId ?? '',
        ),
      ),
    );
  }

  void _navigateToReportScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportScreen(
          onNavigateToHistory: widget.onNavigateToHistory,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56.0),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A4594),
          ),
          child: const SafeArea(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Forms & Reports',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1A4594),
              ),
            )
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFeatureCard(),
          const SizedBox(height: 24),
          const Text(
            'Available Forms',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A4594),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _forms.isEmpty ? _buildEmptyView() : _buildFormsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A4594), Color(0xFF3B82F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.report_problem_outlined,
                  color: Colors.white,
                  size: 28,
                ),
                SizedBox(width: 10),
                Text(
                  'Report Cyberbullying',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Help create a safer environment by reporting cyberbullying incidents. Your report will be kept confidential and appropriate action will be taken.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _navigateToReportScreen,
              icon: const Icon(Icons.add),
              label: const Text('Create New Report'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB731),
                foregroundColor: const Color(0xFF1A4594),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No forms available',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 18,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for available forms',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormsList() {
    return ListView.builder(
      itemCount: _forms.length,
      itemBuilder: (context, index) {
        final form = _forms[index];
        return _buildFormCard(form);
      },
    );
  }

  Widget _buildFormCard(FormModel form) {
    final IconData iconData = _getIconForFormType(form.title);

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _openForm(form),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon container with better styling
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4FA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  iconData,
                  size: 24,
                  color: const Color(0xFF1A4594),
                ),
              ),
              const SizedBox(width: 16),
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      form.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A4594),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      form.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Button with consistent styling
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ElevatedButton(
                  onPressed: () => _openForm(form),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB731),
                    foregroundColor: const Color(0xFF1A4594),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Open Form',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
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

  IconData _getIconForFormType(String type) {
    final String typeLower = type.toLowerCase();

    if (typeLower.contains('counseling')) {
      return Icons.psychology_outlined;
    } else if (typeLower.contains('follow-up') ||
        typeLower.contains('follow up')) {
      return Icons.follow_the_signs_outlined;
    } else if (typeLower.contains('anonymous') || typeLower.contains('tip')) {
      return Icons.person_outline;
    } else {
      return Icons.description_outlined;
    }
  }
}
