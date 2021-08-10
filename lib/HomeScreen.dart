import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app/CallScreen.dart';
import 'package:flutter_app/MyAppBar.dart';

class HomeScreen extends StatelessWidget {
  TextEditingController textEditingController = TextEditingController(text: '');

  void startCall(BuildContext context) async {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallScreen(
              title: "Call screen", roomId: textEditingController.value.text),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(appBarTitle: Text("Hello")),
      body: Container(
          child: Padding(
        padding: EdgeInsets.all(50),
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Flexible(
                child: TextFormField(
              controller: textEditingController,
            )),
            ElevatedButton(
              onPressed: () {
                startCall(context);
              },
              child: Text("Init call"),
            )
          ]),
        ),
      )),
    );
  }
}
