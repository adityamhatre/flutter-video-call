import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:video_call/FCMHandler.dart';
import 'package:video_call/MyAppBar.dart';
import 'package:video_call/SelectUser.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); //all widgets are rendered here
  AwesomeNotifications().initialize(
      // set the icon to null if you want to use the default app icon
      'resource://mipmap/launcher_icon',
      [
        NotificationChannel(
            importance: NotificationImportance.Max,
            defaultRingtoneType: DefaultRingtoneType.Ringtone,
            channelKey: 'incoming_call',
            channelName: 'Incoming call',
            channelDescription: 'Notification channel for incoming calls',
            defaultColor: Color(0xFF9D50DD),
            playSound: true,
            locked: true,
            soundSource: 'resource://raw/res_ring',
            enableVibration: true,
            ledColor: Colors.white)
      ]);
  AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    if (!isAllowed) {
      // Insert here your friendly dialog box before call the request method
      // This is very important to not harm the user experience
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
  });

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        FirebaseMessaging.onBackgroundMessage(FCMHandler.messageHandler);
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            navigatorKey: FCMHandler.navigatorKey,
            title: 'Flutter Demo',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: SelectUser(),
          );
        } else {
          return MaterialApp(
              title: 'Flutter Demo',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                primarySwatch: Colors.blue,
              ),
              home: Scaffold(
                appBar: MyAppBar(
                  title: Text("Loading..."),
                ),
                body: Center(
                  child: Text("Loading..."),
                ),
              ));
        }
      },
    );
  }
}
