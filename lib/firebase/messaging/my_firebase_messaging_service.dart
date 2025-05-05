import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class MyFirebaseMessagingService {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // ✅ Initialize Local Notifications
  static Future<void> initLocalNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        print("🔔 Notification Tapped: ${response.payload}");
        // You can navigate to a specific screen or perform an action here
        _onNotificationTap(response);
      },
    );
  }

  // Handle notification tap (for navigation or action)
  static void _onNotificationTap(NotificationResponse response) {
    // Example: You can navigate to a specific screen
    // Navigator.pushNamed(context, '/specific_screen');
    print(
        "Navigating to specific screen based on payload: ${response.payload}");
  }

  // ✅ Handle Background Notifications
  static Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print("📩 Background Notification: ${message.notification?.title}");
    await _showNotification(message);
  }

  // ✅ Show Local Notifications
  static Future<void> _showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel', // Channel ID
      'High Importance Notifications', // Channel Name
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      // Add channel-specific features here
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title ?? 'No Title',
      message.notification?.body ?? 'No Body',
      platformChannelSpecifics,
      payload: message.data['route'], // Use payload to pass custom data
    );
  }

  // ✅ Foreground Notification Handler
  static void setupForegroundNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("📲 Foreground Notification: ${message.notification?.title}");
      _showNotification(message);
    });
  }

  // ✅ Setup Notification Channel for Android (Required for Android 8.0+)
  static Future<void> setupNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // Channel ID
      'High Importance Notifications', // Channel Name
      description: 'This channel is used for high priority notifications.',
      importance: Importance.high,
      playSound: true,
    );

    // Create the channel
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }
}
