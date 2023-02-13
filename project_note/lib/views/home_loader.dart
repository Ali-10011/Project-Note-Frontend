import 'package:flutter/material.dart';

import 'package:project_note/globals/globals.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';
import 'package:project_note/providers/message_provider.dart';

class LoadingState extends StatefulWidget {
  const LoadingState({Key? key}) : super(key: key);

  @override
  State<LoadingState> createState() => _LoadingStateState();
}

class _LoadingStateState extends State<LoadingState> {
  //Storage storage = Storage();

  Future<void> waitForData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //To Navigate From a Future  Builder
      Navigator.pushReplacementNamed(context, '/home');
    });
    // try {
    //   await Provider.of<MessageProvider>(context, listen: false).loadMessages();
    // } on Exception catch (e) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     //To Navigate From a Future  Builder
    //     Navigator.pushReplacement(
    //         context,
    //         MaterialPageRoute(
    //           builder: (context) => ErrPage(statusCode: e.toString()),
    //         ));
    //   });
    // }
  }

  void uploadMessages() {
    Provider.of<MessageProvider>(context, listen: false)
        .uploadOfflineMessages();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //To Navigate From a Future  Builder
      Navigator.pushReplacementNamed(context, '/home');
    });
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
    }

  

  @override
  void initState() {
    super.initState();
    setConnection();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: Scaffold(
          body: (connection == ConnectionStatus.wifi)
              ? Center(
                  child: FutureBuilder(
                    future: Provider.of<MessageProvider>(context, listen: false)
                        .deleteFlaggedMessages(),
                    builder: (context, dataSnapshot) {
                      if (dataSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              CircularProgressIndicator(),
                              Text("Syncing your Changes....")
                            ],
                          ),
                        );
                      } else if (dataSnapshot.connectionState ==
                          ConnectionState.done) {
                        uploadMessages();
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            CircularProgressIndicator(),
                            Text("Uploading Your Messages....")
                          ],
                        );
                      } else {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              CircularProgressIndicator(),
                              Text("Ooops, something unexpeccted Happened")
                            ],
                          ),
                        );
                      }
                    },
                  ),
                )
              : Center(
                  child: FutureBuilder(
                    future: Provider.of<MessageProvider>(context, listen: false)
                        .loadMessages(),
                    builder: (context, dataSnapshot) {
                      if (dataSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              CircularProgressIndicator(),
                              Text("Loading your Messages....")
                            ],
                          ),
                        );
                      } else if (dataSnapshot.connectionState ==
                          ConnectionState.done) {
                        waitForData();
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              CircularProgressIndicator(),
                              Text("Loading your Messages....")
                            ],
                          ),
                        );
                      } else {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              CircularProgressIndicator(),
                              Text("Ooops, something unexpeccted Happened")
                            ],
                          ),
                        );
                      }
                    },
                  ),
                )),
    );
  }
}