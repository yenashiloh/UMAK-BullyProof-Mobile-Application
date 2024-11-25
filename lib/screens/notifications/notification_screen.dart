import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatelessWidget {
  final List<Map<String, dynamic>> notifications;
  final String userId;
  final String token;
  final bool isLoading;

  const NotificationScreen({
    super.key,
    required this.notifications,
    required this.userId,
    required this.token,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildHeader(),
            if (isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF1E4BB7),
                  ),
                ),
              )
            else if (notifications.isEmpty)
              _buildEmptyView()
            else
              _buildNotificationsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_rounded,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No notifications',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You have no notifications at the moment',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                    fontFamily: 'Poppins',
                  ),
                ),
                if (!isLoading && notifications.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E4BB7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${_getUnreadCount()} new',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList() {
    // Create a copy of notifications list to sort
    final sortedNotifications = List<Map<String, dynamic>>.from(notifications);

    // Sort notifications by timestamp in descending order
    sortedNotifications.sort((a, b) {
      try {
        final dateA = a['timestamp'] != null
            ? DateTime.parse(a['timestamp'])
            : DateTime(1900);
        final dateB = b['timestamp'] != null
            ? DateTime.parse(b['timestamp'])
            : DateTime(1900);
        return dateB.compareTo(dateA);
      } catch (e) {
        print('Error sorting dates: $e');
        return 0;
      }
    });

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final notification = sortedNotifications[index];
            return _buildNotificationCard(notification);
          },
          childCount: sortedNotifications.length,
        ),
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notificationData) {
    final message = notificationData['message'] ?? 'No message';
    final timestamp =
        notificationData['createdAt'] ?? DateTime.now().toString();
    final isRead = notificationData['status'] != 'unread';

    String formattedDate = 'Just now';
    try {
      // Parse the `createdAt` field to a DateTime object
      if (timestamp != 'Just now') {
        final parsedDate = DateTime.parse(timestamp).toLocal();
        formattedDate = _getTimeAgo(parsedDate);
      }
    } catch (e) {
      print('Error parsing date: $e');
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            // Handle notification tap
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNotificationIcon(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Status Update',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                          ),
                          if (!isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF1E4BB7),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            formattedDate,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
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

  Widget _buildNotificationIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF1E4BB7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.notifications_rounded,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  int _getUnreadCount() {
    return notifications
        .where((notification) => notification['status'] == 'unread')
        .length;
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat.yMMMd().format(dateTime);
    }
  }
}
