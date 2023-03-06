import 'package:flutter/material.dart';

import 'package:project_note/globals/globals.dart';

import 'package:project_note/views/err_page.dart';
import 'package:provider/provider.dart';
import 'package:project_note/providers/message_provider.dart';

class LoadingState extends StatefulWidget {
  const LoadingState({Key? key}) : super(key: key);

  @override
  State<LoadingState> createState() => _LoadingStateState();
}

class _LoadingStateState extends State<LoadingState> {
  Future<void> waitForData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //To Navigate From a Future  Builder
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  Future<void> redirectToErrPage(final snapshotErr) async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //To Navigate From a Future  Builder
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => ErrPage(
                statusCode: snapshotErr.toString(),
              )));
    });
  }

  void loadMessages() async {
    try {
      await Provider.of<MessageProvider>(context, listen: false).loadMessages();
    } catch (e) {
      if (e == "200") {
        uploadMessages();
      } else {
        redirectToErrPage(e.toString());
      }
    }
  }

  void uploadMessages() async {
    try {
      await Provider.of<MessageProvider>(context, listen: false)
          .uploadOfflineMessages();
    } catch (e) {
      if (e == "200") {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          //To Navigate From a Future  Builder
          Navigator.pushReplacementNamed(context, '/home');
        });
      }
    }
  }

  Future<void> doOnlineSetup() async {
    try {
      await Provider.of<MessageProvider>(context, listen: false)
          .deleteFlaggedMessages();
    } catch (e) {
      if (e == "200") {
        return;
      }
      if (e != "200") {
        redirectToErrPage(e.toString());
      }
    }
  }

  Future<void> doOfflineSetup() async {
    try {
      await Provider.of<MessageProvider>(context, listen: false).loadMessages();
    } catch (e) {
      return;
    }
  }

  void _setUserName() async {
    await credentialsInstance.setSessionUserName();
  }

  @override
  void initState() {
    super.initState();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    _setUserName();
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
                    future: doOnlineSetup(),
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
                        loadMessages();

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            CircularProgressIndicator(),
                            Text("Uploading Your Messages....")
                          ],
                        );
                      } else if (dataSnapshot.hasError) {
                        redirectToErrPage(dataSnapshot.error);
                        return Container();
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
                    future: doOfflineSetup(),
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
                              Text("Setting you up.....")
                            ],
                          ),
                        );
                      } else if (dataSnapshot.hasError) {
                        redirectToErrPage(dataSnapshot.error);
                        return Container();
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
