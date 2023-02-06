import 'package:flutter/material.dart';
import 'package:bubble/bubble.dart';
import 'package:project_note/globals/globals.dart';

Widget datetimeTile(DateTime time) {
 
  return Bubble(
    style: styleMe,
    child: ListTile(
        contentPadding: const EdgeInsets.only(left: 0.0, right: 0.0),
        title: Text(time.toIso8601String())
  ));
}
