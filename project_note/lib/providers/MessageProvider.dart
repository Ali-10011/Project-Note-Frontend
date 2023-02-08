import 'package:file_picker/file_picker.dart';
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
    if (messageslist.isEmpty) {
      await loadMessages();
    }
    if (messageslist.isNotEmpty) {
      messageslist
          .where((message) => (message.isUploaded == "false"))
          .forEach((offlineMessage) async {
        if (offlineMessage.mediatype == 'text') {
          uploadText(offlineMessage);
        } else {
          uploadImage(offlineMessage);
        }
      });
    } else if (connection == ConnectionStatus.wifi) {
      await getMessages();
    }
  }

  Future<void> sendMessage(String messageEntry) async {
    var uuid = const Uuid();
    var newMessageID = uuid.v1();
    Message newInstance = Message(
        id: newMessageID.toString(),
        username:
            'Lucifer', //hardcoding it for now, will need to make it dynamic in the future
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
    var response = await http.post(Uri.parse(API_URL), headers: {
      "Content-Type": "application/x-www-form-urlencoded"
    }, body: {
      'message': messageInstance.message,
      'path': messageInstance.path,
      'dateTime' : messageInstance.datetime,
      'mediatype': messageInstance.mediatype
    });

    switch (response.statusCode) {
      case 200:
        {
          Map<dynamic, dynamic> jsonDecode = json.decode(response.body);
          int messageindex = messageslist.indexOf(messageInstance);
          messageslist[messageindex] = Message.fromJson(jsonDecode['result']);

          saveMessages();
        }
        break;
      case 404:
        throw ("Cannot Find The Requested Resource");
      default:
        throw (response.statusCode.toString());
    }
  }

  Future<void> sendImage() async {
    var uuid = const Uuid();
    var newfilename = uuid.v1();

    final results = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg']);

    if (results == null) {
      return null;
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

  Future<void> sendCameraImage(String imagePath) async
  {
    var uuid = const Uuid();
    var newfilename = uuid.v1();

     Message newInstance = Message(
        id: newfilename.toString(),
        username:
            'Lucifer', //hardcoding it for now, will need to make it dynamic in the future
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

  void uploadImage(Message messageInstance) {
    storage
        .uploadfile(messageInstance.path, messageInstance.id)
        .then((value) async {
      var response = await http.post(Uri.parse(API_URL), headers: {
        "Content-Type": "application/x-www-form-urlencoded"
      }, body: {
        'message': 'new message',
        'path': value,
        'dateTime': DateTime.now().toString(),
        'mediatype': 'image'

      });

      switch (response.statusCode) {
        case 200:
          Map<dynamic, dynamic> jsonDecode = json.decode(response.body);
          int messageIndex = messageslist.indexOf(messageInstance);
          messageslist[messageIndex] = Message.fromJson(jsonDecode['result']);
          saveMessages();
          break;
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
      return null;
    }

    final path = results.files.single.path;


    Message newInstance = Message(
        id: newfilename.toString(),
        username:
            'Lucifer', //hardcoding it for now, will need to make it dynamic in the future
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

  void uploadVideo(Message messageInstance) {
    storage
        .uploadVideo(messageInstance.path, messageInstance.id)
        .then((value) async {
      var response = await http.post(Uri.parse(API_URL), headers: {
        "Content-Type": "application/x-www-form-urlencoded"
      }, body: {
        'message': 'new message',
        'path': value,
        'dateTime': DateTime.now().toString(),
        'mediatype': 'video'
      });

      switch (response.statusCode) {
        case 200:
          Map<dynamic, dynamic> jsonDecode = json.decode(response.body);
          int messageIndex = messageslist.indexOf(messageInstance);
          messageslist[messageIndex] = Message.fromJson(jsonDecode['result']);
          saveMessages();
          break;
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
