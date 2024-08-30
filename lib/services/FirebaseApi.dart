import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ippu/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';

  Future<void> handleBackgroundMessage(RemoteMessage message) async {
    // Process the notification payload here
    print('Body: ${message.notification!.body}');
    print('Payload: ${message.data}');
  }

  final firebaseMessaging = FirebaseMessaging.instance;

  const _androidChannel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications',
    importance: Importance.high,
  );

  final _localNotifications = FlutterLocalNotificationsPlugin();

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;

    navigatorKey.currentState!.pushNamed(
      '/myevents',
      arguments: message,
    );
  }

class FirebaseApi {

  Future initLocalNotifications() async {
    const iOS = DarwinInitializationSettings();
    const android = AndroidInitializationSettings('@drawable/ic_launcher');

    const settings = InitializationSettings(iOS: iOS, android: android);

    await _localNotifications.initialize(settings,
        onDidReceiveNotificationResponse: (payload) async {
      final message =
          RemoteMessage.fromMap(jsonDecode(payload.payload as String));
      handleMessage(message);
    });

    final platform = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(_androidChannel);
  }

  Future<void> initPushNotifications() async {
    
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);

    //handle onbackground message
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        if (message.notification!.title != null &&
            message.notification!.body != null) {
          final notificationData = message.data;
          final screen = notificationData['screen'];
          // Showing an alert dialog when a notification is received (Foreground state)
          showDialog(
            context: navigatorKey.currentContext!,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return WillPopScope(
                onWillPop: () async => false,
                child: AlertDialog(
                  title: Text(message.notification!.title!),
                  content: Text(message.notification!.body!),
                  actions: [
                    if (notificationData.containsKey('screen'))
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.of(context).pushNamed(screen);
                        },
                        child: const Text('Open Screen'),
                      ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Dismiss'),
                    ),
                  ],
                ),
              );
            },
          );
        }
      }
    });
  }

  Future<void> initNotifications() async {
    await firebaseMessaging.requestPermission();
    final fcmToken = await firebaseMessaging.getToken();

    //save the token to the shared preferences
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('fcmToken', fcmToken!);
    await initPushNotifications();
    initLocalNotifications();
  }
}
