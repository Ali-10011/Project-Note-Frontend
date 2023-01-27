import 'package:flutter/material.dart';
import 'package:project_note/model/Message.dart';
import 'package:project_note/model/dataLoad.dart';
import 'package:project_note/model/firebaseStorage.dart';
import 'package:project_note/views/errpage.dart';
import 'package:project_note/services/uploadmessages.dart';
import 'package:project_note/globals/globals.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

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
      Navigator.pushReplacementNamed(context, '/home');
    } on Exception catch (e) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ErrPage(statusCode: e.toString()),
          ));
    }
  }

  void UploadMessages() async {
    try {
      await uploadOfflineMessages();
       Navigator.pushReplacementNamed(context, '/home');
    } on Exception catch (e) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ErrPage(statusCode: e.toString()),
          ));
    }
  }

  void setConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      connection = ConnectionStatus.mobileNetwork;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      connection = ConnectionStatus.wifi;
    } else {
      connection = ConnectionStatus.noConnection;
    }
    if (!(connection == ConnectionStatus.wifi)) {
      print('We GOT NO WIFI !!!');
      WaitForData();
    } else if (connection == ConnectionStatus.wifi) {
      print('We GOT WIFI !!!');
      UploadMessages();
    }
  }

  @override
  void initState() {
    super.initState();
    setConnection();
  }

  @override
  Widget build(BuildContext context) {
    // Storage storage = Storage();
    return Center(
      child: Scaffold(
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
              Text("Loading Your Messages, Please Wait..."),
              CircularProgressIndicator()
            ])),
      ),
    );
  }
}
