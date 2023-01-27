import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project_note/model/Message.dart';
import 'package:project_note/globals/globals.dart';

class MessageProvider with ChangeNotifier {
  List<Message> _messageslist = [];

  List<Message> get messages {
    return [..._messageslist];
  }

  Future<void> uploadOfflineMessages() async {
    final prefs = await SharedPreferences.getInstance();
    print("Insideeeee");
    final data = prefs.getString('messages') ?? '';
    if (data == '') {
      print("Bruhhhh");
    }
    if (data != '') {
      //Converts the decoded json string to a 'Message' type Map.
      print("Meow");

      print(data);
      _messageslist = json
          .decode(data)
          .map<Message>((message) => Message.fromJson(message))
          .toList();
    }

    _messageslist
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
            int messageindex = _messageslist.indexOf(offlineMessage);
            _messageslist[messageindex].id = jsonDecode['result']['_id'];
            _messageslist[messageindex].datetime =
                jsonDecode['result']['createdAt'];
            _messageslist[messageindex].message =
                jsonDecode['result']['message'];
            _messageslist[messageindex].path = jsonDecode['result']['path'];
            _messageslist[messageindex].isUploaded =
                jsonDecode['result']['isUploaded'];
            _messageslist[messageindex].username =
                jsonDecode['result']['username'];
            notifyListeners();
            print(_messageslist[messageindex].message);
            print(_messageslist[messageindex].isUploaded);
          }
          break;
        case 404:
          throw ("Cannot Find The Requested Resource");
        default:
          throw (response.statusCode.toString());

        //print(jsonDecode);
      }
    });
    //notifyListeners();
    //dataLoad.saveMessages();
    notifyListeners();
  }
}
