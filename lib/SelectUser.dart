import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/CallScreen.dart';
import 'package:flutter_app/FCMHandler.dart';
import 'package:flutter_app/FirestoreCallService.dart';
import 'package:flutter_app/HomeScreen.dart';
import 'package:flutter_app/MyAppBar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';

class SelectUser extends StatefulWidget {
  @override
  SelectUserState createState() => SelectUserState();
}

class SelectUserState extends State<SelectUser> {
  late Tuple2 selectedUser;
  late Future<QuerySnapshot<Map<String, dynamic>>> getUsers;
  late SharedPreferences prefs;

  Future<void> saveTokenToDatabase(String token) async {
    print('Refreshing FCM token');
    var token = await FirebaseMessaging.instance.getToken();
    FirebaseFirestore.instance
        .collection('users')
        .doc(prefs.getString("userId"))
        .update({'fcmToken': token});
  }

  @override
  void initState() {
    super.initState();
    getUsers = FireStoreCallService.getUsers();
    getUsers.then((value) => selectedUser =
        Tuple2(value.docs.first.id, value.docs.first.get("name")));

    SharedPreferences.getInstance().then((value) {
      prefs = value;
      checkAlreadyLoggedIn();
    });

    AwesomeNotifications().actionStream.listen(
            (receivedNotification){
          var route = MaterialPageRoute(
              builder: (context) =>
                  CallScreen(title: "Call screen", roomId: receivedNotification.payload!['roomId']!, fcmToken: ''));
          FCMHandler.navigatorKey.currentState!.push(route);
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: Text("Select your name"),
      ),
      body: Container(
        child: FutureBuilder(
          future: getUsers,
          builder: (BuildContext context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Center(child: CircularProgressIndicator());
            }

            final users = (snapshot.data as QuerySnapshot)
                .docs
                .map((e) => DropdownMenuItem<Tuple2>(
                    onTap: () {},
                    child: Text(e.get("name")),
                    value: Tuple2(e.id, e.get("name"))))
                .toList();

            return Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  DropdownButton<Tuple2>(
                    items: users,
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() {
                        selectedUser = v;
                      });
                    },
                    value: selectedUser,
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        await prefs.setString("userId", selectedUser.item1);
                        await prefs.setString("username", selectedUser.item2);
                        checkAlreadyLoggedIn();
                      },
                      child: Text("Go"))
                ]));
          },
        ),
      ),
    );
  }

  void checkAlreadyLoggedIn() async {
    if (prefs.getString("userId") != null &&
        prefs.getString("userId")!.isNotEmpty) {

      var token = await FirebaseMessaging.instance.getToken();
      await saveTokenToDatabase(token.toString());
      FirebaseMessaging.instance.onTokenRefresh.listen(saveTokenToDatabase);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext context) =>
              HomeScreen(prefs.getString("userId")!.toString()),
        ),
      );
    }
  }
}
