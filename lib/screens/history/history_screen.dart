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
        final dateA = _getReportDate(a['reportDate']) ??
            DateTime(1900); // Default old date for null values
        final dateB = _getReportDate(b['reportDate']) ?? DateTime(1900);
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
        return _buildReportCard(context, report);
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

  Widget _buildReportCard(
      BuildContext context, Map<String, dynamic> reportData) {
    final complaineeName = reportData['perpetratorName'] ?? 'N/A';
    final reportDate =
        _getReportDate(reportData['reportDate']) ?? DateTime(1900);
    final status = reportData['status'] ?? 'Unknown';
    final incidentDetails =
        reportData['incidentDetails'] ?? 'No details provided';

    String formattedDate = 'Unknown Date';
    try {
      if (reportDate != DateTime(1900)) {
        final phTimeZoneDate = reportDate.toUtc().add(const Duration(hours: 8));
        formattedDate = DateFormat.yMMMd().add_jm().format(phTimeZoneDate);
      }
    } catch (e) {
      print('Error parsing date: $e');
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReportDetailScreen(report: reportData),
          ),
        );
      },
      child: Container(
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
                        value: complaineeName,
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

  // Helper method to handle both nested and flat reportDate structures
  DateTime? _getReportDate(dynamic reportDate) {
    if (reportDate is Map && reportDate['reportDate'] != null) {
      return DateTime.tryParse(reportDate['reportDate'].toString());
    } else if (reportDate is String) {
      return DateTime.tryParse(reportDate);
    }
    return null;
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
      case 'under review':
        return const Color(0xFFFFB732).withOpacity(0.9);
      case 'resolved':
        return const Color(0xFF1E8549).withOpacity(0.9);
      default:
        return const Color(0xFF17A2B8);
      // return Colors.grey[400]!;
    }
  }

  Color _getTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'for review':
      case 'under investigation':
      case 'under review':
      case 'resolved':
        return const Color.fromARGB(255, 255, 255, 255);
      default:
        return const Color.fromARGB(255, 255, 255, 255);
      // return Colors.grey[700]!;
    }
  }
}

// New Screen for Report Details
class ReportDetailScreen extends StatelessWidget {
  final Map<String, dynamic> report;

  const ReportDetailScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    // Extract and format data from the report
    final complaineeName = report['perpetratorName'] ?? 'N/A';
    final reportDate = _getReportDate(report['reportDate']) ?? DateTime(1900);
    final status = report['status'] ?? 'Unknown';
    final incidentDetails = report['incidentDetails'] ?? 'N/A';
    final submitAs = report['submitAs'] ?? 'N/A';
    final victimRelationship = report['victimRelationship'] ?? 'N/A';
    final hasReportedBefore = report['hasReportedBefore'] ?? 'N/A';
    final departmentCollege = report['departmentCollege'] ?? 'N/A';
    final reportedTo = report['reportedTo'] ?? 'N/A';
    final platformUsed =
        report['platformUsed'] != null && report['platformUsed'].isNotEmpty
            ? (report['platformUsed'] as List).join(', ')
            : 'N/A';
    final otherPlatformUsed = report['otherPlatformUsed'] ?? 'N/A';
    final cyberbullyingTypes = report['cyberbullyingTypes'] != null &&
            report['cyberbullyingTypes'].isNotEmpty
        ? (report['cyberbullyingTypes'] as List).join(', ')
        : 'N/A';
    final complaineeRole = report['perpetratorRole'] ?? 'N/A';
    final complaineeGradeYearLevel =
        report['perpetratorGradeYearLevel'] ?? 'N/A';
    final supportTypes =
        report['supportTypes'] != null && report['supportTypes'].isNotEmpty
            ? (report['supportTypes'] as List).join(', ')
            : 'N/A';
    final otherSupportTypes = report['otherSupportTypes'] ?? 'N/A';
    final witnessChoice = report['witnessChoice'] ?? 'N/A';
    final contactChoice = report['contactChoice'] ?? 'N/A';
    final actionsTaken = report['actionsTaken'] ?? 'N/A';
    final describeActions = report['describeActions'] ?? 'N/A';

    // Format the report date to Philippine time (UTC +8)
    String formattedDate = 'Unknown Date';
    try {
      if (reportDate != DateTime(1900)) {
        final phTimeZoneDate = reportDate.toUtc().add(const Duration(hours: 8));
        formattedDate = DateFormat.yMMMd().add_jm().format(phTimeZoneDate);
      }
    } catch (e) {
      print('Error parsing date: $e');
    }

    // Determine the label based on complaineeRole
    final gradeYearLabel = (complaineeRole.toLowerCase() == 'employee')
        ? 'Position'
        : 'Grade/Year Level';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A4594),
        elevation: 0,
        title: const Text(
          'Report Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card with Gradient and Status
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A4594), Color(0xFF2A6BD5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        'Date Reported: $formattedDate',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    if (status != 'Unknown')
                      Container(
                        constraints: const BoxConstraints(maxWidth: 120),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _getStatusGradient(status),
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
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
                            Flexible(
                              child: Text(
                                _getDisplayStatus(status),
                                style: TextStyle(
                                  color: _getTextColor(status),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Sections in Modern Cards
              if (incidentDetails != 'N/A')
                _buildModernSectionCard(
                  title: 'Incident Details',
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    constraints:
                        const BoxConstraints(minWidth: double.infinity),
                    child: Text(
                      incidentDetails,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[800],
                        height: 1.5,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              if ([
                submitAs,
                victimRelationship,
                hasReportedBefore,
                departmentCollege,
                reportedTo
              ].any((value) => value != 'N/A'))
                _buildModernSectionCard(
                  title: 'Submission Details',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (submitAs != 'N/A')
                        _buildDetailTile(
                            Icons.person_outline, 'Submitted As', submitAs),
                      if (victimRelationship != 'N/A')
                        _buildDetailTile(Icons.people_outline,
                            'Complainant Relationship', victimRelationship),
                      if (hasReportedBefore != 'N/A')
                        _buildDetailTile(Icons.history, 'Reported Before',
                            hasReportedBefore),
                      if (departmentCollege != 'N/A')
                        _buildDetailTile(Icons.school,
                            'Office/College/Department', departmentCollege),
                      if (reportedTo != 'N/A')
                        _buildDetailTile(
                            Icons.person_add, 'Reported To', reportedTo),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              if ([platformUsed, otherPlatformUsed, cyberbullyingTypes]
                  .any((value) => value != 'N/A'))
                _buildModernSectionCard(
                  title: 'Incident Information',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (platformUsed != 'N/A')
                        _buildDetailTile(
                            Icons.web, 'Platform Used', platformUsed),
                      if (otherPlatformUsed != 'N/A')
                        _buildDetailTile(Icons.web, 'Other Platform Used',
                            otherPlatformUsed),
                      if (cyberbullyingTypes != 'N/A')
                        _buildDetailTile(Icons.warning, 'Cyberbullying Types',
                            cyberbullyingTypes),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              if ([complaineeName, complaineeRole, complaineeGradeYearLevel]
                  .any((value) => value != 'N/A'))
                _buildModernSectionCard(
                  title: 'Complainee Information',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (complaineeName != 'N/A')
                        _buildDetailTile(Icons.person_outline,
                            'Complainee Name', complaineeName),
                      if (complaineeRole != 'N/A')
                        _buildDetailTile(Icons.work_outline, 'Complainee Role',
                            complaineeRole),
                      if (complaineeGradeYearLevel != 'N/A')
                        _buildDetailTile(Icons.school, gradeYearLabel,
                            complaineeGradeYearLevel), // Dynamic label here
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              if ([
                supportTypes,
                otherSupportTypes,
                witnessChoice,
                contactChoice,
                actionsTaken,
                describeActions
              ].any((value) => value != 'N/A'))
                _buildModernSectionCard(
                  title: 'Support and Actions',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (supportTypes != 'N/A')
                        _buildDetailTile(
                            Icons.support_agent, 'Support Types', supportTypes),
                      if (otherSupportTypes != 'N/A')
                        _buildDetailTile(Icons.support_agent,
                            'Other Support Types', otherSupportTypes),
                      if (witnessChoice != 'N/A')
                        _buildDetailTile(
                            Icons.person_add, 'Witness Choice', witnessChoice),
                      if (contactChoice != 'N/A')
                        _buildDetailTile(
                            Icons.phone, 'Contact Choice', contactChoice),
                      if (actionsTaken != 'N/A')
                        _buildDetailTile(Icons.check_circle_outline,
                            'Actions Taken', actionsTaken),
                      if (describeActions != 'N/A')
                        _buildDetailTile(Icons.description, 'Describe Actions',
                            describeActions),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernSectionCard(
      {required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildDetailTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.blue[400], // Modern color for icons
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    fontFamily: 'Poppins',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DateTime? _getReportDate(dynamic reportDate) {
    if (reportDate is Map && reportDate['reportDate'] != null) {
      return DateTime.tryParse(reportDate['reportDate'].toString());
    } else if (reportDate is String) {
      return DateTime.tryParse(reportDate);
    }
    return null;
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

  List<Color> _getStatusGradient(String status) {
    switch (status.toLowerCase()) {
      case 'for review':
        return [const Color(0xFF1A4594), const Color(0xFF2A6BD5)];
      case 'under investigation':
      case 'under review':
        return [const Color(0xFFFFB732), const Color(0xFFFFD54F)];
      case 'resolved':
        return [const Color(0xFF1E8549), const Color(0xFF2ECC71)];
      default:
        return [const Color(0xFF17A2B8), const Color.fromARGB(255, 18, 122, 138)];
      // return [Colors.grey[400]!, Colors.grey[600]!];
    }
  }

  Color _getTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'for review':
      case 'under investigation':
      case 'under review':
      case 'resolved':
        return Colors.white;
      default:
        return Colors.white;
      // return Colors.grey[700]!;
    }
  }
}
