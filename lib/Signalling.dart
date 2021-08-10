import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

typedef void StreamStateCallback(MediaStream stream);

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

  late RTCPeerConnection peerConnection;
  late MediaStream localStream;
  late MediaStream remoteStream;
  bool remoteStreamReceived = false;

  late StreamStateCallback onAddRemoteStream;

  createRoom(stream) async {
    localStream = stream;
    var roomRef = FirebaseFirestore.instance.collection("rooms").doc();
    var callerIceServers = roomRef.collection("callerIceServers");

    peerConnection = await createPeerConnection(config);

    localStream.getTracks().forEach((track) {
      peerConnection.addTrack(track, localStream);
    });

    peerConnection.onTrack = (RTCTrackEvent event) {
      onAddRemoteStream.call(event.streams[0]);
    };
    peerConnection.onIceCandidate = (candidate) {
      callerIceServers.add(candidate.toMap());
    };

    var offer = await peerConnection.createOffer();
    peerConnection.setLocalDescription(offer);
    roomRef.set(Map.of({"offer": offer.toMap()}), SetOptions(merge: true));
    print('roomid = ${roomRef.id}');

    roomRef.collection("recipientIceServers").snapshots().listen((event) {
      event.docChanges.forEach((element) {
        if (element.type == DocumentChangeType.added) {
          var object = element.doc.data()!;
          peerConnection.addCandidate(RTCIceCandidate(
              object['candidate'], object['sdpMid'], object['sdpMLineIndex']));
        }
      });
    });
    roomRef.snapshots().listen((event) {
      if (event.data()!['answer'] != null) {
        peerConnection.setRemoteDescription(RTCSessionDescription(
            event.data()!['answer']['sdp'], event.data()!['answer']['type']));
      }
    });
  }

  joinRoom(roomId, stream) async {
    localStream = stream;
    var roomRef = FirebaseFirestore.instance.collection("rooms").doc(roomId);
    var recipientIceServers = roomRef.collection("recipientIceServers");
    var callerIceServers = roomRef.collection("callerIceServers");

    peerConnection = await createPeerConnection(config);

    localStream.getTracks().forEach((track) {
      peerConnection.addTrack(track, localStream);
    });

    peerConnection.onIceCandidate = (candidate) {
      recipientIceServers.add(candidate.toMap());
    };

    peerConnection.onTrack = (RTCTrackEvent event) {
      onAddRemoteStream.call(event.streams[0]);
    };

    var room = await roomRef.get();
    var offer = room.data()!["offer"];
    var remoteDescriptor = RTCSessionDescription(offer["sdp"], offer["type"]);
    peerConnection.setRemoteDescription(remoteDescriptor);
    var answer = await peerConnection.createAnswer();
    peerConnection.setLocalDescription(answer);

    roomRef.set(Map.of({"answer": answer.toMap()}), SetOptions(merge: true));

    callerIceServers.get().then((value) => value.docs.forEach((element) {
          print(element.data());
          peerConnection.addCandidate(RTCIceCandidate(
              element.data()['candidate'],
              element.data()['sdpMid'],
              element.data()['sdpMLineIndex']));
        }));
  }

/*endCall() {
    if (aditya == null) return;
    peerConnection.close();
    var roomRef = FirebaseFirestore.instance.collection("rooms").doc(aditya);
    CollectionReference<Map<String, dynamic>> callerIceServers =
        roomRef.collection("callerIceServers");
    CollectionReference<Map<String, dynamic>> recipientIceServers =
        roomRef.collection("recipientIceServers");

    callerIceServers.get().then((value) => value.docs.forEach((element) {
          element.reference.delete();
        }));

    recipientIceServers.get().then((value) => value.docs.forEach((element) {
          element.reference.delete();
        }));

    FirebaseFirestore.instance.collection("rooms").doc(aditya).delete();
  }*/
}
