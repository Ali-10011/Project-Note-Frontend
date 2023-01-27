import 'dart:html';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project_note/model/Message.dart';
import 'package:project_note/globals/globals.dart';

class MessageProvider with ChangeNotifier {
  List<Message> messageslist = [];

  List<Message> get messages {
    return [...messageslist];
  }

  Future<void> uploadOfflineMessages() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString('messages') ?? '';

    if (data != '') {
      messageslist = json
          .decode(data)
          .map<Message>((message) => Message.fromJson(message))
          .toList();

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
              messageslist[messageindex].message =
                  jsonDecode['result']['message'];
              messageslist[messageindex].path = jsonDecode['result']['path'];
              messageslist[messageindex].isUploaded =
                  jsonDecode['result']['isUploaded'];
              messageslist[messageindex].username =
                  jsonDecode['result']['username'];
              notifyListeners();
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
      //notifyListeners();
      //dataLoad.saveMessages();
      notifyListeners();
    }
  }

  void saveMessages() async {
    //Save messages to mobile storage

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('messages',
        json.encode(messageslist)); //easy way to store dynamic objects
    notifyListeners();
  }

  Future<void> loadMessages() async {
    //Load Messages from mobile storage
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString('messages') ?? '';
    if (data != '') {
      //Converts the decoded json string to a 'Message' type Map.
      messageslist = json
          .decode(data)
          .map<Message>((message) => Message.fromJson(message))
          .toList();

      pageno = (messageslist.length / 15)
          .toInt(); //How many pages of messages were loaded
      newmessages = messageslist.length %
          15; //How many messages were loaded additional to the pages loaded
    } else if (connection == ConnectionStatus.wifi) {
      await getMessages();
      pageno++;
    }
    notifyListeners();
  }

  Future<void> getMessages() async {
    //Getting new messages from API
    final response = await http.get(Uri.parse('http://localhost:3000/home'));
    switch (response.statusCode) {
      case 200:
        messageslist = json
            .decode(response.body)
            .map<Message>((message) => Message.fromJson(message))
            .toList();
        break;
      case 404:
        throw ("Could not Fetch the resource");
      default:
        throw (response.statusCode.toString());
    }
  }

  Future<void> getMoreMessages() async {
    //This is used to load more messages due to scroll controller offset
    Map<String, String> queryparams = {
      'pageno': pageno.toString(),
      'skip': newmessages.toString()
    };
    var url = Uri.https('localhost:3000', '/api/', queryparams);
    final response = await http.get(Uri.parse(
      'http://localhost:3000/home?pageno=${pageno.toString()}&skip=${newmessages.toString()}&perpage=${LoadPerPage.toString()}',
    ));
/**/
    final data = json.decode(response.body) as List<dynamic>;
    if (data.isEmpty) {
      IsLastPage = true;
    }
    if (data.isNotEmpty) {
      switch (response.statusCode) {
        case 200:
          if (data.length < 15) {
            IsLastPage = true;
          } else {
            pageno++;
          }
          messageslist.addAll(json
              .decode(response.body)
              .map<Message>((message) => Message.fromJson(message))
              .toList());
          break;
        case 404:
          throw ("Could not Find the Resource");
        default:
          throw (response.statusCode.toString());
      }
    }
    notifyListeners();
  }
}
