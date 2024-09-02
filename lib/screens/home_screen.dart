import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onReportButtonPressed;
  final VoidCallback onSeekHelpButtonPressed;

  const HomeScreen({
    super.key,
    required this.onReportButtonPressed,
    required this.onSeekHelpButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(9.0),
      child: ListView(
        children: [
          _buildCard(
            context: context,
            icon: Icons.phone_iphone,
            title: 'What is cyberbullying?',
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
                      text: 'Cyberbullying involves using technology to harass, intimidate, embarrass, or target someone. This includes online threats, hostile or rude texts, tweets, posts, or messages. It also covers sharing personal information, photos, or videos intended to harm or humiliate another person.\n\n',
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
                      text: 'This law is applicable to school-related bullying, particularly between students, and includes instances occurring on social media. "Bullying" is defined as any severe or repeated actions by one or more students whether through written, verbal, or electronic communication, or physical acts or gestures, or a combination of these that result in actual harm or a reasonable fear of physical or emotional harm to another student, damage to their property, creation of a hostile school environment, violation of their rights, or significant disruption to the educational process. When these actions are carried out online, they are collectively referred to as "cyberbullying" (Sec. 2, RA 10627).',
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
          const SizedBox(height: 16),
          _buildCard(
            context: context,
            icon: Icons.report_outlined,
            title: 'Report Cyberbullying',
            description:
                'If you are experiencing cyberbullying, you can report it to us. Our team is dedicated to addressing cases of online harassment and creating a safer environment for all users.',
            buttonText: 'Report Now',
            onButtonPressed: onReportButtonPressed,
          ),
          const SizedBox(height: 16),
          _buildCard(
            context: context,
            icon: Icons.help_outline,
            title: 'Counselling Support',
            description:
                'If you or someone you know is experiencing the distress of cyberbullying, you are not alone. Our dedicated team of trained counselors is here to provide a safe, confidential space for you to share your experiences and feelings.',
            buttonText: 'Seek Help',
            onButtonPressed: onSeekHelpButtonPressed,
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onButtonPressed,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 4,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 80,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A4594), Color.fromARGB(255, 0, 23, 65)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
              ),
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
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: TextButton(
                        onPressed: onButtonPressed,
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFF1A4594),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                        child: Text(buttonText),
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
    required RichText content,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          content: content,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
