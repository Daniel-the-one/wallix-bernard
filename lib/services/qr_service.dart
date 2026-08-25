
import 'package:flutter/foundation.dart';
import '../api/api_config.dart';
import '../api/api_default.dart';
import '../model/qr_check_response.dart';

class QrService {
  static final QrService _instance = QrService._internal();
  factory QrService() => _instance;
  QrService._internal();



  Future<QrCheckResponse> checkQrCode(String qrCode) async {
    try {
      final response = await ApiDefault.postData(ApiConfig.contactsCheckQr, {
        'receiver_token': qrCode,
      });

      final qrCheck = QrCheckResponse.fromJson(response);
      debugPrint('QR CHECK INFO: nomComplet=${qrCheck.nomComplet ?? qrCheck.clientInfo?.clientNom}');
      return qrCheck;
    } catch (e) {
      debugPrint('QrService checkQrCode error: $e');
      return QrCheckResponse(
        status: 'error',
        message: 'Erreur de vérification du code QR: $e',
      );
    }
  }
}
