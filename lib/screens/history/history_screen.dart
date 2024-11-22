import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatelessWidget {
  final List<Map<String, dynamic>> reports;
  final String userId;
  final String token;

  const HistoryScreen({
    super.key,
    required this.reports,
    required this.userId,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildHeader(),
      body: reports.isEmpty 
        ? _buildNoHistoryView() 
        : _buildReportsList(),
    );
  }

  Widget _buildNoHistoryView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No history of report',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 18,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your report history will appear here',
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

  Widget _buildReportsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        return _buildReportCard(report);
      },
    );
  }

  PreferredSizeWidget _buildHeader() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(56.0),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A4594), // Dark blue color
        ),
        child: const SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'History',
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
    );
  }

  Widget _buildReportCard(Map<String, dynamic> reportData) {
    final victimName = reportData['victimName'] ?? 'N/A';
    final perpetratorName = reportData['perpetratorName'] ?? 'N/A';
    final reportDate = reportData['reportDate'] ?? 'Unknown Date';
    final status = reportData['status'] ?? 'Unknown';
    final incidentDetails = reportData['incidentDetails'] ?? 'No details provided';

    String formattedDate = 'Unknown Date';
    try {
      if (reportDate != 'Unknown Date') {
        final parsedDate = DateTime.parse(reportDate);
        formattedDate = DateFormat.yMMMd().add_jm().format(parsedDate);
      }
    } catch (e) {
      print('Error parsing date: $e');
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          incidentDetails,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _getDisplayStatus(status),
                      style: TextStyle(
                        color: _getTextColor(status),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoRow('Respondent Name:', perpetratorName),
              const SizedBox(height: 8),
              _buildInfoRow('Complainant Name:', victimName),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
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
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }

  String _getDisplayStatus(String status) {
    switch (status.toLowerCase()) {
      case 'to review':
        return 'To Review';
      case 'approved':
        return 'Resolved';
      case 'under investigation':
        return 'Under Investigation';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'for review':
        return const Color(0xFFE6EBFF); // Light primary color
      case 'under investigation':
        return const Color(0xFFFFF4E5); // Light warning color
      case 'approved': // For "Resolved"
        return const Color(0xFFE6F4EA); // Light success color
      case 'rejected':
        return Colors.red[100]!;
      default:
        return Colors.grey[100]!;
    }
  }

  Color _getTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'for review':
        return const Color(0xFF1A4594); // Primary color
      case 'under investigation':
        return const Color(0xFFB76E00); // Warning color
      case 'approved': // For "Resolved"
        return const Color(0xFF1E8549); // Success color
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}