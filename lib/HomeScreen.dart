import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app/Contact.dart';
import 'package:flutter_app/FCMHandler.dart';
import 'package:flutter_app/FirestoreCallService.dart';
import 'package:flutter_app/MyAppBar.dart';

import 'CallScreen.dart';

class HomeScreen extends StatefulWidget {
  final String userId;

  HomeScreen(this.userId);

  @override
  State<StatefulWidget> createState() {
    return new HomeScreenState(this.userId);
  }
}

class HomeScreenState extends State<HomeScreen> {
  final TextEditingController textEditingController =
      TextEditingController(text: '');

  final FireStoreCallService fireStoreCallService = FireStoreCallService();

  final String loggedInUserId;

  HomeScreenState(this.loggedInUserId);

  void startCall(dynamic user, BuildContext context) async {
    print(user);

    var route = MaterialPageRoute(
        builder: (context) => CallScreen(
            title: "Call screen", roomId: textEditingController.value.text, fcmToken: user['fcmToken']));
    Navigator.push(context, route);
  }

  @override
  void initState() {
    super.initState();
    print('registering onmessage listener');
    FirebaseMessaging.onMessage.listen(FCMHandler.messageHandler);
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
