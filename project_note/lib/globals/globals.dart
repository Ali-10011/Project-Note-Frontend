import 'package:project_note/model/Message.dart';
import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:project_note/model/dataLoad.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

List<Message> messageslist = [];
bool IsLastPage = false;
int pageno = 0;
int newmessages = 0;
DataLoad dataLoad = DataLoad();
var connection;
enum ConnectionStatus { wifi, mobileNetwork, noConnection }


const int LoadPerPage = 15;
const styleMe = BubbleStyle(
  margin: BubbleEdges.only(top: 10, bottom: 10),
  shadowColor: Color.fromARGB(255, 137, 9, 223),
  elevation: 2,
  alignment: Alignment.topRight,
  nip: BubbleNip.rightTop,
  color: Color.fromARGB(255, 230, 199, 255),
);
