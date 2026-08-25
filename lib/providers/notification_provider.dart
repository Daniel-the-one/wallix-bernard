
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../model/notification_model.dart';
import '../data/shared_prefs_helper.dart';
import '../firebase_service.dart';
import 'dart:convert';

class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  final SharedPrefsHelper _prefs = SharedPrefsHelper();
  final FirebaseService _firebaseService = FirebaseService();

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;

  NotificationProvider() {
    _loadNotifications();
    _initializePush();
  }

  Future<void> _initializePush() async {
    await _firebaseService.init();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleIncomingMessage(message);
    });
  }

  void _handleIncomingMessage(RemoteMessage message) {
    if (message.notification != null) {
      final newNotif = NotificationModel(
        id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: message.notification!.title ?? 'Wallix',
        body: message.notification!.body ?? '',
        timestamp: DateTime.now(),
        data: message.data,
      );

      _addNotification(newNotif);
      _showLocalNotification(newNotif);
    }
  }

  Future<void> _showLocalNotification(NotificationModel notif) async {
    await _firebaseService.showLocalNotification(
      title: notif.title,
      body: notif.body,
    );
  }

  void _addNotification(NotificationModel notif) {
    _notifications.insert(0, notif);
    _unreadCount++;
    _saveNotifications();
    notifyListeners();
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index].isRead = true;
      _unreadCount--;
      _saveNotifications();
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (var n in _notifications) {
      n.isRead = true;
    }
    _unreadCount = 0;
    _saveNotifications();
    notifyListeners();
  }

  void removeNotification(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      if (!_notifications[index].isRead) _unreadCount--;
      _notifications.removeAt(index);
      _saveNotifications();
      notifyListeners();
    }
  }

  void clearAllNotifications() {
    _notifications.clear();
    _unreadCount = 0;
    _saveNotifications();
    notifyListeners();
  }

  void _saveNotifications() {
    List<String> data = _notifications.map((n) => jsonEncode(n.toJson())).toList();
    _prefs.saveString('saved_notifications', jsonEncode(data));
  }

  void _loadNotifications() {
    String saved = _prefs.getString('saved_notifications');
    if (saved.isNotEmpty) {
      try {
        List<dynamic> decoded = jsonDecode(saved);
        _notifications = decoded
            .map((item) => NotificationModel.fromJson(jsonDecode(item)))
            .toList();
        _unreadCount = _notifications.where((n) => !n.isRead).length;
        notifyListeners();
      } catch (e) {
        _notifications = [];
      }
    }
  }
}
