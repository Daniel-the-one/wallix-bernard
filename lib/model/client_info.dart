// lib/model/client_info.dart

class ClientInfo {
  final String clientNom;
  final String clientTelephone;
  final String clientToken;
  final bool clientVerified;
  final String? qrCode;
  final String? nomComplet;

  ClientInfo({
    required this.clientNom,
    required this.clientTelephone,
    required this.clientToken,
    this.clientVerified = false,
    this.qrCode,
    this.nomComplet,
  });

  factory ClientInfo.fromJson(Map<String, dynamic> json) {
    final nom = json['client_nom']?.toString() ??
        json['nomComplet']?.toString() ??
        json['nom']?.toString() ??
        json['name']?.toString() ??
        'Client';

    final tel = json['client_telephone']?.toString() ??
        json['telephone']?.toString() ??
        json['phone']?.toString() ??
        '';

    final token = json['client_token']?.toString() ??
        json['token']?.toString() ??
        json['client_id']?.toString() ??
        '';

    final qr = json['qrCode']?.toString() ?? json['qr_code']?.toString();

    final verified = json['client_verified'] == true ||
        json['client_verified'] == 1 ||
        json['client_verified'] == '1';

    return ClientInfo(
      clientNom: nom,
      clientTelephone: tel,
      clientToken: token,
      clientVerified: verified,
      qrCode: qr,
      nomComplet: json['nomComplet']?.toString() ?? nom,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'client_nom': clientNom,
      'client_telephone': clientTelephone,
      'client_token': clientToken,
      'client_verified': clientVerified,
      'qr_code': qrCode,
      'nomComplet': nomComplet,
    };
  }
}
