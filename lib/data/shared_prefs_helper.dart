
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper {
  static final SharedPrefsHelper _instance = SharedPrefsHelper._internal();
  factory SharedPrefsHelper() => _instance;
  SharedPrefsHelper._internal();

  late SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();



  static const String _pinKey = 'user_pin';



  String? _pinCache;




  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();



    final String? legacyPin = _prefs.getString(_pinKey);
    if (legacyPin != null && legacyPin.isNotEmpty) {
      await _secureStorage.write(key: _pinKey, value: legacyPin);
      await _prefs.remove(_pinKey);
      _pinCache = legacyPin;
    } else {
      _pinCache = await _secureStorage.read(key: _pinKey);
    }
  }






  Future<void> saveString(String key, String value) async {
    await _prefs.setString(key, value);
  }


  Future<void> saveBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }


  Future<void> saveInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }


  Future<void> saveDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
  }


  Future<void> savePinCode(String pin) async {
    await _secureStorage.write(key: _pinKey, value: pin);
    _pinCache = pin;
  }






  String getString(String key, {String defaultValue = ''}) {
    return _prefs.getString(key) ?? defaultValue;
  }


  bool getBool(String key, {bool defaultValue = false}) {
    return _prefs.getBool(key) ?? defaultValue;
  }


  int getInt(String key, {int defaultValue = 0}) {
    return _prefs.getInt(key) ?? defaultValue;
  }


  double getDouble(String key, {double defaultValue = 0.0}) {
    return _prefs.getDouble(key) ?? defaultValue;
  }




  String? getPinCode() {
    return _pinCache;
  }






  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }


  bool hasPinCode() {
    return _pinCache != null && _pinCache!.isNotEmpty;
  }


  bool isLoggedIn() {
    return _prefs.getBool('is_logged_in') ?? false;
  }


  bool isRememberMe() {
    return _prefs.getBool('remember_me') ?? false;
  }



  bool verifyPin(String enteredPin) {
    final String? storedPin = getPinCode();
    if (storedPin == null || storedPin.isEmpty) return false;
    return enteredPin == storedPin;
  }






  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }


  Future<void> removePinCode() async {
    await _secureStorage.delete(key: _pinKey);
    _pinCache = null;
  }


  Future<void> clearAll() async {
    await _prefs.clear();
    await removePinCode();
  }






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


  Map<String, dynamic> getUserData() {
    return {
      'phone_number': getString('phone_number'),
      'agent_name': getString('agent_name'),
      'pin_code': getPinCode() ?? '',
      'remember_me': isRememberMe(),
      'is_logged_in': isLoggedIn(),
    };
  }


  Future<void> logout() async {

    bool remember = isRememberMe();

    if (!remember) {
      await clearAll();
    } else {

      await saveBool('is_logged_in', false);
    }
  }






  Future<void> saveAgentName(String name) async {
    await _prefs.setString('agent_name', name);
  }


  String getAgentName() {
    return _prefs.getString('agent_name') ?? 'Agent';
  }






  Future<void> savePhoneNumber(String phone) async {
    await _prefs.setString('phone_number', phone);
  }


  String getPhoneNumber() {
    return _prefs.getString('phone_number') ?? '';
  }






  Future<void> saveLastLogin(String date) async {
    await _prefs.setString('last_login', date);
  }


  String getLastLogin() {
    return _prefs.getString('last_login') ?? '';
  }
}
