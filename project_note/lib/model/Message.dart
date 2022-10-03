import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:project_note/globals/globals.dart';
import 'package:intl/intl.dart';

class Message {
  late String userName;
  late String datetime;
  late String mediaType;
  late String? message;
  late String? path;

  Message(
      {required this.userName,
      required this.datetime,
      required this.mediaType,
      required this.message,
      required this.path});
}

Future<void> getMessages() async {
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

    // final products =
    //     data.map<Message>((json) => Product.fromJson(json)).toList();
    //print(data);
    // return products;
  } else {
    throw Exception("Failed to load products");
  }
}
