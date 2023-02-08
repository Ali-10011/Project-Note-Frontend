import 'package:cached_video_player/cached_video_player.dart';
import 'package:flutter/material.dart';
import 'package:bubble/bubble.dart';
import 'package:project_note/globals/globals.dart';
import 'package:project_note/models/Message.dart';

Widget videoTile(Message messageEntry) {
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
              child: Icon(
                  color: Colors.white, Icons.play_arrow_rounded, size: 60)),
        ),
        subtitle: Row(children: <Widget>[
          Text(
            clockString,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(width: 10),
          Icon((messageEntry.isUploaded == 'true') ? Icons.check : Icons.error,
              size: 12),
        ]),
      ),
    ]),
  );
}
