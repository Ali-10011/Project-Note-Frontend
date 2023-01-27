import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:project_note/globals/globals.dart';
import 'package:project_note/model/Message.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> uploadOfflineMessages() async {
  final prefs = await SharedPreferences.getInstance();

  final data = prefs.getString('messages') ?? '';
  if (data != '') {
    //Converts the decoded json string to a 'Message' type Map.

    messageslist = json
        .decode(data)
        .map<Message>((message) => Message.fromJson(message))
        .toList();
  }
  messageslist
      .where((message) => (message.isUploaded == "false"))
      .forEach((offlineMessage) async {
    var response =
        await http.post(Uri.parse('http://localhost:3000/home'), headers: {
      "Content-Type": "application/x-www-form-urlencoded"
    }, body: {
      'message': offlineMessage.message,
      'path': offlineMessage.path,
      'mediatype': offlineMessage.mediatype
    });

    switch (response.statusCode) {
      case 200:
        {
          Map<dynamic, dynamic> jsonDecode = json.decode(response.body);
          //messageslist.where((message) {message.id == offlineMessage.id}).forEach((message){});
          int messageindex = messageslist.indexOf(offlineMessage);
          messageslist[messageindex].id = jsonDecode['result']['_id'];
          messageslist[messageindex].datetime =
              jsonDecode['result']['createdAt'];
          messageslist[messageindex].message = jsonDecode['result']['message'];
          messageslist[messageindex].path = jsonDecode['result']['path'];
          messageslist[messageindex].isUploaded =
              jsonDecode['result']['isUploaded'];
          messageslist[messageindex].username =
              jsonDecode['result']['username'];
          print(messageslist[messageindex].message);
          print(messageslist[messageindex].isUploaded);
        }
        break;
      case 404:
        throw ("Cannot Find The Requested Resource");
      default:
        throw (response.statusCode.toString());

      //print(jsonDecode);
    }
  });

  dataLoad.saveMessages();
}
