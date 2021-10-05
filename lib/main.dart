import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/FCMHandler.dart';
import 'package:flutter_app/MyAppBar.dart';
import 'package:flutter_app/SelectUser.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); //all widgets are rendered here
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
