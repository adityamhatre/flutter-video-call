import 'package:firebase_messaging/firebase_messaging.dart';

class FCMHandler {
  static Future<void> messageHandler(RemoteMessage message) async {
    print('Message: ${message.data}');
  }
}
