import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class MainVideo extends StatelessWidget {
  late final RTCVideoRenderer renderer;
  late final callConnected;

  MainVideo({required RTCVideoRenderer renderer, required this.callConnected}) {
    this.renderer = renderer;
  }

  @override
  Widget build(BuildContext context) {
    return RTCVideoView(
      renderer,
      mirror: !callConnected,
      objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
    );
  }
}
