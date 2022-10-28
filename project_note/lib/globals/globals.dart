import 'package:project_note/model/Message.dart';
import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';

List<Message> messageslist = [];
bool IsLastPage = false;
int pageno = 0;
int newmessages = 0;
const int LoadPerPage = 15;
const styleMe = BubbleStyle(
  margin: BubbleEdges.only(top: 10),
  shadowColor: Colors.blue,
  elevation: 2,
  alignment: Alignment.topRight,
  nip: BubbleNip.rightTop,
  color: Color.fromARGB(255, 225, 255, 199),
);
