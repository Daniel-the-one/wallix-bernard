// lib/services/qr_service.dart
import 'package:flutter/foundation.dart';
import '../api/api_config.dart';
import '../api/api_default.dart';
import '../model/qr_check_response.dart';

class QrService {
  static final QrService _instance = QrService._internal();
  factory QrService() => _instance;
  QrService._internal();

  /// Vérifie et valide le QR code d'un client
  /// Endpoint: contacts/check_qr
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
