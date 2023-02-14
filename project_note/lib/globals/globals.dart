import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:project_note/models/firebase_storage.dart';
import 'package:intl/intl.dart';

//List<Message> messageslist = [];
bool isLastPage = false;
const int loadPerPage = 15;

const String apiUrl = 'http://localhost:3000/api/home/messages';
Storage storage = Storage();
var connection;

enum ConnectionStatus { wifi, mobileNetwork, noConnection }

double screenWidth = 0;
double screenHeight = 0;

// ignore: prefer_typing_uninitialized_variables
late final firstCamera;

const styleMe = BubbleStyle(
  margin: BubbleEdges.only(top: 10, bottom: 10),
  shadowColor: Color.fromARGB(255, 137, 9, 223),
  elevation: 2,
  alignment: Alignment.topRight,
  nip: BubbleNip.rightTop,
  color: Color.fromARGB(255, 62, 173, 201),
);

int daysBetween(DateTime from, DateTime to) {
  from = DateTime(from.year, from.month, from.day);
  to = DateTime(to.year, to.month, to.day);
  return (to.difference(from).inHours / 24).round();
}

String dateTimeString(DateTime messageDt) {
  int daysApart = daysBetween(messageDt, DateTime.now());

  if (daysApart == 0) {
    final format = DateFormat("h:mm a");
    var todayDate = format.format(DateTime.parse(messageDt.toString()));
    return ("Today at $todayDate");
  } else if (daysApart == 1) {
    final format = DateFormat("h:mm a");
    var todayDate = format.format(DateTime.parse(messageDt.toString()));
    return ("Yesterday at $todayDate");
  } else {
    final format = DateFormat("dd/MM/yyyy h:mm a");
    var todayDate = format.format(DateTime.parse(messageDt.toString()));
    return todayDate;
  }
}


