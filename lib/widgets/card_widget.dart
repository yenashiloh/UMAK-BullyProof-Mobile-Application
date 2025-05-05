// lib/widgets/card_widget.dart
import 'package:flutter/material.dart';
import 'package:bully_proof_umak/models/card_model.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeCardWidget extends StatelessWidget {
  final CardModel card;
  final Function(String) onButtonPressed;

  const HomeCardWidget({
    super.key,
    required this.card,
    required this.onButtonPressed,
  });

  IconData _getCardIcon() {
    final String titleLower = card.title.toLowerCase();

    // Use standard icons that match your existing design
    if (titleLower.contains('report') || titleLower.contains('bully')) {
      return Icons.description_outlined;
    } else if (titleLower.contains('cyberbullying') ||
        titleLower.contains('cyber')) {
      return Icons.phone_iphone;
    } else if (titleLower.contains('counsel') || titleLower.contains('help')) {
      return Icons.psychology_outlined;
    } else {
      // Default icon for other cards
      return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
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
            // Add this icon container as the first child in the Row
            Container(
              padding: const EdgeInsets.all(16),
              child: Icon(
                _getCardIcon(), // Call the function here
                size: 40,
                color: Colors.white,
              ),
            ),

            // Then the rest of your card content (title, description, button)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.title,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      card.description,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...card.buttons.map((button) => Align(
                          alignment: Alignment.bottomRight,
                          child: ElevatedButton(
                            onPressed: () => onButtonPressed(button.action),
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
                              button.label,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
