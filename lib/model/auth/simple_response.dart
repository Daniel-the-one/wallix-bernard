// lib/model/auth/simple_response.dart

class SimpleResponse {
  final String status;
  final String? message;
  final dynamic data;

  SimpleResponse({
    required this.status,
    this.message,
    this.data,
  });

  factory SimpleResponse.fromJson(Map<String, dynamic> json) {
    return SimpleResponse(
      status: json['status']?.toString() ?? 'error',
      message: json['message']?.toString(),
      data: json['data'] ?? json['information'],
    );
  }

  bool get isSuccess => status == 'success';
}
