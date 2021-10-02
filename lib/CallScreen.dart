import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/Signalling.dart';
import 'package:flutter_app/secondaryVideo.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

import 'MyAppBar.dart';
import 'mainVideo.dart';

class CallScreen extends StatefulWidget {
  late final title;
  late final String roomId;
  late final String? fcmToken;


  CallScreen({required String title, required String roomId, required String? fcmToken}) {
    this.title = title;
    this.roomId = roomId;
    this.fcmToken = fcmToken;
  }

  @override
  State<StatefulWidget> createState() {
    return CallScreenState(title: this.title, roomId: this.roomId, fcmToken: this.fcmToken);
  }
}

class CallScreenState extends State<CallScreen> {
  late final String title;
  late String roomId;
  late String? fcmToken;
  late final Signalling signalling;
  late final RTCVideoRenderer localRenderer;
  late final RTCVideoRenderer remoteRenderer;

  CallScreenState({required String title, required String roomId, required String? fcmToken}) {
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
    getUserMedia().then((value) {
      if (roomId.isNotEmpty) {
        if (value[0]) {
          signalling.joinRoom(roomId, value[1]);
        }
      } else {
        signalling.createRoom(value[1]).then((value) {
          print('Sending req');
          var url = Uri.parse('http://192.168.1.197:3000/call');
          var response = http.post(url, body: {'roomId': value, 'fcmToken': fcmToken});
          response.then((value) => print("value: ${value.body}"), onError: (error) {
            print('error: $error');
          });
        });
      }
    });

    signalling.onAddRemoteStream = (MediaStream stream) {
      setState(() {
        if (!kIsWeb) {
          stream.getTracks().forEach((element) {
            if (element.kind == "audio") element.enableSpeakerphone(true);
          });
        }
        remoteRenderer.srcObject = stream;
      });
    };

    signalling.onEndCall = () {
      if (mounted) Navigator.of(context).pop();
    };
  }

  @override
  void dispose() {
    super.dispose();
    localRenderer.dispose();
    remoteRenderer.dispose();
    signalling.endCall();
  }

  Future<List<dynamic>> getUserMedia() async {
    final Map<String, dynamic> constraints = {
      "audio": true,
      "video": {"facingMode": "user"}
    };
    if (kIsWeb ||
        (await Permission.camera.request().isGranted &&
            await Permission.microphone.request().isGranted)) {
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
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return Scaffold(
      appBar: appBar,
      body: Stack(
        children: [
          MainVideo(renderer: this.localRenderer),
          SecondaryVideo(
            appBarHeight: appBarHeight,
            statusBarHeight: statusBarHeight,
            renderer: this.remoteRenderer,
          ),
          Align(
            child: FractionallySizedBox(
              heightFactor: 0.1,
              widthFactor: 1,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
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
