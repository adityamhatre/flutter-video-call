import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_call/CallScreen.dart';
import 'package:video_call/FCMHandler.dart';
import 'package:video_call/MyAppBar.dart';

class AnswerRejectScreen extends StatelessWidget {
  late final String roomId;
  late final audioCache;
  final audioPlayer = AudioPlayer();

  AnswerRejectScreen({required this.roomId}) {
    audioCache = new AudioCache(fixedPlayer: audioPlayer);
    audioCache.play('audio/ring.wav');
  }

  void answer() {
    audioPlayer.stop();
    var route = MaterialPageRoute(
        builder: (context) =>
            CallScreen(title: "Call screen", roomId: roomId, fcmToken: ''));

    FCMHandler.navigatorKey.currentState!.push(route);
  }

  void reject() {
    audioPlayer.stop();
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;
    print(args);

    return Scaffold(
      appBar: MyAppBar(
        title: Text("Answer or Reject"),
      ),
      body: Column(
        children: [
          Expanded(
            child: new Container(
              child: new Material(
                child: new InkWell(
                  onTap: () {
                    reject();
                  },
                  child: new Container(
                    child: Center(
                      child: Text(
                        "Reject",
                        style: TextStyle(color: Colors.white, fontSize: 48),
                      ),
                    ),
                  ),
                ),
                color: Colors.transparent,
              ),
              color: Colors.red,
            ),
          ),
          Expanded(
            child: new Container(
              child: new Material(
                child: new InkWell(
                  onTap: () {
                    answer();
                  },
                  child: new Container(
                    child: Center(
                      child: Text(
                        "Answer",
                        style: TextStyle(color: Colors.white, fontSize: 48),
                      ),
                    ),
                  ),
                ),
                color: Colors.transparent,
              ),
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
