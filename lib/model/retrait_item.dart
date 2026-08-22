// lib/model/retrait_item.dart

enum RetraitStatus { initialise, accepte, refuse, annule, unknown }

class RetraitItem {
  final String id;
  final String keyRetrait; // key_retraitP ou r_identifiant
  final String clientName;
  final String clientPhone;
  final double amount;
  final String amountShow;
  final DateTime date;
  final RetraitStatus status;
  final String statusLabel;
  final String reference;

  RetraitItem({
    required this.id,
    required this.keyRetrait,
    required this.clientName,
    required this.clientPhone,
    required this.amount,
    required this.amountShow,
    required this.date,
    required this.status,
    required this.statusLabel,
    required this.reference,
  });

  factory RetraitItem.fromJson(Map<String, dynamic> json) {
    final etat = _parseInt(json['etat'] ?? json['status']);
    final keyP = json['key_retraitP']?.toString() ??
        json['key_retrait']?.toString() ??
        json['r_identifiant']?.toString() ??
        json['id']?.toString() ??
        '';

    final montant = _parseDouble(json['montant'] ?? json['amount']);
    final montantShow = json['montant_show']?.toString() ?? '$montant XOF';

    return RetraitItem(
      id: json['id']?.toString() ?? keyP,
      keyRetrait: keyP,
      clientName: json['contact']?.toString() ?? json['client_nom']?.toString() ?? json['name']?.toString() ?? 'Client',
      clientPhone: json['telephone']?.toString() ?? json['client_telephone']?.toString() ?? '',
      amount: montant,
      amountShow: montantShow,
      date: _parseDateTime(json['retrait_datetime'] ?? json['date'] ?? json['created_at']),
      status: _mapToStatus(etat),
      statusLabel: _mapToLabel(etat),
      reference: json['reference']?.toString() ?? keyP,
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static RetraitStatus _mapToStatus(int etat) {
    switch (etat) {
      case 1:
        return RetraitStatus.accepte;
      case 2:
        return RetraitStatus.refuse;
      case 3:
        return RetraitStatus.annule;
      case 0:
        return RetraitStatus.initialise;
      default:
        return RetraitStatus.initialise;
    }
  }

  static String _mapToLabel(int etat) {
    switch (etat) {
      case 1:
        return 'Accepté';
      case 2:
        return 'Refusé';
      case 3:
        return 'Annulé';
      default:
        return 'En attente';
    }
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

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  bool get canBeCancelled => status == RetraitStatus.initialise;
}

class RetraitListResponse {
  final String status;
  final String? message;
  final List<RetraitItem> listRetraits;

  RetraitListResponse({
    required this.status,
    this.message,
    required this.listRetraits,
  });

  factory RetraitListResponse.fromJson(Map<String, dynamic> json) {
    final status = json['status']?.toString() ?? 'success';
    final message = json['message']?.toString();

    List<RetraitItem> retraits = [];
    final dynamic rawData = json['data'] ?? json['retraits'] ?? json['list_retraits'] ?? json['information'];

    if (rawData is List) {
      retraits = rawData
          .whereType<Map<String, dynamic>>()
          .map((r) => RetraitItem.fromJson(r))
          .toList();
    }

    return RetraitListResponse(
      status: status,
      message: message,
      listRetraits: retraits,
    );
  }

  bool get isSuccess => status == 'success';
}
