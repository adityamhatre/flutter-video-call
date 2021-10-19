import 'dart:io';
import 'dart:isolate';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:system_alert_window/system_alert_window.dart';
import 'package:video_call/AnswerRejectScreen.dart';
import 'package:video_call/Contact.dart';
import 'package:video_call/FCMHandler.dart';
import 'package:video_call/FirestoreCallService.dart';
import 'package:video_call/IsolateManager.dart';
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

class HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final FireStoreCallService fireStoreCallService = FireStoreCallService();

  final String loggedInUserId;
  String roomId = '';
  int flag = 0;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    setState(() {
      flag = flag == 0 ? 1 : 0;
    });
  }

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
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    print('registering onmessage listener');
    FirebaseMessaging.onMessage.listen(FCMHandler.messageHandler);
/*    AwesomeNotifications().actionStream.listen((receivedNotification) {
      print(receivedNotification.toMap().toString());
      if (receivedNotification.buttonKeyPressed == 'reject') {
        print('REJECTED');
        return;
      }

      var route = MaterialPageRoute(
          builder: (context) => AnswerRejectScreen(
                roomId: receivedNotification.payload!['roomId']!,
              ));
      FCMHandler.navigatorKey.currentState!.push(route);
    });*/
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (roomId.isNotEmpty) {
        startCall({}, context);
      }
      _initPlatformState();
      _requestPermissions();
      SystemAlertWindow.registerOnClickListener(callBackFunction);
    });
    FirebaseFirestore.instance
        .collection("users")
        .snapshots()
        .listen((querySnapshot) {
      print('Users collection changed');
      setState(() {
        flag = flag == 0 ? 1 : 0;
      });
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> _initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = (await SystemAlertWindow.platformVersion)!;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {});
  }

  void _requestPermissions() async {
    if (await Permission.systemAlertWindow.isGranted) {
      ReceivePort _port = ReceivePort();
      IsolateManager.registerPortWithName(_port.sendPort);
      _port.listen((dynamic callBackData) {
        FCMHandler.navigatorKey.currentState!.pop();

        print(callBackData);
        String tag = callBackData[0];
        print('received tag: $tag');

        var route = MaterialPageRoute(
            builder: (context) => AnswerRejectScreen(
              roomId: tag,
            ));
        FCMHandler.navigatorKey.currentState!.push(route);
      });
      return;
    }

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Please grant permission"),
              content: ElevatedButton(
                onPressed: () async {
                  print('clicked');
                  Navigator.of(context).pop();
                  Permission.systemAlertWindow.request();
                },
                child: Text(
                    "Search for \"Video Call\" in the list after clicking this button"),
              ),
            ));
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

void callBack(String tag) {
  print('tag');
}

bool callBackFunction(String tag) {
  print("Got tag " + tag);
  SystemAlertWindow.closeSystemWindow();

  SendPort port = IsolateManager.lookupPortByName();
  port.send([tag]);

  return true;
}
