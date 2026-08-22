// lib/services/auth_service.dart
import 'package:flutter/material.dart';
import '../api/api_config.dart';
import '../api/api_default.dart';
import '../data/shared_prefs_helper.dart';
import '../model/auth/login_response.dart';
import '../model/auth/simple_response.dart';
import '../model/auth/user.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final SharedPrefsHelper _prefs = SharedPrefsHelper();

  User? _currentUser;
  String? _uIdentifiant;
  String? _phoneNumber;
  String? _agentName;

  User? get currentUser => _currentUser;
  String? get phoneNumber => _phoneNumber ?? _currentUser?.telephone;
  String? get agentName => _agentName ?? _currentUser?.nom;
  String? get uIdentifiant => _uIdentifiant ?? _currentUser?.uIdentifiant;

  void init() {
    _uIdentifiant = _prefs.getString('u_identifiant');
    _phoneNumber = _prefs.getString('phone_number');
    _agentName = _prefs.getString('agent_name');

    if (_uIdentifiant != null && _uIdentifiant!.isNotEmpty) {
      _currentUser = User(
        nom: _agentName ?? 'Agent',
        uIdentifiant: _uIdentifiant!,
        solde: _prefs.getDouble('agent_solde'),
        verified: _prefs.getBool('agent_verified'),
        telephone: _phoneNumber ?? '',
      );
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>> login(String phone, String pin) async {
    final String agentNumber = phone.startsWith('228') ? phone : '228$phone';

    final response = await ApiDefault.postData(ApiConfig.usersConnecteUseraccount, {
      'username': agentNumber,
      'code_securite': pin,
      'type_login': '0', // Login type specified in CYGNE collection
    });

    final loginResponse = LoginResponse.fromJson(response);

    if (loginResponse.isSuccess || (response['status'] == 'success')) {
      try {
        _currentUser = loginResponse.user ?? User.fromJson(response);
        _uIdentifiant = _currentUser!.uIdentifiant;
        _phoneNumber = _currentUser!.telephone;
        _agentName = _currentUser!.nom;

        await _prefs.saveString('u_identifiant', _uIdentifiant!);
        await _prefs.saveString('access_token', _currentUser!.accessToken ?? _uIdentifiant!);
        await _prefs.saveString('phone_number', _phoneNumber!);
        await _prefs.saveString('agent_name', _agentName!);
        await _prefs.saveDouble('agent_solde', _currentUser!.solde);
        await _prefs.saveBool('agent_verified', _currentUser!.verified);
        await _prefs.savePinCode(pin);
        await _prefs.saveBool('is_logged_in', true);

        notifyListeners();
        return {'status': 'success', 'user': _currentUser};
      } catch (e) {
        debugPrint('Error parsing user data: $e');
        return {'status': 'error', 'message': 'Erreur de traitement des données utilisateur'};
      }
    } else {
      if (response['message'] == 'code_securite_error') {
        return {'status': 'error', 'message': 'Code de sécurité incorrect.'};
      }
      return {
        'status': 'error',
        'message': response['message'] ?? 'échec de l\'authentification'
      };
    }
  }

  Future<SimpleResponse> updatePassword({
    required String currentPin,
    required String newPin,
  }) async {
    final response = await ApiDefault.postData(ApiConfig.usersUpdatePassword, {
      'code_securite': currentPin,
      'new_code_securite': newPin,
    });

    final result = SimpleResponse.fromJson(response);
    if (result.isSuccess) {
      await _prefs.savePinCode(newPin);
    }
    return result;
  }

  void setUserData({required String phoneNumber, String? agentName}) {
    _phoneNumber = phoneNumber;
    _agentName = agentName;
    notifyListeners();
  }

  Future<void> logout() async {
    await _prefs.logout();
    _uIdentifiant = null;
    _phoneNumber = null;
    _agentName = null;
    _currentUser = null;
    notifyListeners();
  }

  bool get isLoggedIn => uIdentifiant != null && uIdentifiant!.isNotEmpty;
}
