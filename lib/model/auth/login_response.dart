// lib/model/auth/login_response.dart
import 'user.dart';

class LoginResponse {
  final String status;
  final String? message;
  final User? user;
  final String? accessToken;
  final String? token;
  final Map<String, dynamic>? information;

  LoginResponse({
    required this.status,
    this.message,
    this.user,
    this.accessToken,
    this.token,
    this.information,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final String status = json['status']?.toString() ?? 'error';
    final String? message = json['message']?.toString();
    final info = json['information'] is Map<String, dynamic>
        ? json['information'] as Map<String, dynamic>
        : (json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : null);

    User? user;
    String? token;

    if (info != null) {
      user = User.fromJson(info);
      token = info['token']?.toString() ?? info['access_token']?.toString();
    } else if (json['token'] != null || json['u_identifiant'] != null) {
      user = User.fromJson(json);
      token = json['token']?.toString() ?? json['u_identifiant']?.toString();
    }

    return LoginResponse(
      status: status,
      message: message,
      user: user,
      accessToken: token,
      token: token,
      information: info,
    );
  }

  bool get isSuccess => status == 'success' || (user != null && user!.uIdentifiant.isNotEmpty);
}
