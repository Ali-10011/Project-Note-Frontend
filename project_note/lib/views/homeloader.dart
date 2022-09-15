import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project_note/model/Message.dart';
import 'package:project_note/globals/globals.dart';

class LoadingState extends StatefulWidget {
  const LoadingState({Key? key}) : super(key: key);

  @override
  State<LoadingState> createState() => _LoadingStateState();
}

class _LoadingStateState extends State<LoadingState> {
  Future<void> getMessages() async {
    final response = await http.get(Uri.parse('http://localhost:3000/home'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List<dynamic>;
      for (int i = 0; i < data.length; i++) {
        messageslist.add(Message(
            userName: data[i]['username'],
            datetime: data[i]['createdAt'],
            mediaType: data[i]['path'] ?? 'text',
            message: data[i]['text'],
            path: data[i]['path']));
      }
      // for (int i = 0; i < data.length; i++) {
      //   print('${messageslist[i].message}  ${messageslist[i].date}');
      // }
    } else {
      throw Exception("Failed to load products");
    }
  }

  void WaitForData() async {
    await getMessages();
    if (messageslist.isNotEmpty) {
      pageno++;
      Navigator.pushReplacementNamed(context, '/home');
    }
    else{
       Navigator.pushReplacementNamed(context, '/err');
    }
  }

  @override
  void initState() {
    super.initState();
    WaitForData();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
            child: SpinKitDoubleBounce(
          color: Colors.white,
          size: 50.0,
        )));
  }
}
