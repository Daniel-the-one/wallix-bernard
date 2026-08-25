
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_service.dart';

class FirebaseInitializer {
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      debugPrint('Firebase Core initialized successfully');
      await FirebaseService().init();
    } catch (e) {
      debugPrint('FirebaseInitializer error: $e');
    }
  }
}
