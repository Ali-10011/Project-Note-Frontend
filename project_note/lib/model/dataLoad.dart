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
    try {
      final data = json.decode(prefs.getString('messages')!);
      if (data != null) {
        for (int i = 0; i < data.length; i++) {
          messageslist.add(Message(
              userName: data[i]['name'],
              datetime: data[i]['createdAt'],
              mediaType: data[i]['mediaType'],
              message: data[i]['text'],
              path: data[i]['path']));
        }
        pageno = (messageslist.length / 15)
            .toInt(); //How many pages of messages were loaded
        newmessages = messageslist.length %
            15; //How many messages were loaded additional to the pages loaded
      } else {
        await getMessages();
        pageno++;
      }
    } catch (e) {
      throw ("Could not fetch stored chat");
    }
  }

  Future<void> getMessages() async {
    //Getting new messages from API
    final response = await http.get(Uri.parse('http://localhost:3000/home'));
    switch (response.statusCode) {
      case 200:
        final data = json.decode(response.body) as List<dynamic>;
        for (int i = 0; i < data.length; i++) {
          messageslist.add(Message(
              userName: data[i]['username'],
              datetime: data[i]['createdAt'],
              mediaType: data[i]['mediatype'],
              message: data[i]['text'],
              path: data[i]['path']));
        }
        break;
      case 404:
        throw ("Could not Fetch the resource");
      default:
        throw (response.statusCode.toString());
    }
  }
}
