
import 'package:flutter/material.dart';
import '../model/qr_check_response.dart';
import '../services/qr_service.dart';

class QrProvider extends ChangeNotifier {
  final QrService _qrService = QrService();


  Future<QrCheckResponse> checkQrCode(String qrCode) {
    return _qrService.checkQrCode(qrCode);
  }
}
