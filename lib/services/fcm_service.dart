import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initializeFCM() async {
    try {
      if (kIsWeb) return; // Optional FCM web handling

      // Request Push Notification Permission
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Subscribe to broadcast notification topics
        await _messaging.subscribeToTopic('all_pilgrims');
        await _messaging.subscribeToTopic('hajj_updates');

        // Handle foreground notifications
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          if (message.notification != null) {
            debugPrint('FCM Notification: ${message.notification?.title} - ${message.notification?.body}');
          }
        });
      }
    } catch (e) {
      debugPrint('FCM Initialization Deferred: $e');
    }
  }
}
