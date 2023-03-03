import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:project_note/globals/globals.dart';
import 'package:project_note/providers/message_provider.dart';
import 'package:provider/provider.dart';
import 'package:project_note/views/err_page.dart';

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();

    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take a picture')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            final image = await _controller.takePicture();

            if (!mounted) return;
            //if (image == null) return;

            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                  imagePath: image.path,
                ),
              ),
            );
          } catch (e) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => ErrPage(statusCode: e.toString()),
              ),
            );
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  State<DisplayPictureScreen> createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  void _fireSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.red,
      content: Text(
        message.toString(),
        style: const TextStyle(color: Colors.white),
      ),
    ));
  }

  Future<void> _doForcedLogoutActivities() async {
    credentialsInstance.deleteToken();
    Provider.of<MessageProvider>(context, listen: false).deleteAllMessages();
    _fireSnackBar("Session Expired !");
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/auth', (Route<dynamic> route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Display the Picture')),
        body: Image.file(File(widget.imagePath)),
        floatingActionButton:
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          FloatingActionButton(
            heroTag: null,
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        TakePictureScreen(camera: firstCamera),
                  ));
            },
            child: const Icon(Icons.delete),
          ),
          FloatingActionButton(
            heroTag: null,
            onPressed: () async {
              try {
                await Provider.of<MessageProvider>(context, listen: false)
                    .sendCameraImage(widget.imagePath);
              } catch (e) {
                if (e.toString() == "401") {
                  _doForcedLogoutActivities();
                } else if (e.toString() == "200") {
                  Navigator.of(context).pop();
                } else {
                  _fireSnackBar("Error Code : ${e.toString()} Occurred");
                }
              }
            },
            child: const Icon(Icons.check),
          )
        ]));
  }
}
