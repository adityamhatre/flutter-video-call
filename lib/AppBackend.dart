import 'package:http/http.dart' as http;
import 'package:video_call/FCMHandler.dart';

class AppBackend {
  static void delete(String roomId) async {
    var url = Uri.parse('${FCMHandler.server}/deleteRoom');
    http.delete(url, body: {'roomId': roomId});
  }
}
