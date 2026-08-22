// lib/api/api_default.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../data/shared_prefs_helper.dart';
import 'api_config.dart';

class ApiDefault {
  static const String baseUrl = ApiConfig.baseUrl;

  /// Injecte les paramètres par défaut dans chaque payload
  static Map<String, dynamic> getDefaultData([Map<String, dynamic>? body]) {
    final SharedPrefsHelper prefs = SharedPrefsHelper();

    final String uIdentifiant = prefs.getString('u_identifiant');
    final String dIdentifiant = prefs.getString('d_identifiant', defaultValue: 'unknown_device');
    final String cIdentifiant = prefs.getString('c_identifiant', defaultValue: 'wallix_agent_android');
    final String accessToken = prefs.getString('access_token', defaultValue: 'default_access_token');
    final String lang = prefs.getString('language_code', defaultValue: 'fr');
    final String registrationId = prefs.getString('fcm_token', defaultValue: '');

    final Map<String, dynamic> data = {
      if (uIdentifiant.isNotEmpty) 'u_identifiant': uIdentifiant,
      'd_identifiant': dIdentifiant,
      'c_identifiant': cIdentifiant,
      'access_token': accessToken,
      'lang': lang,
      'registration_id': registrationId,
    };

    if (body != null) {
      data.addAll(body);
    }

    return data;
  }

  /// Headers HTTP communs avec Authorization Bearer
  static Map<String, String> getDefaultHeaders() {
    final SharedPrefsHelper prefs = SharedPrefsHelper();
    final String token = prefs.getString('access_token').isNotEmpty
        ? prefs.getString('access_token')
        : prefs.getString('u_identifiant');
    final String agentId = prefs.getString('u_identifiant'); // Rapport: X-Agent-Id
    final String fcmToken = prefs.getString('fcm_token');

    return {
      'Accept': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      if (agentId.isNotEmpty) 'X-Agent-Id': agentId,
      if (fcmToken.isNotEmpty) 'FCM-Token': fcmToken,
    };
  }

  /// Méthode centrale pour envoyer des requêtes POST à l'API en form-data.
  static Future<Map<String, dynamic>> postData(String endpoint, Map<String, dynamic> body) async {
    final Uri url = Uri.parse("$baseUrl/$endpoint");
    final Map<String, dynamic> finalBody = getDefaultData(body);

    debugPrint('--- API REQUEST (FORM-DATA) ---');
    debugPrint('URL: $url');
    debugPrint('BODY: $finalBody');

    try {
      final request = http.MultipartRequest('POST', url);
      
      // Injecter les headers
      request.headers.addAll(getDefaultHeaders());

      // Injecter les champs du body en tant que form-data
      finalBody.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });

      final streamedResponse = await request.send().timeout(ApiConfig.connectTimeout);
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('--- API RESPONSE ---');
      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('BODY: ${response.body}');

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        if (decodedResponse is Map<String, dynamic>) {
          return decodedResponse;
        } else if (decodedResponse is List) {
          return {'status': 'success', 'data': decodedResponse};
        }
        return {'status': 'success', 'data': decodedResponse};
      } else {
        return {
          'status': 'error',
          'message': 'Erreur serveur (${response.statusCode})',
        };
      }
    } catch (e) {
      debugPrint('--- API ERROR: $e ---');
      return {
        'status': 'error',
        'message': 'Erreur de connexion : $e',
      };
    }
  }
}
