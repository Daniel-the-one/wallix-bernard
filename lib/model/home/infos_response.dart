
import '../../api/api_status.dart';
import 'infos_accueil.dart';

class InfosResponse {
  final String status;
  final String? message;
  final InfosAccueil? information;

  InfosResponse({
    required this.status,
    this.message,
    this.information,
  });

  factory InfosResponse.fromJson(Map<String, dynamic> json) {
    final status = json['status']?.toString() ?? 'error';
    final message = json['message']?.toString();

    InfosAccueil? info;
    if (json['information'] is Map<String, dynamic>) {
      info = InfosAccueil.fromJson(json['information'] as Map<String, dynamic>);
    } else if (json['data'] is Map<String, dynamic>) {
      info = InfosAccueil.fromJson(json['data'] as Map<String, dynamic>);
    } else if (ApiStatus.isSuccess(status)) {
      info = InfosAccueil.fromJson(json);
    }

    return InfosResponse(
      status: status,
      message: message,
      information: info,
    );
  }

  bool get isSuccess => ApiStatus.isSuccess(status) && information != null;
}
