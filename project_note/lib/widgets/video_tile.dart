import 'package:flutter/material.dart';
import 'package:bubble/bubble.dart';
import 'package:project_note/globals/globals.dart';
import 'package:project_note/models/message_model.dart';
import 'package:provider/provider.dart';

import '../providers/message_provider.dart';

Widget videoTile(Message messageEntry, BuildContext context) {
  final clockString = dateTimeString(DateTime.parse(messageEntry.datetime));
  return Bubble(
    style: styleMe,
    child: Stack(children: <Widget>[
      ListTile(
        contentPadding: const EdgeInsets.only(left: 0.0, right: 0.0),
        title: Container(
          margin: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
          color: Colors.black,
          height: screenHeight * 0.3,
          child: Positioned(
              top: screenHeight / 5.5,
              left: screenWidth / 4.5,
              child: const Icon(
                  color: Colors.white, Icons.play_arrow_rounded, size: 60)),
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
          Row(
            children: [
              Text(
                clockString,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(width: 10),
              Icon(
                  (messageEntry.isUploaded == 'true')
                      ? Icons.check
                      : Icons.error,
                  size: 12),
            ],
          ),
          IconButton(
            padding: const EdgeInsets.all(0),
            onPressed: () {
              Provider.of<MessageProvider>(context, listen: false)
                  .deleteMessage(messageEntry);
            },
            icon: const Icon(Icons.delete),
            color: Colors.black,
          )
        ]),
      ),
    ]),
  );
}
