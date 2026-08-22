// lib/data/shared_prefs_helper.dart
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper {
  static final SharedPrefsHelper _instance = SharedPrefsHelper._internal();
  factory SharedPrefsHelper() => _instance;
  SharedPrefsHelper._internal();

  late SharedPreferences _prefs;

  // ============================================
  // INITIALISATION
  // ============================================
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ============================================
  // SAUVEGARDER (SETTERS)
  // ============================================
  
  // Sauvegarder une string
  Future<void> saveString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  // Sauvegarder un booléen
  Future<void> saveBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  // Sauvegarder un entier
  Future<void> saveInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  // Sauvegarder un double
  Future<void> saveDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
  }

  // Sauvegarder le code PIN
  Future<void> savePinCode(String pin) async {
    await _prefs.setString('user_pin', pin);
  }

  // ============================================
  // RÉCUPÉRER (GETTERS)
  // ============================================
  
  // Récupérer une string (avec valeur par défaut)
  String getString(String key, {String defaultValue = ''}) {
    return _prefs.getString(key) ?? defaultValue;
  }

  // Récupérer un booléen (avec valeur par défaut)
  bool getBool(String key, {bool defaultValue = false}) {
    return _prefs.getBool(key) ?? defaultValue;
  }

  // Récupérer un entier (avec valeur par défaut)
  int getInt(String key, {int defaultValue = 0}) {
    return _prefs.getInt(key) ?? defaultValue;
  }

  // Récupérer un double (avec valeur par défaut)
  double getDouble(String key, {double defaultValue = 0.0}) {
    return _prefs.getDouble(key) ?? defaultValue;
  }

  // Récupérer le code PIN
  String getPinCode() {
    return _prefs.getString('user_pin') ?? '1234'; // Par défaut 1234
  }

  // ============================================
  // VÉRIFICATIONS
  // ============================================
  
  // Vérifier si une clé existe
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  // Vérifier si le code PIN existe
  bool hasPinCode() {
    return _prefs.containsKey('user_pin');
  }

  // Vérifier si l'utilisateur est connecté
  bool isLoggedIn() {
    return _prefs.getBool('is_logged_in') ?? false;
  }

  // Vérifier si "Se souvenir de moi" est activé
  bool isRememberMe() {
    return _prefs.getBool('remember_me') ?? false;
  }

  // Vérifier le code PIN
  bool verifyPin(String enteredPin) {
    String storedPin = getPinCode();
    return enteredPin == storedPin;
  }

  // ============================================
  // SUPPRIMER
  // ============================================
  
  // Supprimer une clé
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  // Supprimer le code PIN
  Future<void> removePinCode() async {
    await _prefs.remove('user_pin');
  }

  // Tout supprimer (déconnexion complète)
  Future<void> clearAll() async {
    await _prefs.clear();
  }

  // ============================================
  // MÉTHODES SPÉCIFIQUES POUR L'AUTH
  // ============================================
  
  // Sauvegarder toutes les données utilisateur
  Future<void> saveUserData({
    required String phoneNumber,
    required String agentName,
    required String pinCode,
    bool rememberMe = false,
  }) async {
    await saveString('phone_number', phoneNumber);
    await saveString('agent_name', agentName);
    await savePinCode(pinCode);
    await saveBool('remember_me', rememberMe);
    await saveBool('is_logged_in', true);
  }

  // Récupérer les données utilisateur
  Map<String, dynamic> getUserData() {
    return {
      'phone_number': getString('phone_number'),
      'agent_name': getString('agent_name'),
      'pin_code': getPinCode(),
      'remember_me': isRememberMe(),
      'is_logged_in': isLoggedIn(),
    };
  }

  // Déconnexion
  Future<void> logout() async {
    // On garde le PIN et le numéro si "Se souvenir" est activé
    bool remember = isRememberMe();
    
    if (!remember) {
      await clearAll();
    } else {
      // On garde les données mais on déconnecte
      await saveBool('is_logged_in', false);
    }
  }

  // ============================================
  // MÉTHODES POUR LE NOM DE L'AGENT
  // ============================================
  
  // Sauvegarder le nom de l'agent
  Future<void> saveAgentName(String name) async {
    await _prefs.setString('agent_name', name);
  }

  // Récupérer le nom de l'agent
  String getAgentName() {
    return _prefs.getString('agent_name') ?? 'Agent';
  }

  // ============================================
  // MÉTHODES POUR LE NUMÉRO DE TÉLÉPHONE
  // ============================================
  
  // Sauvegarder le numéro de téléphone
  Future<void> savePhoneNumber(String phone) async {
    await _prefs.setString('phone_number', phone);
  }

  // Récupérer le numéro de téléphone
  String getPhoneNumber() {
    return _prefs.getString('phone_number') ?? '';
  }

  // ============================================
  // MÉTHODES POUR LA DERNIÈRE CONNEXION
  // ============================================
  
  // Sauvegarder la date de dernière connexion 
  Future<void> saveLastLogin(String date) async {
    await _prefs.setString('last_login', date);
  }

  // Récupérer la date de dernière connexion
  String getLastLogin() {
    return _prefs.getString('last_login') ?? '';
  }
}