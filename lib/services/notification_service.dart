import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialize notification service
  Future<void> initialize() async {
    try {
      // Request permission
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        throw Exception('User declined or has not accepted permission');
      }

      // Initialize local notifications
      const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(initSettings);

      // Configure FCM
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

      // Update FCM token
      await _updateFcmToken();
    } catch (e) {
      throw Exception('Failed to initialize notification service: $e');
    }
  }

  // Update FCM token
  Future<void> _updateFcmToken() async {
    try {
      final userId = _auth.currentUser?.uid;

      if (userId == null) return;

      final token = await _messaging.getToken();

      if (token != null) {
        await _firestore.collection('users').doc(userId).update({
          'fcmToken': token,
        });
      }
    } catch (e) {
      throw Exception('Failed to update FCM token: $e');
    }
  }

  // Handle foreground message
  void _handleForegroundMessage(RemoteMessage message) {
    _showLocalNotification(message);
  }

  // Handle background message
  void _handleBackgroundMessage(RemoteMessage message) {
    // Handle navigation based on notification data
    print('Handling background message: ${message.data}');
  }

  // Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      final notification = message.notification;

      if (notification == null) return;

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'karrot_channel',
        'Karrot Notifications',
        importance: Importance.high,
        priority: Priority.high,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        details,
        payload: message.data.toString(),
      );
    } catch (e) {
      throw Exception('Failed to show local notification: $e');
    }
  }

  // Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
    } catch (e) {
      throw Exception('Failed to subscribe to topic: $e');
    }
  }

  // Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
    } catch (e) {
      throw Exception('Failed to unsubscribe from topic: $e');
    }
  }
}
