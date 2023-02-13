import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'dart:async';
import 'package:cached_video_player/cached_video_player.dart';

IconData icon = Icons.pause;

class VideoHero extends StatefulWidget {
  const VideoHero({Key? key, required this.videoUrl}) : super(key: key);
  final String videoUrl;
  @override
  State<VideoHero> createState() => _VideoHeroState();
}

class _VideoHeroState extends State<VideoHero> {
  late CachedVideoPlayerController _videocontroller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();

    _videocontroller = CachedVideoPlayerController.network(widget.videoUrl);
    _initializeVideoPlayerFuture =
        _videocontroller.initialize(); //returns a future

    _videocontroller.setLooping(true);
  }

  @override
  void dispose() {
    _videocontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    timeDilation = 1.3;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(),
      body: Hero(
        tag: widget.videoUrl,
        child: FutureBuilder(
          future: _initializeVideoPlayerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Center(
                child: AspectRatio(
                    aspectRatio: _videocontroller.value.aspectRatio,
                    child: CachedVideoPlayer(_videocontroller)),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            if (_videocontroller.value.isPlaying) {
              _videocontroller.pause();
            } else {
              _videocontroller.play();
            }
          });
        },
        child: Icon(
          _videocontroller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}
