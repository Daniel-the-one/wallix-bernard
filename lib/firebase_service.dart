
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'data/shared_prefs_helper.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final SharedPrefsHelper _prefs = SharedPrefsHelper();
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  String? get fcmToken => _fcmToken ?? _prefs.getString('fcm_token');

  Future<void> init() async {
    try {
      await _initializeLocalNotifications();
      await _initializeMessaging();
    } catch (e) {
      debugPrint('FirebaseService init error: $e');
    }
  }

  Future<void> _initializeMessaging() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        String? token = await messaging.getToken();
        if (token != null) {
          debugPrint('FCM Token: $token');
          await _saveToken(token);
        }

        messaging.onTokenRefresh.listen((String newToken) async {
          debugPrint('FCM Token refreshed: $newToken');
          await _saveToken(newToken);
        });
      }

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _handleMessage(message);
      });
    } catch (e) {
      debugPrint('Firebase Messaging error: $e');
    }
  }

  Future<void> _saveToken(String token) async {
    _fcmToken = token;
    await _prefs.saveString('fcm_token', token);
  }

  Future<String?> getToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        debugPrint('FCM Token: $token');
        await _saveToken(token);
      }
      return token;
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return _prefs.getString('fcm_token');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
      );

      await _localNotificationsPlugin.initialize(
        settings: initializationSettings,
      );

      final androidImplementation = _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        const AndroidNotificationChannel channel = AndroidNotificationChannel(
          'wallix_channel',
          'Notifications Wallix',
          description: 'Canal de notifications Wallix Agent',
          importance: Importance.max,
        );
        await androidImplementation.createNotificationChannel(channel);
      }
    } catch (e) {
      debugPrint('Local notifications error: $e');
    }
  }

  void _handleMessage(RemoteMessage message) {
    if (message.notification != null) {
      showLocalNotification(
        title: message.notification!.title ?? 'Wallix Agent',
        body: message.notification!.body ?? '',
        payload: message.data.toString(),
      );
    }
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'wallix_channel',
        'Notifications Wallix',
        importance: Importance.max,
        priority: Priority.high,
      );

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await _localNotificationsPlugin.show(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: title,
        body: body,
        notificationDetails: platformChannelSpecifics,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Error displaying local notification: $e');
    }
  }
}
