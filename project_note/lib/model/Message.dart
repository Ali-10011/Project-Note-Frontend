import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:project_note/globals/globals.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Message {
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
  Map<String, String> queryparams = {
    'pageno': pageno.toString(),
    'skip': newmessages.toString()
  };
  var url = Uri.https('localhost:3000', '/api/', queryparams);
  final response = await http.get(Uri.parse(
    'http://localhost:3000/home?pageno=${pageno.toString()}&skip=${newmessages.toString()}&perpage=${LoadPerPage.toString()}',
  ));
/**/
  if (response.statusCode == 200) {
    final data = json.decode(response.body) as List<dynamic>;
    if (data.length < 15) {
      IsLastPage = true;
    } else {
      pageno++;
    }
    for (int i = 0; i < data.length; i++) {
      print(data[i]['mediatype']);
      messageslist.add(Message(
          userName: data[i]['username'],
          datetime: data[i]['createdAt'],
          mediaType: data[i]['mediatype'],
          message: data[i]['text'],
          path: data[i]['path']));
    }
    for (int i = 0; i < messageslist.length; i++) {
      print(messageslist[i].mediaType);
    }
    for (int i = 0; i < data.length; i++) {
      dynamic dateTimeString = data[i]['createdAt'];
      final dateTime = DateTime.parse(dateTimeString);
      final DateFormat formatter = DateFormat('yyyy-MM-dd');
      String formatted = formatter.format(dateTime);
      print('${formatted}');
    }
  } else {
    throw Exception("Failed to load products");
  }
}

void saveMessages() async {
  
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('messages', json.encode(messageslist)); //easy way to store dynamic objects
}

Future<void> loadMessages() async {
  final prefs = await SharedPreferences.getInstance();
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
    pageno = (messageslist.length / 15).toInt();
    newmessages = messageslist.length % 15;
  } else {
    await getMessages();
     pageno++;
  }

}

Future<void> getMessages() async {
    final response = await http.get(Uri.parse('http://localhost:3000/home'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List<dynamic>;
      for (int i = 0; i < data.length; i++) {
        messageslist.add(Message(
            userName: data[i]['username'],
            datetime: data[i]['createdAt'],
            mediaType: data[i]['mediatype'],
            message: data[i]['text'],
            path: data[i]['path']));
      }
      // for (int i = 0; i < data.length; i++) {
      //   print('${messageslist[i].message}  ${messageslist[i].date}');
      // }
    } else {
      throw Exception("Failed to load messages");
    }
  }
