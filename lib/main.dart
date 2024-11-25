import 'package:bully_proof_umak/config.dart';
import 'package:bully_proof_umak/screens/history/history_screen.dart';
import 'package:bully_proof_umak/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home/home_screen.dart';
import 'screens/report-incidents/report_screen.dart';
import 'screens/notifications/notification_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  runApp(MyApp(token: token));
}

class MyApp extends StatelessWidget {
  final String? token;

  const MyApp({required this.token, super.key});

  @override
  Widget build(BuildContext context) {
    bool isTokenValid = token != null && !JwtDecoder.isExpired(token!);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BullyProof',
      home: isTokenValid ? HomePage(token: token!) : const SplashScreen(),
    );
  }
}

class HomePage extends StatefulWidget {
  final String token;
  const HomePage({required this.token, super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late String email;
  late String userId;
  late String token;
  int _currentIndex = 0;
  List<Map<String, dynamic>> _userReports = [];
  List<Map<String, dynamic>> _userNotif = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    email = jwtDecodedToken['email'] ?? "Unknown";
    userId = jwtDecodedToken['_id'] ?? "";
    token = widget.token;
  }

  Future<void> _fetchUserReportData(String userId) async {
    setState(() {
      _isLoading = true;
    });

    const reportUrl = '${url}reports';
    try {
      final reportResponse = await http.get(Uri.parse(reportUrl), headers: {
        'Authorization': 'Bearer ${widget.token}',
      });

      if (reportResponse.statusCode == 200) {
        final List<dynamic> reports = json.decode(reportResponse.body);

        final userReports =
            reports.where((report) => report['reportedBy'] == userId).toList();

        setState(() {
          _userReports = List<Map<String, dynamic>>.from(userReports);
          _isLoading = false;
        });

        if (_userReports.isEmpty) {
          print("No reports found for user $userId");
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        throw Exception('Failed to fetch reports');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching report data: $e');
    }
  }

  Future<void> _fetchUserNotificationData(String userId) async {
    setState(() {
      _isLoading = true;
    });

    const notifUrl = '${url}notifications';
    try {
      final notifResponse = await http.get(Uri.parse(notifUrl), headers: {
        'Authorization': 'Bearer ${widget.token}',
      });

      if (notifResponse.statusCode == 200) {
        final List<dynamic> notifs = json.decode(notifResponse.body);

        final userNotif =
            notifs.where((notif) => notif['userId'] == userId).toList();

        setState(() {
          _userNotif = List<Map<String, dynamic>>.from(userNotif);
          _isLoading = false;
        });

        if (_userNotif.isEmpty) {
          print("No notifications found for user $userId");
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        throw Exception('Failed to fetch notifications');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching notification data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/user_logo.png',
              height: 45,
            ),
            const Text(
              "BullyProof",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Color(0xFF1A4594),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFF7F2FA),
        elevation: 0,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(
            onReportButtonPressed: () {
              _onPageSelected(1);
            },
            onSeekHelpButtonPressed: () {
              _onPageSelected(2);
            },
            email: email,
          ),
          // In HomePage's build method, update the ReportScreen creation:
          ReportScreen(
            onNavigateToHistory: () {
              setState(() {
                _currentIndex = 2; // Index for History screen
              });
              _fetchUserReportData(userId); // Fetch the latest data
            },
          ),
          HistoryScreen(
            reports: _userReports,
            token: widget.token,
            userId: userId,
            isLoading: _isLoading,
          ),
          NotificationScreen(
            notifications: _userNotif,
            token: widget.token,
            userId: userId,
            isLoading: _isLoading,
          ),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onPageSelected,
        backgroundColor: const Color(0xFF1A4594),
        selectedItemColor: const Color(0xFFFFB731),
        unselectedItemColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: [
          _buildBottomNavigationBarItem(
            index: 0,
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: 'Home',
          ),
          _buildBottomNavigationBarItem(
            index: 1,
            icon: const Icon(Icons.description_outlined),
            activeIcon: const Icon(Icons.description_outlined),
            label: 'Report',
          ),
          _buildBottomNavigationBarItem(
            index: 2,
            icon: const Icon(Icons.archive_outlined),
            activeIcon: const Icon(Icons.archive),
            label: 'History',
          ),
          _buildBottomNavigationBarItem(
            index: 3,
            icon: const Icon(Icons.notifications_outlined),
            activeIcon: const Icon(Icons.notifications),
            label: 'Notification',
          ),
          _buildBottomNavigationBarItem(
            index: 4,
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildBottomNavigationBarItem({
    required int index,
    required Icon icon,
    required Icon activeIcon,
    required String label,
  }) {
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.only(bottom: 5),
        decoration: BoxDecoration(
          border: _currentIndex == index
              ? const Border(
                  bottom: BorderSide(
                      color: Color.fromARGB(255, 160, 190, 247), width: 2),
                )
              : null,
        ),
        child: icon,
      ),
      activeIcon: Container(
        padding: const EdgeInsets.only(bottom: 4),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFFFB731), width: 2),
          ),
        ),
        child: activeIcon,
      ),
      label: label,
    );
  }

  void _onPageSelected(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 2:
        _fetchUserReportData(userId);
        break;
      case 3:
        _fetchUserNotificationData(userId);
        break;
      default:
        // Optionally handle other cases or do nothing
        break;
    }
  }
}
