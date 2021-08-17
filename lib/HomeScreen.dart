import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app/CallScreen.dart';
import 'package:flutter_app/Contact.dart';
import 'package:flutter_app/FirestoreCallService.dart';
import 'package:flutter_app/MyAppBar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatelessWidget {
  final TextEditingController textEditingController =
      TextEditingController(text: '');

  final FireStoreCallService fireStoreCallService = FireStoreCallService();

  final String loggedInUserId;

  HomeScreen(this.loggedInUserId);

  Future<Widget> buildPageAsync() async {
    return Future.microtask(() {
      return CallScreen(
          title: "Call screen", roomId: textEditingController.value.text);
    });
  }

  void startCall(BuildContext context) async {
    var page = await buildPageAsync();
    var route = MaterialPageRoute(builder: (context) => page);
    Navigator.push(context, route);
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
