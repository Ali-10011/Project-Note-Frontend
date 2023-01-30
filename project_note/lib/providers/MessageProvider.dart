import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project_note/models/Message.dart';
import 'package:project_note/globals/globals.dart';
import 'package:uuid/uuid.dart';

class MessageProvider with ChangeNotifier {
  List<Message> messageslist = [];

  List<Message> get messages {
    return [...messageslist];
  }

  Future<void> uploadOfflineMessages() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString('messages') ?? '';
    if (data != '') {
      //Converts the decoded json string to a 'Message' type Map.
      messageslist = json
          .decode(data)
          .map<Message>((message) => Message.fromJson(message))
          .toList();
      messageslist
          .where((message) => (message.isUploaded == "false"))
          .forEach((offlineMessage) async {
        var response = await http.post(Uri.parse(API_URL), headers: {
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
              int messageindex = messageslist.indexOf(offlineMessage);
              messageslist[messageindex] =
                  Message.fromJson(jsonDecode['result']);

              saveMessages();
            }
            break;
          case 404:
            throw ("Cannot Find The Requested Resource");
          default:
            throw (response.statusCode.toString());
        }
      });
    } else if (connection == ConnectionStatus.wifi) {
      await getMessages();
    }
  }

  Future<void> sendMessage(String messageEntry) async {
   addOfflineMessage(messageEntry);
    var response = await http.post(Uri.parse(API_URL),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {'message': messageEntry, 'path': '', 'mediatype': 'text'});
    switch (response.statusCode) {
      case 200:
        {
          Map<dynamic, dynamic> jsonDecode = json.decode(response.body);
          messageslist[0] = Message.fromJson(jsonDecode['result']);
          saveMessages();
        }
        break;
      case 404:
        throw ("Cannot Find The Requested Resource");
      default:
        throw (response.statusCode.toString());

      //print(jsonDecode);
    }
  }

  void saveMessages() async {
    //Save messages to mobile storage

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('messages',
        json.encode(messageslist)); //easy way to store dynamic objects
    notifyListeners();
  }

  void addOfflineMessage(String messageText) {
    var uuid = const Uuid();
    var newMessageID = uuid.v1();
    messageslist.insert(
        0,
        Message(
            id: newMessageID.toString(),
            username:
                'Lucifer', //hardcoding it for now, will need to make it dynamic in the future
            datetime: DateTime.now().toString(),
            mediatype: 'text',
            message: messageText,
            path: '',
            isUploaded: 'false'));
    saveMessages();
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
    } else if (connection == ConnectionStatus.wifi) {
      await getMessages();
    }
    notifyListeners();
  }

  Future<void> getMessages() async {
    //Getting new messages from API
    final response = await http.get(Uri.parse(API_URL));
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

    final response = await http.get(Uri.parse(
      '$API_URL?skip=${messageslist.length.toString()}&perpage=${loadPerPage.toString()}',
    ));

    final data = json.decode(response.body) as List<dynamic>;
    if (data.isEmpty) {
      isLastPage = true;
    } else if (data.isNotEmpty) {
      switch (response.statusCode) {
        case 200:
          if (data.length < 15) {
            isLastPage = true;
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
