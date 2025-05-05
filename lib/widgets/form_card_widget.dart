// lib/widgets/form_card_widget.dart
import 'package:flutter/material.dart';
import 'package:bully_proof_umak/models/form_model.dart';

class FormCardWidget extends StatelessWidget {
  final FormModel form;
  final VoidCallback onTap;

  const FormCardWidget({
    Key? key,
    required this.form,
    required this.onTap,
  }) : super(key: key);

  IconData _getIconForForm() {
    final String titleLower = form.title.toLowerCase();
    
    if (titleLower.contains('counseling')) {
      return Icons.psychology_outlined;
    } else if (titleLower.contains('follow') || titleLower.contains('up')) {
      return Icons.follow_the_signs_outlined;
    } else if (titleLower.contains('anonymous') || titleLower.contains('tip')) {
      return Icons.person_outline;
    } else {
      return Icons.description_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
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
                  _getIconForForm(),
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
                      form.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A4594),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      form.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: onTap,
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
}