
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../data/shared_prefs_helper.dart';
import 'api_config.dart';

class ApiDefault {
  static const String baseUrl = ApiConfig.baseUrl;


  static Map<String, dynamic> getDefaultData([Map<String, dynamic>? body]) {
    final SharedPrefsHelper prefs = SharedPrefsHelper();

    final String uIdentifiant = prefs.getString('u_identifiant');
    final String dIdentifiant = prefs.getString('d_identifiant', defaultValue: 'unknown_device');
    final String cIdentifiant = prefs.getString('c_identifiant', defaultValue: ApiConfig.defaultCIdentifiant);
    final String accessToken = prefs.getString('access_token', defaultValue: ApiConfig.defaultAccessToken);
    final String lang = prefs.getString('language_code', defaultValue: 'fr');
    final String registrationId = prefs.getString('fcm_token', defaultValue: '');

    final Map<String, dynamic> data = {
      if (uIdentifiant.isNotEmpty) 'u_identifiant': uIdentifiant,
      'd_identifiant': dIdentifiant,
      'c_identifiant': cIdentifiant,
      'access_token': accessToken,
      'api_key': ApiConfig.apiKey,
      'lang': lang,
      'registration_id': registrationId,
    };

    if (body != null) {
      data.addAll(body);
    }

    return data;
  }


  static Map<String, String> getDefaultHeaders() {
    final SharedPrefsHelper prefs = SharedPrefsHelper();
    final String token = prefs.getString('access_token').isNotEmpty
        ? prefs.getString('access_token')
        : prefs.getString('u_identifiant');
    final String agentId = prefs.getString('u_identifiant');
    final String fcmToken = prefs.getString('fcm_token');

    return {
      'Accept': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      if (agentId.isNotEmpty) 'X-Agent-Id': agentId,
      if (fcmToken.isNotEmpty) 'FCM-Token': fcmToken,
    };
  }


  static Map<String, dynamic> _sanitizeForLog(Map<String, dynamic> body) {
    const sensitiveKeys = {'code_securite', 'access_token', 'api_key', 'new_code_securite'};
    return body.map((key, value) {
      if (sensitiveKeys.contains(key)) {
        return MapEntry(key, '***');
      }
      return MapEntry(key, value);
    });
  }






  static Future<Map<String, dynamic>> postData(
    String endpoint,
    Map<String, dynamic> body, {
    String baseUrl = ApiConfig.baseUrl,
  }) async {
    final Uri url = Uri.parse("$baseUrl/$endpoint");
    final Map<String, dynamic> finalBody = getDefaultData(body);


    if (kDebugMode) {
      debugPrint('--- API REQUEST (FORM-DATA) ---');
      debugPrint('URL: $url');
      debugPrint('BODY: ${_sanitizeForLog(finalBody)}');
    }

    try {
      final request = http.MultipartRequest('POST', url);


      request.headers.addAll(getDefaultHeaders());


      finalBody.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });

      final streamedResponse = await request.send().timeout(ApiConfig.connectTimeout);
      final response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        debugPrint('--- API RESPONSE [$endpoint] ---');
        debugPrint('STATUS: ${response.statusCode}');
        debugPrint('BODY: ${_sanitizeForLog(_tryDecode(response.body))}');
      }

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
      if (kDebugMode) {
        debugPrint('--- API ERROR [$endpoint]: $e ---');
      }
      return {
        'status': 'error',
        'message': 'Erreur de connexion : $e',
      };
    }
  }


  static dynamic _tryDecode(String body) {
    try {
      return json.decode(body);
    } catch (_) {
      return body;
    }
  }
}
