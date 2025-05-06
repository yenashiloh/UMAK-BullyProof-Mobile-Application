// lib/services/form_element_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bully_proof_umak/config.dart';
import 'package:bully_proof_umak/models/form_element_model.dart';

class FormElementService {
  static const String formElementsEndpoint = '${url}form-elements';
  
  static Future<List<FormElementModel>> fetchFormElements(String token, String formBuilderId) async {
    try {
      final response = await http.get(
        Uri.parse('$formElementsEndpoint?form_builder_id=$formBuilderId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> elementsJson = jsonDecode(response.body);
        return elementsJson.map((json) => FormElementModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load form elements: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching form elements: $e');
      return [];
    }
  }
}