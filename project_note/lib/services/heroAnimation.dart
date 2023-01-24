import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:cached_network_image/cached_network_image.dart';

class PhotoHero extends StatelessWidget {
  const PhotoHero({Key? key, required this.photo}) : super(key: key);

  final String photo;

  Widget build(BuildContext context) {
    //timeDilation = 1.3;
    return Container(
      child: Hero(
        tag: photo,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: CachedNetworkImage(
                  key: UniqueKey(), imageUrl: photo, fit: BoxFit.contain)),
        ),
      ),
    );
  }
}
