import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bully_proof_umak/config.dart';
import 'package:bully_proof_umak/screens/report-incidents/report_screen.dart';

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
  List<Map<String, dynamic>> _forms = [];

  @override
  void initState() {
    super.initState();
    _fetchForms();
  }

  Future<void> _fetchForms() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Replace this with actual API endpoint when available
      final formsUrl = '${url}forms';
      
      final response = await http.get(
        Uri.parse(formsUrl),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        // Uncomment and adjust when API is available
        // final List<dynamic> forms = json.decode(response.body);
        // setState(() {
        //   _forms = List<Map<String, dynamic>>.from(forms);
        //   _isLoading = false;
        // });
        
        // For now, use mock data
        setState(() {
          _forms = [
            {
              'id': '1',
              'title': 'Counseling Request Form',
              'description': 'Request counseling services for cyberbullying incidents.',
              'type': 'counseling',
              'url': 'https://example.com/counseling-form',
            },
            {
              'id': '2',
              'title': 'Incident Follow-up Form',
              'description': 'Provide additional information for an existing report.',
              'type': 'follow-up',
              'url': 'https://example.com/follow-up-form',
            },
            {
              'id': '3',
              'title': 'Anonymous Tip Form',
              'description': 'Submit information about potential cyberbullying incidents anonymously.',
              'type': 'anonymous',
              'url': 'https://example.com/anonymous-form',
            },
          ];
          _isLoading = false;
        });
      } else {
        // Handle error response
        setState(() {
          _isLoading = false;
        });
        _showErrorMessage('Failed to load forms. Please try again later.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorMessage('Error: $e');
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

  void _openForm(String url) {
    // For now, just show a message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening form: $url'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    
    // In a real implementation, you could:
    // 1. Open an in-app webview
    // 2. Launch a URL
    // 3. Navigate to another screen with a form
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
      // Floating action button removed as requested
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
            child: _forms.isEmpty
                ? _buildEmptyView()
                : _buildFormsList(),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

  Widget _buildFormCard(Map<String, dynamic> form) {
    final IconData iconData = _getIconForFormType(form['type']);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _openForm(form['url']),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A4594).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  iconData,
                  size: 32,
                  color: const Color(0xFF1A4594),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      form['title'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A4594),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      form['description'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: () => _openForm(form['url']),
                        icon: const Icon(Icons.open_in_new, size: 16),
                        label: const Text('Open Form'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFB731),
                          foregroundColor: const Color(0xFF1A4594),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForFormType(String type) {
    switch (type) {
      case 'counseling':
        return Icons.psychology_outlined;
      case 'follow-up':
        return Icons.follow_the_signs_outlined;
      case 'anonymous':
        return Icons.person_outline;
      default:
        return Icons.description_outlined;
    }
  }
} 