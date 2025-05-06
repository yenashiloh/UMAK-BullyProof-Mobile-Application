// lib/models/form_element_model.dart
import 'dart:convert';

class FormElementModel {
  final String id;
  final String formBuilderId;
  final String stepId;
  final String elementType;
  final String title;
  final String position;
  final Map<String, dynamic> settings;
  final List<FormElementOption> options;
  final bool isRequired;
  final String cardId;
  final DateTime updatedAt;
  final DateTime createdAt;

  FormElementModel({
    required this.id,
    required this.formBuilderId,
    required this.stepId,
    required this.elementType,
    required this.title,
    required this.position,
    required this.settings,
    required this.options,
    required this.isRequired,
    required this.cardId,
    required this.updatedAt,
    required this.createdAt,
  });

  factory FormElementModel.fromJson(Map<String, dynamic> json) {
    List<FormElementOption> optionsList = [];

    if (json['options'] != null && json['options'] != '[]') {
      try {
        final List<dynamic> optionsData = jsonDecode(json['options']);
        optionsList = optionsData
            .map((option) => FormElementOption.fromJson(option))
            .toList();
      } catch (e) {
        print('Error parsing form element options: $e');
      }
    }

    Map<String, dynamic> settingsMap = {};
    if (json['settings'] != null && json['settings'] != '[]') {
      try {
        settingsMap = jsonDecode(json['settings']);
      } catch (e) {
        print('Error parsing form element settings: $e');
      }
    }

    // Convert 'is_required' to boolean, handling string representations
    bool isRequired = false;
    if (json['is_required'] != null) {
      if (json['is_required'] is bool) {
        isRequired = json['is_required'];
      } else if (json['is_required'] is String) {
        // Convert string representation to boolean
        isRequired = json['is_required'].toString().toLowerCase() == 'true';
      }
    }

    return FormElementModel(
      id: json['_id'] ?? '',
      formBuilderId: json['form_builder_id'] ?? '',
      stepId: json['step_id'] ?? '',
      elementType: json['element_type'] ?? '',
      title: json['title'] ?? '',
      position: json['position']?.toString() ?? '0',
      settings: settingsMap,
      options: optionsList,
      isRequired: isRequired,
      cardId: json['card_id'] ?? '',
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}

class FormElementOption {
  final String id;
  final String text;

  FormElementOption({
    required this.id,
    required this.text,
  });

  factory FormElementOption.fromJson(Map<String, dynamic> json) {
    return FormElementOption(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
    );
  }
}
