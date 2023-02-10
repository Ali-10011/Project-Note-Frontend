import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:bubble/bubble.dart';
import 'package:project_note/globals/globals.dart';
import 'package:project_note/models/Message.dart';
import 'package:provider/provider.dart';

import '../providers/MessageProvider.dart';

Widget imageTile(Message messageEntry, BuildContext context) {
  final clockString = dateTimeString(DateTime.parse(messageEntry.datetime));
  return Bubble(
    style: styleMe,
    child: ListTile(
      contentPadding: const EdgeInsets.only(left: 0.0, right: 0.0),
      title: Container(
          margin: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
          color: Colors.white,
          height: screenHeight * 0.3,
          child: (messageEntry.isUploaded == 'true')
              ? CachedNetworkImage(
                  key: UniqueKey(),
                  imageUrl: messageEntry.path.toString(),
                  fit: BoxFit.cover)
              : Image.file(File(messageEntry.path), fit: BoxFit.cover)),
      subtitle:
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: <Widget>[
        Text(
              clockString,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        const SizedBox(width: 10),
        Icon((messageEntry.isUploaded == 'true') ? Icons.check : Icons.error,
                size: 12),
              
      ]
      
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
            ],
          ),
    ),
  );
}
