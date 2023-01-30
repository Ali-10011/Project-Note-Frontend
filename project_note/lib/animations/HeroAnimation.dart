import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:project_note/models/Message.dart';

class PhotoHero extends StatelessWidget {
  const PhotoHero({Key? key, required this.messageEntry}) : super(key: key);

  final Message messageEntry;

  Widget build(BuildContext context) {
    //timeDilation = 1.3;
    return Hero(
      tag: messageEntry,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: (messageEntry.isUploaded == 'true')
                ? CachedNetworkImage(
                    key: UniqueKey(),
                    imageUrl: messageEntry.path.toString(),
                    fit: BoxFit.cover)
                : Image.file(File(messageEntry.path), fit: BoxFit.cover)),
      ),
    );
  }
}
