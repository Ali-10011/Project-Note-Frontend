import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project_note/models/message_model.dart';
import 'package:project_note/globals/globals.dart';
import 'package:uuid/uuid.dart';

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

  Future<String?> uploadOfflineMessages() async {
    try {
      if ((messageslist.isEmpty)) {
       
        await loadMessages(); //no messages have been loaded, and offline mode so load existing messages instead
      } else if (messageslist.isNotEmpty) {
        //we already have some loaded messages in the list
       
        messageslist
            .where((message) => (message.isUploaded == "false"))
            .forEach((offlineMessage) async {
          if (offlineMessage.mediatype == 'text') {
            await uploadText(offlineMessage);
          } else if (offlineMessage.mediatype == 'image') {
            await uploadImage(offlineMessage);
          } else if (offlineMessage.mediatype == 'video') {
            await uploadVideo(offlineMessage);
          }
        });
      }
    } catch (e) {
      throw (e.toString());
    }
    return null;
  }

  Future<String?> deleteFlaggedMessages() async {
//Deletes all messages that are in deleted Messages List

    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('deletedMessages') ?? '';

    if (data != '' && data.isNotEmpty) {
      deletedMessagesList =
          json.decode(data).map<String>((e) => e.toString()).toSet().toList();
      for (var flaggedMessage in deletedMessagesList) {
        try {
          await deleteMessagefromDatabase(flaggedMessage);
        } catch (e) {
          throw (e.toString());
        }
      }
    } else {
      await prefs.setString(
          'deletedMessages', json.encode(deletedMessagesList));
    }
    return null;
  }

  Future<String?> sendMessage(String messageEntry) async {
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

    try {
      saveMessages();
      if (connection == ConnectionStatus.wifi) {
        await uploadText(newInstance);
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<String?> uploadText(Message messageInstance) async {
    bool isValid = await credentialsInstance.isTokenValid();
    if (!(isValid)) {
      //we check if the token is valid
      throw ("401");
    }
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
      case 401:
        throw ("401");

      default:
        throw (response.statusCode);
    }
    return null;
  }

  Future<String?> deleteMessage(Message messageInstance) async {
    if (connection == ConnectionStatus.wifi) {
      //The user is connected to the internet
      try {
        await deleteMessagefromDatabase(messageInstance.id);
      } catch (e) {
        if (e == "200") {
          messageslist.remove(messageInstance);
          saveMessages(); //Sync the changes with the shared prefs
        } else {
          rethrow;
        }
      }
    } else if (messageInstance.isUploaded == "true") {
      //The user is not connected to the internet
      messageslist.remove(
          messageInstance); //Remove the message from offline view of user.
      saveMessages(); //Sync the changes with the shared prefs
      flagforDeletion(messageInstance.id);
    }
    return null;
  }

  Future<String?> deleteMessagefromDatabase(String messageID) async {
    bool isValid = await credentialsInstance.isTokenValid();
    if (!(isValid)) {
      //we check if the token is valid
      throw ("401");
    }
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
          throw ("200"); //Tells the caller function that the message was sucessfully deleted
        }
      case 401: //This case means that the token has expired
        {
          throw ("401"); //we save nothing, perform no action
        }
      default: //For any other error code
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

  Future<String?> sendImage() async {
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
            sessionUserName, //hardcoding it for now, will need to make it dynamic in the future
        datetime: DateTime.now().toString(),
        mediatype: 'image',
        message: 'new message',
        path: path.toString(),
        isUploaded: 'false');

    messageslist.insert(0, newInstance);
    saveMessages();

    if (connection == ConnectionStatus.wifi) {
      try {
        await uploadImage(newInstance);
      } catch (e) {
        throw (e.toString());
      }
    }
    return null;
  }

  Future<String?> uploadImage(Message messageInstance) async {
    bool isValid = await credentialsInstance.isTokenValid();
    if (!(isValid)) {
      //we check if the token is valid
      throw ("401");
    }
    String? token = await credentialsInstance.readToken();
    try {
      await storage
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
          //Throw back to the calling function;
          case 200:
            {
              Map<dynamic, dynamic> jsonDecode = json.decode(response.body);
              int messageIndex = messageslist.indexOf(messageInstance);
              messageslist[messageIndex] = Message.fromJson(jsonDecode);
              saveMessages();
              throw ("200");
            }
          case 401:
            {
              throw ("401");
            }
        }
      });
    } catch (e) {
      throw (e.toString());
    }
    return null;
  }

  Future<String?> sendCameraImage(String imagePath) async {
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
      try {
        await uploadImage(newInstance);
      } catch (e) {
        throw (e.toString());
      }
    }
    return null;
  }

  Future<String?> sendVideo() async {
    var uuid = const Uuid();
    var newfilename = uuid.v1();

    final results = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['mp4', 'mkv', 'mov']);

    if (results == null) {
      return "";
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
      try {
        await uploadVideo(newInstance);
      } catch (e) {
        rethrow;
      }
    }
    return null;
  }

  Future<String?> uploadVideo(Message messageInstance) async {
    bool isValid = await credentialsInstance.isTokenValid();
    if (!(isValid)) {
      //we check if the token is valid
      throw ("401");
    }
    String? token = await credentialsInstance.readToken();
    try {
      await storage
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
              throw ("200");
            }
          default:
            throw (response.statusCode.toString());
        }
      });
    } catch (e) {
      throw (e.toString());
    }
  }

  void saveMessages() async {
    //Save messages to mobile storage

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('messages',
        json.encode(messageslist)); //easy way to store dynamic objects
    notifyListeners();
  }

  Future<String?> loadMessages() async {
    //Load Messages from mobile storage

    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString('messages') ?? '';

    if (data.isNotEmpty) {
      //Converts the decoded json string to a 'Message' type Map.
      messageslist = json
          .decode(data)
          .map<Message>((message) => Message.fromJson(message))
          .toList();
      notifyListeners();
      throw ("200");
    } else if (connection == ConnectionStatus.wifi) {
      
      try {
        await getMessages();
      } catch (e) {
        throw (e.toString());
      }
    }
    return null;
  }

  Future<String?> getMessages() async {
    //Getting new messages from API
    bool isValid = await credentialsInstance.isTokenValid();
    if (!(isValid)) {
      //we check if the token is valid
      throw ("401");
    }
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

    switch (response.statusCode) {
      case 200:
        if (data.isEmpty) {
          isLastPage = true;
        } else if (data.length < loadPerPage) {
          messageslist.addAll(json
              .decode(response.body)
              .map<Message>((message) => Message.fromJson(message))
              .toList());
          notifyListeners();
          isLastPage = true;
        } else {
          messageslist.addAll(json
              .decode(response.body)
              .map<Message>((message) => Message.fromJson(message))
              .toList());
          notifyListeners();
          isLastPage = false;
        }
        saveMessages();
        throw ("200");
      default:
        throw (response.statusCode.toString());
    }
  }
}
