import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:project_note/constants/constant.dart';
class Message {
  late String userName;
  late String date;
  late String mediaType;
  late String? message;
  late String? path;

  Message(
      {required this.userName,
      required this.date,
      required this.mediaType,
      required this.message,
      required this.path});
}

Future<void> getMessages() async {
  final response = await http.get(Uri.parse('http://localhost:3000/home'));

  if (response.statusCode == 200) {
    final data = json.decode(response.body) as List<dynamic>;
    for (int i = 0; i < data.length; i++) {
      messageslist.add(Message(
          userName: data[i]['username'],
          date: data[i]['createdAt'],
          mediaType: data[i]['path'] ?? 'text',
          message: data[i]['text'],
          path: data[i]['path']));
    }
    // for (int i = 0; i < data.length; i++) {
    //   print('${messageslist[i].message}  ${messageslist[i].date}');
    // }

    // final products =
    //     data.map<Message>((json) => Product.fromJson(json)).toList();
    //print(data);
    // return products;
  } else {
    throw Exception("Failed to load products");
  }
}

