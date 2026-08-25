

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  bool isRead;
  final Map<String, dynamic>? data;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    this.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ??
          json['notification_id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['message_title']?.toString() ??
          json['title']?.toString() ??
          json['titre']?.toString() ??
          'Notification',
      body: json['message_body']?.toString() ??
          json['body']?.toString() ??
          json['message']?.toString() ??
          json['contenu']?.toString() ??
          '',
      timestamp: json['received_at'] != null
          ? DateTime.tryParse(json['received_at'].toString()) ?? DateTime.now()
          : (json['timestamp'] != null
              ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
              : (json['created_at'] != null
                  ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
                  : DateTime.now())),
      isRead: json['is_read'] == true || json['is_read'] == 1 || json['is_read'] == '1',
      data: json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : null,
    );
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) => NotificationModel.fromJson(map);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'is_read': isRead,
      'data': data,
    };
  }

  Map<String, dynamic> toMap() => toJson();
}
