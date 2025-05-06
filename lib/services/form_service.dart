// lib/services/form_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bully_proof_umak/config.dart';
import 'package:bully_proof_umak/models/form_model.dart';

class FormService {
  static const String formsEndpoint = '${url}forms';

  static Future<List<FormModel>> fetchForms(String token) async {
    try {
      final response = await http.get(
        Uri.parse(formsEndpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> formsJson = jsonDecode(response.body);
        return formsJson.map((json) => FormModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load forms: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching forms: $e');
      // Return empty list in case of error to avoid app crashes
      return [];
    }
  }

  static Future<FormModel?> fetchFormById(String token, String formId) async {
    try {
      final response = await http.get(
        Uri.parse('$formsEndpoint/$formId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return FormModel.fromJson(json);
      } else {
        throw Exception('Failed to load form: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching form: $e');
      return null;
    }
  }

  static Future<bool> submitFormData(
      String token, Map<String, dynamic> formData) async {
    try {
      final response = await http.post(
        Uri.parse('$formsEndpoint/submit'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(formData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to submit form: ${response.statusCode}');
      }
    } catch (e) {
      print('Error submitting form: $e');
      return false;
    }
  }
}
