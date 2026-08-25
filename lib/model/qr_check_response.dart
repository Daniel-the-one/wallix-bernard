
import '../api/api_status.dart';
import 'client_info.dart';

class QrCheckResponse {
  final String status;
  final String? message;
  final String? nomComplet;
  final String? clientToken;
  final String? clientTelephone;
  final bool isVerified;
  final ClientInfo? clientInfo;

  QrCheckResponse({
    required this.status,
    this.message,
    this.nomComplet,
    this.clientToken,
    this.clientTelephone,
    this.isVerified = false,
    this.clientInfo,
  });

  factory QrCheckResponse.fromJson(Map<String, dynamic> json) {
    final status = json['status']?.toString() ?? 'success';
    final message = json['message']?.toString();

    final info = json['information'] is Map<String, dynamic>
        ? json['information'] as Map<String, dynamic>
        : (json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : json);

    final String nom = info['nomComplet']?.toString() ??
        info['client_nom']?.toString() ??
        info['nom']?.toString() ??
        info['name']?.toString() ??
        '';

    final String token = info['client_token']?.toString() ??
        info['token']?.toString() ??
        info['client_id']?.toString() ??
        '';

    final String phone = info['client_telephone']?.toString() ??
        info['telephone']?.toString() ??
        info['phone']?.toString() ??
        '';

    final bool verified = info['client_verified'] == true ||
        info['client_verified'] == 1 ||
        info['is_verified'] == true ||
        info['is_verified'] == 1;

    final client = ClientInfo(
      clientNom: nom.isNotEmpty ? nom : 'Client',
      clientTelephone: phone,
      clientToken: token,
      clientVerified: verified,
      nomComplet: nom,
    );

    return QrCheckResponse(
      status: status,
      message: message,
      nomComplet: nom,
      clientToken: token,
      clientTelephone: phone,
      isVerified: verified,
      clientInfo: client,
    );
  }

  bool get isSuccess => ApiStatus.isSuccess(status) || (nomComplet != null && nomComplet!.isNotEmpty);
}
