import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
// ignore: implementation_imports
import 'package:flutter_webrtc/src/rtc_video_renderer.dart';

class SecondaryVideo extends StatefulWidget {
  late final appBarHeight;
  late final statusBarHeight;
  late final renderer;

  SecondaryVideo(
      {required appBarHeight,
      required statusBarHeight,
      required RTCVideoRenderer renderer}) {
    this.appBarHeight = appBarHeight;
    this.statusBarHeight = statusBarHeight;
    this.renderer = renderer;
  }

  @override
  State<StatefulWidget> createState() {
    return SecondaryVideoState(appBarHeight, statusBarHeight, renderer);
  }
}

class SecondaryVideoState extends State<SecondaryVideo> {
  var x;
  var y;
  late final appbarHeight;
  late final statusBarHeight;
  late final renderer;

  SecondaryVideoState(appBarHeight, statusBarHeight, renderer) {
    this.statusBarHeight = statusBarHeight;
    this.appbarHeight = appBarHeight;
    this.renderer = renderer;
  }

  @override
  Widget build(BuildContext context) {
    final widget = SizedBox.fromSize(
        size: Size(200, 200),
        child: RTCVideoView(
          renderer,
          mirror: false,
          objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
        ));
    return Positioned(
        left: x,
        top: y,
        child: Draggable(
          feedback: widget,
          child: widget,
          childWhenDragging: Container(),
          onDragEnd: (details) {
            setState(() {
              x = details.offset.dx;
              y = details.offset.dy - this.appbarHeight - this.statusBarHeight;
              if (x < 0.0) x = 0.0;
              if (y < 0.0) y = 0.0;
            });
          },
        ));
  }
}
