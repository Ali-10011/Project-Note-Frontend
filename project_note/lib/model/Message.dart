import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:project_note/globals/globals.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Message {
  //Message Class with Json Encode and Decode Function
  late String userName;
  late String datetime;
  late String mediaType;
  late String message;
  late String path;

  Message(
      {required this.userName,
      required this.datetime,
      required this.mediaType,
      required this.message,
      required this.path});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
        userName: json['username'],
        datetime: json['createdAt'],
        mediaType: json['mediaType'],
        message: json['text'],
        path: json['path']);
  }

  Map<String, dynamic> toJson() => {
        'name': userName,
        'createdAt': datetime,
        'mediaType': mediaType,
        'text': message,
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
      for (int i = 0; i < data.length; i++) {
        messageslist.add(Message(
            userName: data[i]['username'],
            datetime: data[i]['createdAt'],
            mediaType: data[i]['mediatype'],
            message: data[i]['text'],
            path: data[i]['path']));
      }

      for (int i = 0; i < data.length; i++) {
        dynamic dateTimeString = data[i]['createdAt'];
        final dateTime = DateTime.parse(dateTimeString);
        final DateFormat formatter = DateFormat('yyyy-MM-dd');
        String formatted = formatter.format(dateTime);
      }
      break;
    case 404:
      throw ("Could not Find the Resource");
    default:
      throw (response.statusCode.toString());
  }
}
