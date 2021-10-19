import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:system_alert_window/models/system_window_decoration.dart';
import 'package:system_alert_window/models/system_window_header.dart';
import 'package:system_alert_window/models/system_window_padding.dart';
import 'package:system_alert_window/models/system_window_text.dart';
import 'package:system_alert_window/system_alert_window.dart';
import 'package:video_call/AnswerRejectScreen.dart';

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
      print('incoming call with room=$roomId}');

      /*AwesomeNotifications().createNotification(
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
              payload: {'roomId': roomId}));*/

      show(username, roomId);
    }
  }

  static void show(String username, String roomId) {
    SystemWindowHeader header = SystemWindowHeader(
        title: SystemWindowText(
            text: "Incoming Call from $username",
            fontSize: 10,
            textColor: Colors.black45),
        padding: SystemWindowPadding.setSymmetricPadding(12, 12),
        decoration: SystemWindowDecoration(startColor: Colors.black));

    SystemWindowFooter footer = SystemWindowFooter(
        buttons: [
          SystemWindowButton(
            text: SystemWindowText(
                text: "Accept", fontSize: 30, textColor: Colors.white, fontWeight: FontWeight.BOLD),
            tag: "accept-$roomId",
            //useful to identify button click event
            padding:
                SystemWindowPadding(left: 10, right: 10, bottom: 10, top: 10),
            width: 0,
            height: 400,
            decoration: SystemWindowDecoration(
                startColor: Colors.green,
                endColor: Colors.green,
                borderWidth: 0,
                borderRadius: 30.0),
          ),
          SystemWindowButton(
            text: SystemWindowText(
                text: "Reject", fontSize: 30, textColor: Colors.white, fontWeight: FontWeight.BOLD),
            tag: "reject",
            width: 0,
            padding:
                SystemWindowPadding(left: 10, right: 10, bottom: 10, top: 10),
            height: 400,
            decoration: SystemWindowDecoration(
                startColor: Colors.red,
                endColor: Colors.red,
                borderWidth: 0,
                borderRadius: 30.0),
          )
        ],
        padding: SystemWindowPadding(left: 16, right: 16, bottom: 12),
        decoration: SystemWindowDecoration(startColor: Colors.black),
        buttonsPosition: ButtonPosition.CENTER);

    SystemWindowBody body = SystemWindowBody(
      rows: [
        EachRow(
          columns: [
            EachColumn(
              text: SystemWindowText(
                  text: "$username calling", fontSize: 30, textColor: Colors.white, fontWeight: FontWeight.BOLD),
            ),
          ],
          gravity: ContentGravity.CENTER,
        ),
      ],
      decoration: SystemWindowDecoration(startColor: Colors.black),
      padding: SystemWindowPadding(left: 16, right: 16, bottom: 12, top: 12),
    );


    SystemAlertWindow.showSystemWindow(
        height: 230,
        header: header,
        body: body,
        footer: footer,
        margin: SystemWindowMargin(left: 8, right: 8, top: 100, bottom: 0),
        gravity: SystemWindowGravity.TOP,
        notificationTitle: "Incoming Call",
        notificationBody: "from $username",
        prefMode: SystemWindowPrefMode.OVERLAY);
    //Using SystemWindowPrefMode.DEFAULT uses Overlay window till Android 10 and bubble in Android 11
    //Using SystemWindowPrefMode.OVERLAY forces overlay window instead of bubble in Android 11.
    //Using SystemWindowPrefMode.BUBBLE forces Bubble instead of overlay window in Android 10 & above
  }

}
