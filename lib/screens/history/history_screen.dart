import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Enhanced shimmer gradient with more subtle colors and smoother transition
const _shimmerGradient = LinearGradient(
  colors: [
    Color(0xFFEBEBF4),
    Color(0xFFF5F5F5),
    Color(0xFFEBEBF4),
  ],
  stops: [
    0.0,
    0.5,
    1.0,
  ],
  begin: Alignment(-2.0, -0.3),
  end: Alignment(2.0, 0.3),
  tileMode: TileMode.clamp,
);

class ShimmerLoading extends StatefulWidget {
  const ShimmerLoading({
    super.key,
    required this.child,
    this.shimmerDuration = const Duration(milliseconds: 1500),
  });

  final Widget child;
  final Duration shimmerDuration;

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController.unbounded(vsync: this)
      ..repeat(min: -0.5, max: 1.5, period: widget.shimmerDuration);
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      child: widget.child,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return _shimmerGradient.createShader(
              Rect.fromLTWH(
                _shimmerController.value * bounds.width - bounds.width * 0.5,
                0,
                bounds.width * 2,
                bounds.height,
              ),
            );
          },
          child: child,
        );
      },
    );
  }
}

class HistoryScreen extends StatelessWidget {
  final List<Map<String, dynamic>> reports;
  final String userId;
  final String token;
  final bool isLoading;

  const HistoryScreen({
    super.key,
    required this.reports,
    required this.userId,
    required this.token,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildHeader(),
      body: isLoading
          ? _buildSkeletonLoading()
          : (reports.isEmpty ? _buildNoHistoryView() : _buildReportsList()),
    );
  }

  Widget _buildSkeletonLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: 3,
      itemBuilder: (context, index) {
        return _buildSkeletonCard(
          contentLines: index % 2 == 0 ? 2 : 1,
          hasLongTitle: index == 1,
        );
      },
    );
  }

  Widget _buildSkeletonCard({int contentLines = 2, bool hasLongTitle = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: ShimmerLoading(
        child: Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title with varying width
                          Container(
                            width: hasLongTitle ? double.infinity : 200,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Date
                          Container(
                            width: 120,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status badge
                    Container(
                      width: 90,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Content rows with varying widths
                ...List.generate(
                  contentLines,
                  (index) => Padding(
                    padding: EdgeInsets.only(
                        bottom: index < contentLines - 1 ? 12.0 : 0),
                    child: _buildSkeletonInfoRow(
                      labelWidth: 80 + (index * 20),
                      valueWidth: 150 + (index * 30),
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

  Widget _buildSkeletonInfoRow({
    required double labelWidth,
    required double valueWidth,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: labelWidth,
          height: 14,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: valueWidth,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ],
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
    // Create a copy of reports list to sort
    final sortedReports = List<Map<String, dynamic>>.from(reports);

    // Sort the reports by date in descending order
    sortedReports.sort((a, b) {
      try {
        final dateA = a['reportDate'] != null
            ? DateTime.parse(a['reportDate'])
            : DateTime(1900); // Default old date for null values
        final dateB = b['reportDate'] != null
            ? DateTime.parse(b['reportDate'])
            : DateTime(1900);
        return dateB
            .compareTo(dateA); // Compare in reverse order for descending
      } catch (e) {
        print('Error sorting dates: $e');
        return 0; // Keep original order if there's an error
      }
    });

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: sortedReports.length,
      itemBuilder: (context, index) {
        final report = sortedReports[index];
        return _buildReportCard(report);
      },
    );
  }

  PreferredSizeWidget _buildHeader() {
    return PreferredSize(
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
    final incidentDetails =
        reportData['incidentDetails'] ?? 'No details provided';

    String formattedDate = 'Unknown Date';
    try {
      if (reportDate != 'Unknown Date') {
        final parsedDate = DateTime.parse(reportDate);
        final phTimeZoneDate = parsedDate.toUtc().add(const Duration(hours: 8));
        formattedDate = DateFormat.yMMMd().add_jm().format(phTimeZoneDate);
      }
    } catch (e) {
      print('Error parsing date: $e');
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Bar
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withOpacity(0.15),
                  border: Border(
                    bottom: BorderSide(
                      color: _getStatusColor(status).withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formattedDate,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _getTextColor(status),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _getDisplayStatus(status),
                            style: TextStyle(
                              color: _getTextColor(status),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      incidentDetails,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    _buildModernInfoRow(
                      icon: Icons.person_outline,
                      label: 'Complainee',
                      value: perpetratorName,
                    ),
                    const SizedBox(height: 12),
                    _buildModernInfoRow(
                      icon: Icons.person_outline,
                      label: 'Complainant',
                      value: victimName,
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

  Widget _buildModernInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey[400],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getDisplayStatus(String status) {
    switch (status.toLowerCase()) {
      case 'for review':
        return 'For Review';
      case 'resolved':
        return 'Resolved';
      case 'under investigation':
        return 'Under Investigation';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'for review':
        return const Color(0xFF1A4594).withOpacity(0.9);
      case 'under investigation':
        return const Color(0xFFFFB732).withOpacity(0.9);
      case 'resolved':
        return const Color(0xFF1E8549).withOpacity(0.9);
      default:
        return Colors.grey[400]!;
    }
  }

  Color _getTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'for review':
        return const Color.fromARGB(255, 255, 255, 255);
      case 'under investigation':
        return const Color.fromARGB(255, 255, 255, 255);
      case 'resolved':
        return const Color.fromARGB(255, 255, 255, 255);
      default:
        return Colors.grey[700]!;
    }
  }
}
