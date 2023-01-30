import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:project_note/models/FirebaseStorage.dart';

//List<Message> messageslist = [];
bool isLastPage = false;
const int loadPerPage = 15;

const String API_URL = 'http://localhost:3000/home';
Storage storage = Storage();
//DataLoad dataLoad = DataLoad();
var connection;

enum ConnectionStatus { wifi, mobileNetwork, noConnection }

const styleMe = BubbleStyle(
  margin: BubbleEdges.only(top: 10, bottom: 10),
  shadowColor: Color.fromARGB(255, 137, 9, 223),
  elevation: 2,
  alignment: Alignment.topRight,
  nip: BubbleNip.rightTop,
  color: Color.fromARGB(255, 230, 199, 255),
);
