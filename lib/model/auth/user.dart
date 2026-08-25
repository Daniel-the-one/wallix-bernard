

class User {
  final String nom;
  final String? agentName;
  final String? numeroAgent;
  final String? agentPhoto;
  final String uIdentifiant;
  final String? token;
  final String? accessToken;
  final double solde;
  final bool verified;
  final String telephone;

  User({
    required this.nom,
    this.agentName,
    this.numeroAgent,
    this.agentPhoto,
    required this.uIdentifiant,
    this.token,
    this.accessToken,
    required this.solde,
    required this.verified,
    required this.telephone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final info = json['information'] is Map<String, dynamic>
        ? json['information'] as Map<String, dynamic>
        : json;

    final String extractedToken = info['token']?.toString() ??
        info['access_token']?.toString() ??
        json['u_identifiant']?.toString() ??
        '';

    final String name = info['agent_name']?.toString() ??
        info['agentName']?.toString() ??
        info['name']?.toString() ??
        info['nom']?.toString() ??
        'Agent';

    return User(
      nom: name,
      agentName: info['agent_name']?.toString() ?? info['agentName']?.toString(),
      numeroAgent: info['numero_agent']?.toString(),
      agentPhoto: info['agent_photo']?.toString(),
      uIdentifiant: extractedToken,
      token: extractedToken,
      accessToken: extractedToken,
      solde: _parseDouble(info['solde'] ?? info['balance']),
      verified: _parseVerified(info['verified'] ?? info['is_verified'] ?? info['client_verified']),
      telephone: info['telephone']?.toString() ?? info['phone']?.toString() ?? info['client_telephone']?.toString() ?? '',
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      String cleaned = value.replaceAll(',', '.').replaceAll(' ', '');
      return double.tryParse(cleaned) ?? 0.0;
    }
    return 0.0;
  }

  static bool _parseVerified(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      final lowercase = value.toLowerCase();
      return lowercase == '1' ||
          lowercase == 'true' ||
          lowercase == 'oui' ||
          lowercase == 'yes' ||
          lowercase == 'verified';
    }
    return false;
  }

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'agent_name': agentName,
      'numero_agent': numeroAgent,
      'agent_photo': agentPhoto,
      'u_identifiant': uIdentifiant,
      'token': token,
      'access_token': accessToken,
      'solde': solde,
      'verified': verified,
      'telephone': telephone,
    };
  }
}
