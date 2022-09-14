import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project_note/views/Authentication.dart';
import 'package:project_note/views/Home.dart';
import 'package:project_note/views/homeloader.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Note',
      initialRoute: '/initial',
      routes: {'/': (context) => Auth(), '/home': (context) => Home(), '/initial' : (context) => LoadingState() },
      debugShowCheckedModeBanner: false,
    );
  }
}
