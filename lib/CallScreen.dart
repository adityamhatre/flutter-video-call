import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_call/FCMHandler.dart';
import 'package:video_call/Signalling.dart';
import 'package:video_call/secondaryVideo.dart';

import 'MyAppBar.dart';
import 'mainVideo.dart';

class CallScreen extends StatefulWidget {
  late final title;
  late final String roomId;
  late final String? fcmToken;

  CallScreen({required String title,
    required String roomId,
    required String? fcmToken}) {
    this.title = title;
    this.roomId = roomId;
    this.fcmToken = fcmToken;
  }

  @override
  State<StatefulWidget> createState() {
    return CallScreenState(
        title: this.title, roomId: this.roomId, fcmToken: this.fcmToken);
  }
}

class CallScreenState extends State<CallScreen> {
  late final String title;
  late String roomId;
  late String? fcmToken;
  late final Signalling signalling;
  late final RTCVideoRenderer localRenderer;
  late final RTCVideoRenderer remoteRenderer;
  var callConnected = false;
  var isIncomingCallState = false;
  Timer? timer;

  CallScreenState({required String title,
    required String roomId,
    required String? fcmToken}) {
    this.title = title;
    this.signalling = Signalling();
    this.localRenderer = RTCVideoRenderer();
    this.remoteRenderer = RTCVideoRenderer();
    this.roomId = roomId.trim();
    this.fcmToken = fcmToken;
  }

  @override
  void initState() {
    super.initState();
    localRenderer.initialize();
    remoteRenderer.initialize();
    startTimer(60);

    getUserMedia().then((value) {
      if (roomId.isNotEmpty) {
        if (value[0]) {
          setState(() {
            isIncomingCallState = true;
          });
          signalling.joinRoom(roomId, value[1]);
        }
      } else {
        signalling.createRoom(value[1]).then((value) async {
          var prefs = await SharedPreferences.getInstance();
          var username = prefs.getString("username");
          var url = Uri.parse('${FCMHandler.server}/call');
          var response = http.post(url, body: {
            'roomId': value,
            'fcmToken': fcmToken,
            'caller': username
          });
          setState(() {
            this.roomId = value;
          });
          response.then((value) => print("value: ${value.body}"),
              onError: (error) {
                print('error: $error');
              });
        });
      }
    });

    signalling.onAddRemoteStream = (MediaStream stream) {
      setState(() {
        remoteRenderer.srcObject = stream;
        callConnected = true;
      });
    };

    signalling.onEndCall = () {
      endCall();
    };
  }

  void endCall() async {
    if (!mounted) return;

    if (timer != null) {
      timer!.cancel();
    }

    signalling.endCall(roomId);
    await clearSharedPrefs();

    if (isIncomingCallState) {
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    } else {
      FCMHandler.navigatorKey.currentState!.pop();
    }
  }

  Future clearSharedPrefs() async {
    var prefs = await SharedPreferences.getInstance();

    var userId = prefs.getString("userId")!;
    var username = prefs.getString("username")!;
    await prefs.clear();
    await prefs.setString("userId", userId);
    await prefs.setString("username", username);
  }

  @override
  void dispose() {
    super.dispose();
    localRenderer.dispose();
    remoteRenderer.dispose();
  }

  void startTimer(int countDown) {
    print('starting timer');
    timer = Timer(new Duration(seconds: countDown), () {
      if (callConnected) return;
      print('timer tick');
      endCall();
    });
  }

  Future<List<dynamic>> getUserMedia() async {
    final Map<String, dynamic> constraints = {
      "audio": true,
      "video": {"facingMode": "user"}
    };
    if (kIsWeb ||
        (await Permission.camera
            .request()
            .isGranted &&
            await Permission.microphone
                .request()
                .isGranted)) {
      var stream = await navigator.mediaDevices.getUserMedia(constraints);
      var remote = await createLocalMediaStream("remoteRenderer");
      setState(() {
        localRenderer.srcObject = stream;
        remoteRenderer.srcObject = remote;
      });
      return [true, stream];
    }
    return [false];
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar = MyAppBar(
      title: Text(this.title),
    );
    final appBarHeight = appBar.preferredSize.height;
    final statusBarHeight = MediaQuery
        .of(context)
        .padding
        .top;
    return Scaffold(
      appBar: appBar,
      body: Stack(
        children: [
          MainVideo(
              callConnected: this.callConnected,
              renderer: this.callConnected
              ? this.remoteRenderer
                  : this.localRenderer),
          SecondaryVideo(
              appBarHeight: appBarHeight,
              statusBarHeight: statusBarHeight,
              renderer:
              this.callConnected ? this.localRenderer : this.remoteRenderer,
              callConnected: this.callConnected
          ),
          Align(
            child: FractionallySizedBox(
              heightFactor: 0.1,
              widthFactor: 1,
              child: ElevatedButton(
                onPressed: () {
                  endCall();
                },
                child: Text("Disconnect"),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                ),
              ),
            ),
            alignment: Alignment.bottomCenter,
          )
        ],
      ),
    );
  }
}
