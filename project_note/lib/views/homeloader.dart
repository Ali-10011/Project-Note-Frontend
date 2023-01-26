import 'package:flutter/material.dart';
import 'package:project_note/model/Message.dart';
import 'package:project_note/model/dataLoad.dart';
import 'package:project_note/model/firebaseStorage.dart';
import 'package:project_note/views/errpage.dart';
import 'package:project_note/services/uploadmessages.dart';
import 'package:project_note/globals/globals.dart';

class LoadingState extends StatefulWidget {
  const LoadingState({Key? key}) : super(key: key);

  @override
  State<LoadingState> createState() => _LoadingStateState();
}

class _LoadingStateState extends State<LoadingState> {
  DataLoad dataLoad = DataLoad();
  //Storage storage = Storage();

  void WaitForData() async {
    try {
      await dataLoad.loadMessages();
    } on Exception catch (e) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ErrPage(statusCode: e.toString()),
          ));
    }
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  void initState() {
    super.initState();
    setConnection();
    if (!(connection == ConnectionStatus.wifi)) {
      WaitForData();
    } else if (connection == ConnectionStatus.wifi) {
      UploadMessages();
    }
  }

  void UploadMessages() async {
    try {
      uploadOfflineMessages();
    } on Exception catch (e) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ErrPage(statusCode: e.toString()),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Storage storage = Storage();
    return Scaffold(
      body: Center(
          child: Column(children: <Widget>[
        Text("Loading Your Messages, Please Wait..."),
        CircularProgressIndicator()
      ])),
    );
  }
}
