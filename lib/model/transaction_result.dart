
import '../api/api_status.dart';
import 'transaction_item.dart';

class TransactionResult {
  final String status;
  final String? message;
  final String? reference;
  final String? keyDepot;
  final String? keyRetraitP;
  final double? amount;
  final double? commission;
  final String? clientName;
  final DateTime? datetime;
  final TransactionItem? transactionItem;
  final Map<String, dynamic>? rawData;

  TransactionResult({
    required this.status,
    this.message,
    this.reference,
    this.keyDepot,
    this.keyRetraitP,
    this.amount,
    this.commission,
    this.clientName,
    this.datetime,
    this.transactionItem,
    this.rawData,
  });

  factory TransactionResult.fromJson(Map<String, dynamic> json) {
    final status = json['status']?.toString() ?? 'success';
    final message = json['message']?.toString();
    final info = json['information'] is Map<String, dynamic>
        ? json['information'] as Map<String, dynamic>
        : (json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : json);

    final ref = info['reference']?.toString() ?? json['reference']?.toString();
    final kDepot = info['key_depot']?.toString() ?? json['key_depot']?.toString();
    final kRetrait = info['key_retraitP']?.toString() ?? info['key_retrait']?.toString() ?? json['key_retraitP']?.toString();
    final amt = _parseDouble(info['amount'] ?? info['montant'] ?? json['montant']);
    final comm = _parseDouble(info['commission'] ?? json['commission']);
    final cName = info['client_nom']?.toString() ?? info['nomComplet']?.toString() ?? info['name']?.toString() ?? json['client_name']?.toString();

    final dt = _parseDateTime(info['depot_datetime'] ?? info['retrait_datetime'] ?? info['transaction_datetime'] ?? json['datetime']);

    TransactionItem? item;
    if (json.containsKey('transaction') && json['transaction'] is Map<String, dynamic>) {
      item = TransactionItem.fromJson(json['transaction'] as Map<String, dynamic>);
    }

    return TransactionResult(
      status: status,
      message: message,
      reference: ref,
      keyDepot: kDepot,
      keyRetraitP: kRetrait,
      amount: amt,
      commission: comm,
      clientName: cName,
      datetime: dt,
      transactionItem: item,
      rawData: json,
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

  bool get isSuccess => ApiStatus.isSuccess(status);
}
