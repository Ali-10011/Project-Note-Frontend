import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:project_note/globals/globals.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_note/model/Message.dart';

class DataLoad {
  void saveMessages() async {
    //Save messages to mobile storage

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('messages',
        json.encode(messageslist)); //easy way to store dynamic objects
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
}
