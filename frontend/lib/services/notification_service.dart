import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'api_service.dart';

class NotificationService {
  static final _firebaseMessaging = FirebaseMessaging.instance;
  static final _localNotifications = FlutterLocalNotificationsPlugin();
  static final _apiService = ApiService();

  static Future<void> initialize() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    FirebaseMessaging.onMessage.listen(_showLocalNotification);
  }

  static void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'flowplan_channel',
          'FlowPlan Notifications',
          channelDescription: 'Notifications from FlowPlan AI',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  static Future<String?> getToken() => _firebaseMessaging.getToken();

  static Future<void> registerToken() async {
    final token = await getToken();
    if (token == null) return;
    try {
      await _apiService.post('/notifications/register', {'fcm_token': token});
    } catch (_) {}
  }
}
