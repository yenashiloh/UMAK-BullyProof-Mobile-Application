// lib/widgets/profile_avatar.dart
import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double size;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.size = 120,
  });

  Color _getAvatarColor(String name) {
    final List<Color> colors = [
      const Color(0xFFE67C73), // Red
      const Color(0xFF8E24AA), // Purple
      const Color(0xFF039BE5), // Blue
      const Color(0xFF0B8043), // Green
      const Color(0xFFF6BF26), // Yellow
      const Color(0xFFF4511E), // Orange
    ];

    final int hashCode = name.toUpperCase().codeUnits.fold(0, (a, b) => a + b);
    return colors[hashCode % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final String firstLetter = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final Color avatarColor = _getAvatarColor(name);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 3,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultAvatar(firstLetter, avatarColor);
                },
              )
            : _buildDefaultAvatar(firstLetter, avatarColor),
      ),
    );
  }

  Widget _buildDefaultAvatar(String letter, Color backgroundColor) {
    return Container(
      color: backgroundColor,
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
