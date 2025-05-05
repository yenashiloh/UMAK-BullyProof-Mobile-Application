// lib/models/card_model.dart
class CardModel {
  final String id;
  final String title;
  final String description;
  final List<CardButton> buttons;
  final String createdBy;
  final String status;
  final DateTime updatedAt;
  final DateTime createdAt;

  CardModel({
    required this.id,
    required this.title,
    required this.description,
    required this.buttons,
    required this.createdBy,
    required this.status,
    required this.updatedAt,
    required this.createdAt,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) {
    List<CardButton> buttonsList = [];
    if (json['buttons'] != null) {
      // Parse the string representation of the buttons list
      String buttonsStr = json['buttons'];
      // Remove outer brackets if they exist
      if (buttonsStr.startsWith('[') && buttonsStr.endsWith(']')) {
        buttonsStr = buttonsStr.substring(1, buttonsStr.length - 1);
      }
      
      // Try to parse as JSON if it appears to be in JSON format
      try {
        List<dynamic> buttonsData = [];
        // If the string is formatted like "[{...},{...}]"
        if (buttonsStr.contains('{') && buttonsStr.contains('}')) {
          // Split by "},{"
          List<String> parts = buttonsStr.split('},{');
          for (int i = 0; i < parts.length; i++) {
            String part = parts[i];
            if (i == 0 && !part.startsWith('{')) part = '{' + part;
            if (i == parts.length - 1 && !part.endsWith('}')) part = part + '}';
            // Now try to parse each part
            Map<String, dynamic> buttonData = {};
            // Extract label
            RegExp labelRegex = RegExp(r'"label":"([^"]+)"');
            Match? labelMatch = labelRegex.firstMatch(part);
            if (labelMatch != null) {
              buttonData['label'] = labelMatch.group(1);
            }
            
            // Extract action
            RegExp actionRegex = RegExp(r'"action":"([^"]+)"');
            Match? actionMatch = actionRegex.firstMatch(part);
            if (actionMatch != null) {
              buttonData['action'] = actionMatch.group(1);
            }
            
            if (buttonData.isNotEmpty) {
              buttonsData.add(buttonData);
            }
          }
        }
        
        buttonsList = buttonsData
            .map((buttonJson) => CardButton.fromJson(buttonJson))
            .toList();
      } catch (e) {
        print('Error parsing buttons: $e');
      }
    }

    return CardModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      buttons: buttonsList,
      createdBy: json['created_by'] ?? '',
      status: json['status'] ?? '',
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}

class CardButton {
  final String label;
  final String action;

  CardButton({
    required this.label,
    required this.action,
  });

  factory CardButton.fromJson(Map<String, dynamic> json) {
    return CardButton(
      label: json['label'] ?? '',
      action: json['action'] ?? '',
    );
  }
}