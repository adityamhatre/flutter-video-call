import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

typedef RecipientIceCandidateCallback = void Function(
    RTCIceCandidate rtcIceCandidate);
typedef CallAnswerCallback = void Function(
    RTCSessionDescription rtcSessionDescription);

class FireStoreCallService {
  late String roomId;
  late dynamic offer;
  late dynamic answer;
  late DocumentReference roomRef;
  late CollectionReference callerIceCandidates;
  late CollectionReference recipientIceCandidates;

  late RecipientIceCandidateCallback onRecipientIceCandidates;
  late CallAnswerCallback onCallAnswer;

  String createOrJoinRoom([String? roomId]) {
    if (roomId != null) {
      roomRef = FirebaseFirestore.instance.collection("rooms").doc(roomId);
    } else {
      roomRef = FirebaseFirestore.instance.collection("rooms").doc();
    }

    this.callerIceCandidates = roomRef.collection("callerIceCandidates");
    this.recipientIceCandidates = roomRef.collection("recipientIceCandidates");

    this.roomId = roomRef.id;
    Clipboard.setData(ClipboardData(text: this.roomId));
    return this.roomId;
  }

  void addCallerIceCandidates(map) {
    callerIceCandidates.add(map);
  }

  Future setOffer(RTCSessionDescription offer) {
    return roomRef.set(
        Map.of({"offer": offer.toMap()}), SetOptions(merge: true));
  }

  void listenForRecipientIceCandidates() {
    roomRef.collection("recipientIceCandidates").snapshots().listen((event) {
      event.docChanges.forEach((DocumentChange element) {
        if (element.type == DocumentChangeType.added) {
          dynamic object = element.doc.data()!;
          onRecipientIceCandidates(RTCIceCandidate(
              object['candidate'], object['sdpMid'], object['sdpMLineIndex']));
        }
      });
    });
  }

  void listenForCallAnswer() {
    roomRef.snapshots().listen((dynamic event) {
      var object = event.data();
      if (object == null) return;
      if (object['answer'] != null) {
        var rtcSessionDescription = RTCSessionDescription(
            object['answer']['sdp'], object['answer']['type']);
        onCallAnswer(rtcSessionDescription);
      }
    });
  }

  void addRecipientIceCandidates(map) {
    recipientIceCandidates.add(map);
  }

  Future<RTCSessionDescription> getRemoteOffer() async {
    final room = await roomRef.get();
    final offer = (room.data()! as dynamic)["offer"];
    return RTCSessionDescription(offer["sdp"], offer["type"]);
  }

  void setAnswer(RTCSessionDescription answer) {
    roomRef.set(Map.of({"answer": answer.toMap()}), SetOptions(merge: true));
  }

  void endCall() {
    callerIceCandidates.get().then((value) => value.docs.forEach((element) {
          element.reference.delete();
        }));

    recipientIceCandidates.get().then((value) => value.docs.forEach((element) {
          element.reference.delete();
        }));

    FirebaseFirestore.instance.collection("rooms").doc(roomId).delete();
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> getUsers() {
    return FirebaseFirestore.instance.collection("users").orderBy("name").get();
  }
}
