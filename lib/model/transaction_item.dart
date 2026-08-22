// lib/model/transaction_item.dart
import 'package:intl/intl.dart';

enum TransactionType { credit, debit, envoi, reception, depot, retrait, unknown }

class TransactionItem {
  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final String amountShow;
  final DateTime date;
  final TransactionType type;
  final String status;
  final String? keyDepot;
  final String? typeOperationKey;
  final String? transactionDetails;
  final String? heureTransaction;
  final String? dateTransaction;
  final double? montantTotal;

  TransactionItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.amountShow,
    required this.date,
    required this.type,
    this.status = 'success',
    this.keyDepot,
    this.typeOperationKey,
    this.transactionDetails,
    this.heureTransaction,
    this.dateTransaction,
    this.montantTotal,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    final typeId = _parseInt(json['type_operation'] ?? json['type_operation_key']);
    final montant = _parseDouble(json['montant'] ?? json['amount'] ?? json['montant_total']);
    final mShow = json['montant_show']?.toString() ?? '$montant XOF';
    final parsedDate = _parseDateTime(
      json['transaction_datetime'] ??
      json['depot_datetime'] ??
      json['date_transaction'] ??
      json['date'] ??
      json['created_at'],
    );

    return TransactionItem(
      id: json['id']?.toString() ?? json['key_depot']?.toString() ?? json['reference']?.toString() ?? '',
      title: json['title']?.toString() ?? _mapTypeToLabel(typeId, json),
      subtitle: json['subtitle']?.toString() ?? json['contact']?.toString() ?? json['client_nom']?.toString() ?? json['reference']?.toString() ?? '',
      amount: montant,
      amountShow: mShow,
      date: parsedDate,
      type: _mapToType(typeId, json),
      status: json['status_show']?.toString() ?? json['status']?.toString() ?? 'success',
      keyDepot: json['key_depot']?.toString(),
      typeOperationKey: json['type_operation_key']?.toString() ?? typeId.toString(),
      transactionDetails: json['transaction_details']?.toString(),
      heureTransaction: json['heure_transaction']?.toString(),
      dateTransaction: json['date_transaction']?.toString(),
      montantTotal: _parseDouble(json['montant_total']),
    );
  }

  factory TransactionItem.fromApi(Map<String, dynamic> json) => TransactionItem.fromJson(json);

  static String _mapTypeToLabel(int typeId, [Map<String, dynamic>? json]) {
    if (json != null && json['libelle'] != null) return json['libelle'].toString();
    switch (typeId) {
      case 1:
        return 'Envoi';
      case 2:
        return 'Réception';
      case 3:
        return 'Dépôt';
      case 4:
        return 'Retrait';
      default:
        return 'Opération';
    }
  }

  static TransactionType _mapToType(int typeId, [Map<String, dynamic>? json]) {
    final String typeStr = json?['type']?.toString().toLowerCase() ?? '';
    if (typeStr == 'depot' || typeId == 3) return TransactionType.depot;
    if (typeStr == 'retrait' || typeId == 4) return TransactionType.retrait;
    if (typeStr == 'envoi' || typeId == 1) return TransactionType.envoi;
    if (typeStr == 'reception' || typeId == 2) return TransactionType.reception;
    if (typeStr == 'credit') return TransactionType.credit;
    if (typeStr == 'debit') return TransactionType.debit;
    return TransactionType.unknown;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
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

  static Map<String, List<TransactionItem>> groupByDate(List<TransactionItem> transactions) {
    final Map<String, List<TransactionItem>> grouped = {};
    for (var tx in transactions) {
      final String dateKey = DateFormat('dd/MM/yyyy').format(tx.date);
      grouped.putIfAbsent(dateKey, () => []).add(tx);
    }
    return grouped;
  }
}