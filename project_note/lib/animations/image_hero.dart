import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:project_note/models/message_model.dart';

class PhotoHero extends StatelessWidget {
  const PhotoHero({Key? key, required this.messageEntry}) : super(key: key);

  final Message messageEntry;

  @override
  Widget build(BuildContext context) {
    //timeDilation = 2.0;
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: (messageEntry.isUploaded == 'true')
                ? CachedNetworkImage(
                    key: UniqueKey(),
                    imageUrl: messageEntry.path.toString(),
                    fit: BoxFit.contain)
                : Image.file(File(messageEntry.path), fit: BoxFit.contain)),
      ),
    );
  }
}
