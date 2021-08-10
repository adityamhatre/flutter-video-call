import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class MainVideo extends StatelessWidget {
  late final RTCVideoRenderer renderer;

  MainVideo({required RTCVideoRenderer renderer}) {
    this.renderer = renderer;
  }

  @override
  Widget build(BuildContext context) {
    return RTCVideoView(
      renderer,
      mirror: true,
      objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
    );
  }
}
