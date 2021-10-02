import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/HomeScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FCMHandler {
  static late BuildContext _context;
  static late SharedPreferences prefs;
  static bool initDone = false;

  static init({required BuildContext context}) {
    if(initDone) return;
    initDone = true;
    _context = context;
  }

  static Future<void> messageHandler(RemoteMessage message) async {
    print('Message: ${message.data}');
    SharedPreferences.getInstance().then((value) {
      prefs = value;
      checkAlreadyLoggedIn(message.data['roomId']);
    });
  }

  static void checkAlreadyLoggedIn(String roomId) async {
    if (prefs.getString("userId") != null &&
        prefs.getString("userId")!.isNotEmpty) {
      print('joining call with room=$roomId}');
      Navigator.of(_context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (BuildContext context) =>
              HomeScreen(prefs.getString("userId")!.toString(), roomId),
        ),
      );
    }
  }
}
