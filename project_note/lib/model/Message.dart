import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:project_note/globals/globals.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Message {
  //Message Class with Json Encode and Decode Function
  late String username;
  late String datetime;
  late String mediatype;
  late String message;
  late String path;

  Message(
      {required this.username,
      required this.datetime,
      required this.mediatype,
      required this.message,
      required this.path});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
        username: json['username'],
        datetime: json['createdAt'],
        mediatype: json['mediatype'],
        message: json['message'],
        path: json['path']);
  }

  Map<String, dynamic> toJson() => {
        'username': username,
        'createdAt': datetime,
        'mediatype': mediatype,
        'message': message,
        'path': path
      };
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
  switch (response.statusCode) {
    case 200:
      final data = json.decode(response.body) as List<dynamic>;
      if (data.length < 15) {
        IsLastPage = true;
      } else {
        pageno++;
      }
       messageslist =
          json.decode(response.body).map<Message>((message) => Message.fromJson(message)).toList();
      break;
    case 404:
      throw ("Could not Find the Resource");
    default:
      throw (response.statusCode.toString());
  }
}
