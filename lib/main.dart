import 'package:bully_proof_umak/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home/home_screen.dart';
import 'screens/report-incidents/report_screen.dart';
import 'screens/seek-help/seek_help_screen.dart';
import 'screens/notifications/notification_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  runApp(MyApp(token: token));
}

class MyApp extends StatelessWidget {
  final String? token;

  const MyApp({@required this.token, super.key});

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

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    email = jwtDecodedToken['email'] ?? "Unknown";
  }

  void _onPageSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              height: 60,
            ),
            Text(
              email,
              style: const TextStyle(
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
          ),
          const ReportScreen(),
          const SeekHelpScreen(),
          const NotificationScreen(),
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
            icon: const Icon(Icons.calendar_today),
            activeIcon: const Icon(Icons.calendar_today),
            label: 'Get Help',
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
}
