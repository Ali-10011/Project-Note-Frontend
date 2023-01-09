import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'dart:async';
import 'package:video_player/video_player.dart';

class VideoHero extends StatefulWidget {
  const VideoHero({Key? key, required this.video}) : super(key: key);
  final video;
  @override
  State<VideoHero> createState() => _VideoHeroState();
}

class _VideoHeroState extends State<VideoHero> {
  @override
  late VideoPlayerController _videocontroller;
  late Future<void> _initializeVideoPlayerFuture;
  @override
  void initState() {
    super.initState();
    _videocontroller = VideoPlayerController.network(widget.video);

    // Initialize the controller and store the Future for later use.
    _initializeVideoPlayerFuture =
        _videocontroller.initialize(); //returns a future

    // Use the controller to loop the video.
    _videocontroller.setLooping(true);
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    _videocontroller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    timeDilation = 1.3;
    return Scaffold(
      appBar: AppBar(),
      // Use a FutureBuilder to display a loading spinner while waiting for the
      // VideoPlayerController to finish initializing.
      body: Hero(
        tag: widget.video,
        child: FutureBuilder(
          future: _initializeVideoPlayerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              // If the VideoPlayerController has finished initialization, use
              // the data it provides to limit the aspect ratio of the video.
              return AspectRatio(
                  aspectRatio: _videocontroller.value.aspectRatio,
                  // Use the VideoPlayer widget to display the video.
                  child: VideoPlayer(_videocontroller));
            } else {
              // If the VideoPlayerController is still initializing, show a
              // loading spinner.
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Wrap the play or pause in a call to `setState`. This ensures the
          // correct icon is shown.
          setState(() {
            // If the video is playing, pause it.
            if (_videocontroller.value.isPlaying) {
              _videocontroller.pause();
            } else {
              // If the video is paused, play it.
              _videocontroller.play();
            }
          });
        },
        // Display the correct icon depending on the state of the player.
        child: Icon(
          _videocontroller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}
