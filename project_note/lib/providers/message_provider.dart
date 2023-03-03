import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project_note/models/message_model.dart';
import 'package:project_note/globals/globals.dart';
import 'package:uuid/uuid.dart';
import 'package:project_note/models/credentials_model.dart';

class MessageProvider with ChangeNotifier {
  List<Message> messageslist = [];
  List<String> deletedMessagesList = [];

  List<Message> get messages {
    return [...messageslist];
  }

  void deleteAllMessages() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove('deletedMessages');
    await preferences.remove('messages');
    messageslist.clear();
    deletedMessagesList.clear();
  }

  Future<void> uploadOfflineMessages() async {
    if (messageslist.isEmpty) {
      await loadMessages();
    }
    if (messageslist.isNotEmpty) {
      messageslist
          .where((message) => (message.isUploaded == "false"))
          .forEach((offlineMessage) async {
        if (offlineMessage.mediatype == 'text') {
          uploadText(offlineMessage);
        } else if (offlineMessage.mediatype == 'image') {
          uploadImage(offlineMessage);
        } else if (offlineMessage.mediatype == 'video') {
          uploadVideo(offlineMessage);
        }
      });
    } else if (connection == ConnectionStatus.wifi) {
      await getMessages();
    }
  }

  Future<void> deleteFlaggedMessages() async {
//Deletes all messages that are in deleted Messages List
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('deletedMessages') ?? '';

    if (data != '' && data.isNotEmpty) {
      deletedMessagesList =
          json.decode(data).map<String>((e) => e.toString()).toSet().toList();
      for (var flaggedMessage in deletedMessagesList) {
        deleteMessagefromDatabase(flaggedMessage);
      }
    } else {
      await prefs.setString(
          'deletedMessages', json.encode(deletedMessagesList));
    }
    return;
  }

  Future<void> sendMessage(String messageEntry) async {
    var uuid = const Uuid();
    var newMessageID = uuid.v1();
    Message newInstance = Message(
        id: newMessageID.toString(),
        username:
            sessionUserName, //hardcoding it for now, will need to make it dynamic in the future
        datetime: DateTime.now().toString(),
        mediatype: 'text',
        message: messageEntry,
        path: '',
        isUploaded: 'false');
    messageslist.insert(0, newInstance);
    saveMessages();
    if (connection == ConnectionStatus.wifi) {
      uploadText(newInstance);
    }
  }

  void uploadText(Message messageInstance) async {
    UserCredentials credentialsInstance = UserCredentials();
    String? token = await credentialsInstance.readToken();

    var response = await http.post(Uri.parse(apiUrl), headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      'Authorization': 'Bearer $token'
    }, body: {
      'message': messageInstance.message,
      'path': messageInstance.path,
      'dateTime': messageInstance.datetime,
      'mediatype': messageInstance.mediatype
    });

    switch (response.statusCode) {
      case 200:
        {
          Map<dynamic, dynamic> jsonDecode = json.decode(response.body);
          int messageindex = messageslist.indexOf(messageInstance);
          messageslist[messageindex] = Message.fromJson(jsonDecode);

          saveMessages();
        }
        break;
      case 404:
        throw ("Cannot Find The Requested Resource");
      default:
        throw (response.statusCode.toString());
    }
  }

  void deleteMessage(Message messageInstance) {
    messageslist.remove(messageInstance);
    saveMessages();
    if (connection == ConnectionStatus.wifi) {
      deleteMessagefromDatabase(messageInstance.id);
    } else if (messageInstance.isUploaded == "true") {
      flagforDeletion(messageInstance.id);
    }
  }

  void deleteMessagefromDatabase(String messageID) async {
    String? token = await credentialsInstance.readToken();

    var response = await http.delete(
      Uri.parse("$apiUrl/$messageID"),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
    );
    switch (response.statusCode) {
      case 200:
        {
          removeflagforDeletion(messageID);
        }
        break;
      case 404:
        {
          flagforDeletion(messageID);
          throw ("Cannot Find The Requested Resource");
        }

      default:
        {
          flagforDeletion(messageID);
          throw (response.statusCode.toString());
        }
    }
  }

  void flagforDeletion(String messageID) async {
    //Message couldn't be deleted so it is saved to be deleted during next sync
    deletedMessagesList.add(messageID);
    deletedMessagesList = deletedMessagesList.toSet().toList();
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('deletedMessages', json.encode(deletedMessagesList));
  }

  void removeflagforDeletion(String messageID) async {
    deletedMessagesList = deletedMessagesList.toSet().toList();
    deletedMessagesList.remove(messageID);
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('deletedMessages', json.encode(deletedMessagesList));
  }

  Future<void> sendImage() async {
    var uuid = const Uuid();
    var newfilename = uuid.v1();

    final results = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg']);

    if (results == null) {
      return;
    }

    final path = results.files.single.path;

    Message newInstance = Message(
        id: newfilename.toString(),
        username:
            'Lucifer', //hardcoding it for now, will need to make it dynamic in the future
        datetime: DateTime.now().toString(),
        mediatype: 'image',
        message: 'new message',
        path: path.toString(),
        isUploaded: 'false');

    messageslist.insert(0, newInstance);
    saveMessages();

    if (connection == ConnectionStatus.wifi) {
      uploadImage(newInstance);
    }
  }

  Future<void> sendCameraImage(String imagePath) async {
    var uuid = const Uuid();
    var newfilename = uuid.v1();

    Message newInstance = Message(
        id: newfilename.toString(),
        username:
            sessionUserName, //hardcoding it for now, will need to make it dynamic in the future
        datetime: DateTime.now().toString(),
        mediatype: 'image',
        message: 'new message',
        path: imagePath.toString(),
        isUploaded: 'false');

    messageslist.insert(0, newInstance);
    saveMessages();

    if (connection == ConnectionStatus.wifi) {
      uploadImage(newInstance);
    }
  }

  Future<void> uploadImage(Message messageInstance) async {
    String? token = await credentialsInstance.readToken();

    storage
        .uploadfile(messageInstance.path, messageInstance.id)
        .then((value) async {
      var response = await http.post(Uri.parse(apiUrl), headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        'Authorization': 'Bearer $token'
      }, body: {
        'message': 'new message',
        'path': value,
        'dateTime': messageInstance.datetime,
        'mediatype': 'image'
      });

      switch (response.statusCode) {
        case 200:
          {
            Map<dynamic, dynamic> jsonDecode = json.decode(response.body);
            int messageIndex = messageslist.indexOf(messageInstance);
            messageslist[messageIndex] = Message.fromJson(jsonDecode);
            saveMessages();
            break;
          }
        case 404:
          throw ("Cannot Find The Requested Resource");
        default:
          throw (response.statusCode.toString());
      }
    });
  }

  Future<void> sendVideo() async {
    var uuid = const Uuid();
    var newfilename = uuid.v1();

    final results = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['mp4', 'mkv', 'mov']);

    if (results == null) {
      return;
    }

    final path = results.files.single.path;

    Message newInstance = Message(
        id: newfilename.toString(),
        username:
            sessionUserName, //hardcoding it for now, will need to make it dynamic in the future
        datetime: DateTime.now().toString(),
        mediatype: 'video',
        message: 'new message',
        path: path.toString(),
        isUploaded: 'false');

    messageslist.insert(0, newInstance);
    saveMessages();

    if (connection == ConnectionStatus.wifi) {
      uploadVideo(newInstance);
    }
  }

  Future<void> uploadVideo(Message messageInstance) async {
    String? token = await credentialsInstance.readToken();
    storage
        .uploadVideo(messageInstance.path, messageInstance.id)
        .then((value) async {
      var response = await http.post(Uri.parse(apiUrl), headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        'Authorization': 'Bearer $token'
      }, body: {
        'message': 'new message',
        'path': value,
        'dateTime': messageInstance.datetime,
        'mediatype': 'video'
      });

      switch (response.statusCode) {
        case 200:
          {
            Map<dynamic, dynamic> jsonDecode = json.decode(response.body);
            int messageIndex = messageslist.indexOf(messageInstance);
            messageslist[messageIndex] = Message.fromJson(jsonDecode);
            saveMessages();

            break;
          }
        case 404:
          throw ("Cannot Find The Requested Resource");
        default:
          throw (response.statusCode.toString());
      }
    });
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
    } else if (connection == ConnectionStatus.wifi) {
      await getMessages();
    }
    notifyListeners();
  }

  Future<void> getMessages() async {
    //Getting new messages from API
    String? token = await credentialsInstance.readToken();

    final response = await http.get(
        Uri.parse(
            '$apiUrl?skip=${messageslist.length.toString()}&perpage=${loadPerPage.toString()}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        });

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
