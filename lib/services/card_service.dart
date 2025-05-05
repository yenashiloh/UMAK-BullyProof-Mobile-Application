// lib/services/card_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bully_proof_umak/config.dart';
import 'package:bully_proof_umak/models/card_model.dart';

class CardService {
  static const String cardsEndpoint = '${url}cards';
  
  static Future<List<CardModel>> fetchCards(String token) async {
    try {
      final response = await http.get(
        Uri.parse(cardsEndpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> cardsJson = jsonDecode(response.body);
        return cardsJson.map((json) => CardModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load cards: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching cards: $e');
      // Return empty list in case of error to avoid app crashes
      return [];
    }
  }
}