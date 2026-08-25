

class CommissionResponse {
  final double totalGains;
  final double gainsToday;
  final double? commission;
  final List<CommissionItem> items;
  final String status;

  CommissionResponse({
    required this.totalGains,
    required this.gainsToday,
    this.commission,
    required this.items,
    this.status = 'success',
  });

  factory CommissionResponse.fromJson(Map<String, dynamic> json) {
    final rawList = json['commissions'] as List? ??
        json['data'] as List? ??
        json['items'] as List? ??
        [];

    final List<CommissionItem> commissionItems = rawList
        .map((i) => CommissionItem.fromJson(i is Map<String, dynamic> ? i : {}))
        .toList();

    return CommissionResponse(
      totalGains: _parseDouble(json['total_gains'] ?? json['total'] ?? json['commission'] ?? json['commissions_total']),
      gainsToday: _parseDouble(json['gains_today'] ?? json['today']),
      commission: _parseDouble(json['commission'] ?? json['commissions']),
      items: commissionItems,
      status: json['status']?.toString() ?? 'success',
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
}

class CommissionItem {
  final String id;
  final String description;
  final double amount;
  final DateTime date;
  final String transactionRef;

  CommissionItem({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.transactionRef,
  });

  factory CommissionItem.fromJson(Map<String, dynamic> json) {
    return CommissionItem(
      id: json['id']?.toString() ?? '',
      description: json['description']?.toString() ?? json['libelle']?.toString() ?? 'Commission',
      amount: _parseDouble(json['amount'] ?? json['montant'] ?? json['commission']),
      date: _parseDateTime(json['date'] ?? json['created_at']),
      transactionRef: json['transaction_ref']?.toString() ?? json['reference']?.toString() ?? '',
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
}
