// lib/model/operation_history_response.dart
import 'transaction_item.dart';

class OperationHistoryResponse {
  final String status;
  final String? message;
  final List<TransactionItem> operations;

  OperationHistoryResponse({
    required this.status,
    this.message,
    required this.operations,
  });

  factory OperationHistoryResponse.fromJson(Map<String, dynamic> json) {
    final status = json['status']?.toString() ?? 'success';
    final message = json['message']?.toString();

    List<TransactionItem> list = [];
    final dynamic rawData = json['data'] ?? json['operations'] ?? json['transactions'] ?? json['information'];

    if (rawData is List) {
      list = rawData
          .whereType<Map<String, dynamic>>()
          .map((item) => TransactionItem.fromJson(item))
          .toList();
    }

    return OperationHistoryResponse(
      status: status,
      message: message,
      operations: list,
    );
  }

  bool get isSuccess => status == 'success';
}
