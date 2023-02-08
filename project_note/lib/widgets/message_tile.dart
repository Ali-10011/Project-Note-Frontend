import 'package:flutter/material.dart';
import 'package:bubble/bubble.dart';
import 'package:intl/intl.dart';
import 'package:project_note/globals/globals.dart';
import 'package:project_note/models/Message.dart';

Widget messageTile(Message messageEntry) {
  final clockString = dateTimeString(DateTime.parse(messageEntry.datetime));
  return Bubble(
    style: styleMe,
    child: ListTile(
      contentPadding: const EdgeInsets.only(left: 0.0, right: 0.0),
      title: Text(messageEntry.message),
      subtitle: Row(children: <Widget>[
        Text(
          clockString,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        const SizedBox(width: 10),
        Icon((messageEntry.isUploaded == 'true') ? Icons.check : Icons.error,
            size: 12)
      ]),
    ),
  );
}
