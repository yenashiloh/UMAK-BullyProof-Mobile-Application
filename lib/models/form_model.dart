// lib/models/form_model.dart
import 'dart:convert';

class FormModel {
  final String id;
  final String title;
  final String description;
  final String createdBy;
  final String status;
  final String cardId;
  final List<FormStep> steps;
  final DateTime updatedAt;
  final DateTime createdAt;

  FormModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdBy,
    required this.status,
    required this.cardId,
    required this.steps,
    required this.updatedAt,
    required this.createdAt,
  });

  factory FormModel.fromJson(Map<String, dynamic> json) {
    List<FormStep> stepsList = [];
    
    if (json['steps'] != null) {
      try {
        List<dynamic> stepsData = jsonDecode(json['steps']);
        stepsList = stepsData.map((step) => FormStep.fromJson(step)).toList();
      } catch (e) {
        print('Error parsing form steps: $e');
      }
    }

    return FormModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      createdBy: json['created_by'] ?? '',
      status: json['status'] ?? '',
      cardId: json['card_id'] ?? '',
      steps: stepsList,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}

class FormStep {
  final String id;
  final String title;
  
  FormStep({
    required this.id,
    required this.title,
  });

  factory FormStep.fromJson(Map<String, dynamic> json) {
    return FormStep(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
    );
  }
}