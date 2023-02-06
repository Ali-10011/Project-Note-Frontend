import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:project_note/models/FirebaseStorage.dart';

//List<Message> messageslist = [];
bool isLastPage = false;
const int loadPerPage = 15;

const String API_URL = 'http://localhost:3000/home';
Storage storage = Storage();
var connection;

enum ConnectionStatus { wifi, mobileNetwork, noConnection }

double screenWidth = 0;
double screenHeight = 0;

late final firstCamera;

const styleMe = BubbleStyle(
  margin: BubbleEdges.only(top: 10, bottom: 10),
  shadowColor: Color.fromARGB(255, 137, 9, 223),
  elevation: 2,
  alignment: Alignment.topRight,
  nip: BubbleNip.rightTop,
  color: Color.fromARGB(255, 138, 62, 201),
);
