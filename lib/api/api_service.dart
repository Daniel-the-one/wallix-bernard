
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'api_default.dart';
import '../data/shared_prefs_helper.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final SharedPrefsHelper _prefs = SharedPrefsHelper();

  String get baseUrl => ApiConfig.baseUrl;


  Map<String, String> getAuthHeaders() {
    return ApiDefault.getDefaultHeaders();
  }


  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    return ApiDefault.postData(endpoint, body);
  }


  Future<Map<String, dynamic>> get(String endpoint, [Map<String, dynamic>? queryParams]) async {
    Uri uri = Uri.parse('$baseUrl/$endpoint');
    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams.map((k, v) => MapEntry(k, v.toString())));
    }

    try {
      final response = await http.get(uri, headers: getAuthHeaders()).timeout(ApiConfig.connectTimeout);
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
        return {'status': 'success', 'data': decoded};
      }
      return {'status': 'error', 'message': 'Erreur serveur (${response.statusCode})'};
    } catch (e) {
      debugPrint('ApiService GET error: $e');
      return {'status': 'error', 'message': 'Erreur de connexion : $e'};
    }
  }


  String? getAccessToken() {
    final token = _prefs.getString('access_token');
    return token.isNotEmpty ? token : _prefs.getString('u_identifiant');
  }


  Future<void> saveAccessToken(String token) async {
    await _prefs.saveString('access_token', token);
    await _prefs.saveString('u_identifiant', token);
  }
}
