import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project_note/model/Message.dart';
import 'package:project_note/globals/globals.dart';
import 'package:project_note/model/firebaseStorage.dart';

class LoadingState extends StatefulWidget {
  const LoadingState({Key? key}) : super(key: key);

  @override
  State<LoadingState> createState() => _LoadingStateState();
}

class _LoadingStateState extends State<LoadingState> {
  Storage storage = Storage();

  



  void WaitForData() async {
    await loadMessages();
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  void initState() {
    super.initState();
    WaitForData();
  }

  Widget build(BuildContext context) {
    Storage storage = Storage();
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
      //     body: Container(
      //   child: Column(
      //     children: [
      //       ElevatedButton(
      //           onPressed: () async {
      //             final results = await FilePicker.platform.pickFiles(
      //                 allowMultiple: false,
      //                 type: FileType.custom,
      //                 allowedExtensions: ['png', 'jpg']);
      //             if (results == null) {
      //               ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //                 content: Text('No File Was Selected.'),
      //               ));
      //               return null;
      //             }
      //             final path = results.files.single.path;
      //             final fileName = results.files.single.name;

      //             storage
      //                 .uploadfile(path!, fileName)
      //                 .then((value) => print('File has been uploaded'));
      //           },
      //           child: Text('Upload File')),
      //       FutureBuilder(
      //           future: storage.downloadURL('test.png'),
      //           builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
      //             if (snapshot.connectionState == ConnectionState.done &&
      //                 snapshot.hasData) {
      //               return InkWell(
      //                 onTap: () {
      //                   Navigator.push(
      //                       context,
      //                       MaterialPageRoute(
      //                         builder: (context) => PhotoHero(
      //                           photo: snapshot.data!,
      //                         ),
      //                       ));
      //                 },
      //                 child: Bubble(
      //                     style: styleMe,
      //                     child: Container(
      //                         color: Colors.white,
      //                         width: MediaQuery.of(context).size.width * 0.6,
      //                         height: MediaQuery.of(context).size.height * 0.45,
      //                         child: Image.network(snapshot.data!,
      //                             fit: BoxFit.cover))),
      //               );
      //             } else if (snapshot.connectionState ==
      //                     ConnectionState.waiting ||
      //                 !snapshot.hasData) {
      //               return CircularProgressIndicator();
      //             } else {
      //               return CircularProgressIndicator();
      //             }
      //             ;
      //           }),
      //     ],
      //   ),
      // ),
    );
  }
}
