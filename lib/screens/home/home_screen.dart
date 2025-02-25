import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Add this package for modern typography

class HomeScreen extends StatelessWidget {
  final VoidCallback onReportButtonPressed;
  final VoidCallback onSeekHelpButtonPressed;
  final String fullName;

  const HomeScreen({
    super.key,
    required this.onReportButtonPressed,
    required this.onSeekHelpButtonPressed,
    required this.fullName,
  });

  String _getFirstName(String fullName) {
    List<String> nameParts = fullName.trim().split(' ');
    return nameParts.isNotEmpty ? nameParts[0] : fullName;
  }

  @override
  Widget build(BuildContext context) {
    String firstName = _getFirstName(fullName);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: ListView(
        children: [
          // Welcome Text with modern typography
          Text.rich(
            TextSpan(
              text: "Welcome, ",
              style: GoogleFonts.poppins(
                fontSize: 24,
                color: Colors.black87,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: firstName,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A4594),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Modern Cards
          _buildModernCard(
            context: context,
            icon: Icons.phone_iphone,
            title: 'What is Cyberbullying?',
            description:
                'Cyberbullying involves using technology to harass, intimidate, embarrass, or target someone. This includes online threats, hostile or rude texts, tweets, posts, or messages.',
            buttonText: 'Learn More',
            onButtonPressed: () => _showDialog(
              context: context,
              content: RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'What is Cyberbullying?\n\n',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text:
                          'Cyberbullying involves using technology to harass, intimidate, embarrass, or target someone. This includes online threats, hostile or rude texts, tweets, posts, or messages. It also covers sharing personal information, photos, or videos intended to harm or humiliate another person.\n\n',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    TextSpan(
                      text: 'What is Anti-Bullying Act of 2013 (RA 10627)?\n\n',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text:
                          'This law is applicable to school-related bullying, particularly between students, and includes instances occurring on social media. "Bullying" is defined as any severe or repeated actions by one or more students whether through written, verbal, or electronic communication, or physical acts or gestures, or a combination of these that result in actual harm or a reasonable fear of physical or emotional harm to another student, damage to their property, creation of a hostile school environment, violation of their rights, or significant disruption to the educational process. When these actions are carried out online, they are collectively referred to as "cyberbullying" (Sec. 2, RA 10627).',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildModernCard(
            context: context,
            icon: Icons.description_outlined,
            title: 'Report Cyberbullying',
            description:
                'If you are experiencing cyberbullying, you can report it to us. Our team is dedicated to addressing cases of online harassment and creating a safer environment for all users.',
            buttonText: 'Report Now',
            onButtonPressed: onReportButtonPressed,
          ),
          // const SizedBox(height: 20),
          // _buildModernCard(
          //   context: context,
          //   icon: Icons.psychology_outlined,
          //   title: 'Counselling Support',
          //   description:
          //       'If you or someone you know is experiencing the distress of cyberbullying, you are not alone. Our dedicated team of trained counselors is here to provide a safe, confidential space for you to share your experiences and feelings.',
          //   buttonText: 'Seek Help',
          //   onButtonPressed: onSeekHelpButtonPressed,
          // ),
        ],
      ),
    );
  }

  Widget _buildModernCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onButtonPressed,
  }) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1A4594).withOpacity(0.9),
              const Color.fromARGB(255, 0, 23, 65),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Icon(
                icon,
                size: 40,
                color: Colors.white,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                        onPressed: onButtonPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFB731),
                          foregroundColor: const Color(0xFF1A4594),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: Text(
                          buttonText,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDialog({
    required BuildContext context,
    required Widget content,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.all(24.0),
          backgroundColor: Colors.white,
          content: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: content,
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Close',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF1A4594),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
