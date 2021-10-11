import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FCMHandler {
  static late SharedPreferences prefs;
  static bool initDone = false;
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'mainNavigator');

  static final server =
      "https://aditya-video-calling-server.herokuapp.com"; //"""http://192.168.1.197:3000";

  static Future<void> messageHandler(RemoteMessage message) async {
    print('Message: ${message.data}');
    SharedPreferences.getInstance().then((value) {
      prefs = value;
      checkAlreadyLoggedIn(message.data['roomId'], message.data['username']);
    });
  }

  static void checkAlreadyLoggedIn(String roomId, String username) async {
    if (prefs.getString("userId") != null &&
        prefs.getString("userId")!.isNotEmpty) {
      print('joining call with room=$roomId}');
      //
      // var route = MaterialPageRoute(
      //     builder: (context) =>
      //         CallScreen(title: "Call screen", roomId: roomId, fcmToken: ''));
      // FCMHandler.navigatorKey.currentState!.push(route);

      AwesomeNotifications().createNotification(
          actionButtons: [
            NotificationActionButton(key: "answer", label: "Answer"),
            NotificationActionButton(
                key: "reject",
                label: "Reject",
                buttonType: ActionButtonType.KeepOnTop,
                autoCancel: true),
          ],
          content: NotificationContent(
              id: 10,
              channelKey: 'incoming_call',
              title: 'Incoming video call from $username',
              notificationLayout: NotificationLayout.Default,
              payload: {'roomId': roomId}));
    }
  }
}
