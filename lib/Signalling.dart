import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:video_call/AppBackend.dart';
import 'package:video_call/FirestoreCallService.dart';

typedef void OnAddRemoteStream(MediaStream stream);
typedef void OnEndCall();

class Signalling {
  final config = Map.of({
    "iceServers": [
      {
        "urls": "turn:numb.viagenie.ca",
        "credential": "******",
        "username": "aditya.video.call@gmail.com"
      },
      {
        "urls": [
          "stun:stun1.l.google.com:19302",
          "stun:stun2.l.google.com:19302"
        ]
      }
    ]
  });

  late OnAddRemoteStream onAddRemoteStream;
  late OnEndCall onEndCall;

  final FireStoreCallService firestoreCallService = FireStoreCallService();
  late RTCPeerConnection peerConnection;
  var callDisconnected = false;

  addLocalTracks(localStream) {
    localStream.getTracks().forEach((track) {
      peerConnection.addTrack(track, localStream);
    });
  }

  listenForRemoteStream() {
    peerConnection.onTrack = (RTCTrackEvent event) {
      onAddRemoteStream(event.streams[0]);
    };
  }

  listenForEndCall() {
    peerConnection.onIceConnectionState = (RTCIceConnectionState state) {
      if (state == RTCIceConnectionState.RTCIceConnectionStateDisconnected) {
        onEndCall();
      }
    };
  }

  Future<String> createRoom(localStream) async {
    peerConnection = await createPeerConnection(config);
    var roomId = firestoreCallService.createOrJoinRoom();

    addLocalTracks(localStream);
    listenForRemoteStream();
    peerConnection.onIceCandidate = (candidate) {
      if (callDisconnected) return;
      firestoreCallService.addCallerIceCandidates(candidate.toMap());
    };

    var offer = await peerConnection.createOffer();
    peerConnection.setLocalDescription(offer);

    await firestoreCallService.setOffer(offer);
    firestoreCallService.onRecipientIceCandidates =
        (RTCIceCandidate rtcIceCandidate) {
      peerConnection.addCandidate(rtcIceCandidate);
    };
    firestoreCallService.onCallAnswer =
        (RTCSessionDescription rtcSessionDescription) {
      peerConnection.setRemoteDescription(rtcSessionDescription);
    };

    firestoreCallService.listenForRecipientIceCandidates();
    firestoreCallService.listenForCallAnswer();
    listenForEndCall();
    return roomId;
  }

  joinRoom(roomId, localStream) async {
    firestoreCallService.createOrJoinRoom(roomId);

    peerConnection = await createPeerConnection(config);

    addLocalTracks(localStream);
    listenForRemoteStream();
    peerConnection.onIceCandidate = (candidate) {
      if (callDisconnected) return;
      firestoreCallService.addRecipientIceCandidates(candidate.toMap());
    };

    var remoteDescriptor = await firestoreCallService.getRemoteOffer();
    peerConnection.setRemoteDescription(remoteDescriptor);
    var answer = await peerConnection.createAnswer();
    peerConnection.setLocalDescription(answer);
    firestoreCallService.setAnswer(answer);
    firestoreCallService.callerIceCandidates
        .get()
        .then((value) => value.docs.forEach((element) {
              dynamic doc = element.data();
              peerConnection.addCandidate(RTCIceCandidate(
                  doc['candidate'], doc['sdpMid'], doc['sdpMLineIndex']));
            }));
    listenForEndCall();
  }

  endCall(String roomId) {
    if (callDisconnected) return;
    callDisconnected = true;
    peerConnection.close();
    peerConnection.dispose();
    AppBackend.delete(roomId);
  }
}
