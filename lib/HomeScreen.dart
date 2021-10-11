import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:video_call/Contact.dart';
import 'package:video_call/FCMHandler.dart';
import 'package:video_call/FirestoreCallService.dart';
import 'package:video_call/MyAppBar.dart';

import 'CallScreen.dart';

class HomeScreen extends StatefulWidget {
  final String userId;
  final String? roomId;

  HomeScreen(this.userId, [this.roomId]);

  @override
  State<StatefulWidget> createState() {
    return new HomeScreenState(this.userId, roomId);
  }
}

class HomeScreenState extends State<HomeScreen> {
  final FireStoreCallService fireStoreCallService = FireStoreCallService();

  final String loggedInUserId;
  String roomId = '';

  HomeScreenState(this.loggedInUserId, [String? roomId]) {
    if (roomId != null) {
      this.roomId = roomId;
    }
  }

  void startCall(dynamic user, BuildContext context) async {
    print(user);
    print(context);

    var route = MaterialPageRoute(
        builder: (context) => CallScreen(
            title: "Call screen",
            roomId: this.roomId,
            fcmToken: user['fcmToken']));
    FCMHandler.navigatorKey.currentState!.push(route);
  }

  @override
  void initState() {
    super.initState();
    print('registering onmessage listener');
    FirebaseMessaging.onMessage.listen(FCMHandler.messageHandler);
    AwesomeNotifications().actionStream.listen((receivedNotification) {
      print(receivedNotification.toMap().toString());
      if (receivedNotification.buttonKeyPressed == 'reject') {
        print('REJECTED');
        return;
      }
      var route = MaterialPageRoute(
          builder: (context) => CallScreen(
              title: "Call screen",
              roomId: receivedNotification.payload!['roomId']!,
              fcmToken: ''));
      FCMHandler.navigatorKey.currentState!.push(route);
    });
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (roomId.isNotEmpty) {
        startCall({}, context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MyAppBar(title: Text("Hello")),
        body: Container(
            child: Center(
                child: Padding(
                    padding: EdgeInsets.all(10),
                    child: FutureBuilder(
                        future: FireStoreCallService.getUsers(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState !=
                              ConnectionState.done) {
                            return CircularProgressIndicator();
                          }

                          final activeUsers = [];
                          (snapshot.data as QuerySnapshot)
                              .docs
                              .forEach((element) {
                            final user = element.data() as Map<String, dynamic>;
                            if (element.id != loggedInUserId) {
                              activeUsers.add(user);
                            }
                          });
                          return Container(
                              child: GridView.count(
                            crossAxisCount: 2,
                            children: activeUsers
                                .map((e) => Contact(e, startCall))
                                .toList(),
                          ));
                        })))));
  }
}
