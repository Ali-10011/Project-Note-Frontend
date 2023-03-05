import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:project_note/animations/profile_hero.dart';
import 'package:project_note/models/message_model.dart';
import 'package:project_note/globals/globals.dart';
import 'package:project_note/providers/message_provider.dart';
import 'package:project_note/animations/image_hero.dart';
import 'package:project_note/views/video_player.dart';

import 'package:project_note/widgets/image_tile.dart';
import 'package:project_note/widgets/video_tile.dart';
import 'package:project_note/widgets/message_tile.dart';
import 'package:provider/provider.dart';
import 'package:project_note/widgets/bottom_bar.dart';

import '../services/forced_logout.dart';
import '../widgets/custom_snackbar.dart';

import '../widgets/connection_alert.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Message> _messageslist = [];
  final controller = ScrollController();

  Color networkBarColor =
      (connection == ConnectionStatus.wifi) ? Colors.blue : Colors.white;

  void loadMore() async {
    if ((connection == ConnectionStatus.wifi) && (isLastPage == false)) {
      try {
        await Provider.of<MessageProvider>(context, listen: false)
            .getMessages();
      } catch (e) {
        if (e == "401") {
          doForcedLogoutActivities(context);
        } else if (e == "200") {
        } else {
          fireSnackBar(e.toString(), Colors.red, Colors.white, context);
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      if ((connection == ConnectionStatus.wifi)) {
        if (controller.position.maxScrollExtent == controller.offset) {
          if (!(isLastPage)) {
            loadMore();
          }
        }
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void clearCache() {
    imageCache.clear();
    imageCache.clearLiveImages();
    setState(() {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Images Reloaded !"),
      ));
    });
  }

 

  @override
  Widget build(BuildContext context) {
    _messageslist = context.watch<MessageProvider>().messages;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileHero()),
              );
            },
            child: Hero(
              tag: "Profile",
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(25.0),
                  child: Image.asset('assets/placeholder.png',
                      height: 50.0, width: 50.0, fit: BoxFit.cover)),
            ),
          ),
          backgroundColor: Colors.black,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.clear_all,
                color: Colors.white,
              ),
              onPressed: () {
                clearCache();
                // do something
              },
            ),
            IconButton(
              icon: Icon(
                (connection == ConnectionStatus.wifi)
                    ? Icons.wifi_outlined
                    : Icons.signal_wifi_bad_outlined,
                color: (connection == ConnectionStatus.wifi)
                    ? Colors.blue
                    : Colors.red,
              ),
              onPressed: () {
                showModalBottomSheet(
                    backgroundColor: Colors.transparent,
                    context: context,
                    builder: (builder) => (connection == ConnectionStatus.wifi
                        ? connectionAlert(context)
                        : noConnectionAlert(context)));
              },
            )
          ],
        ),
        body: CustomScrollView(controller: controller, reverse: true, slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: (_messageslist.isEmpty)
                  ? const Center(child: Text('Start Typing.... '))
                  : ListView.builder(
                      reverse: true,
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemCount: _messageslist.length + 1,
                      itemBuilder: (context, i) {
                        if (i < _messageslist.length) {
                          if (_messageslist[i].mediatype.compareTo('image') ==
                              0) {
                            return InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PhotoHero(
                                          messageEntry: _messageslist[i],
                                        ),
                                      ));
                                },
                                child: imageTile(_messageslist[i], context));
                          }
                          if (_messageslist[i].mediatype.compareTo('video') ==
                              0) {
                            return InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => VideoHero(
                                          videoUrl: _messageslist[i].path,
                                        ),
                                      ));
                                },
                                child: videoTile(_messageslist[i], context));
                          } else {
                            return (messageTile(_messageslist[i], context));
                          }
                        } else if (isLastPage ||
                            connection == ConnectionStatus.noConnection) {
                          return const Padding(
                            padding: EdgeInsets.fromLTRB(150, 10, 150, 10),
                            child: Divider(
                              height: 1,
                              thickness: 5,
                            ),
                          );
                        } else {
                          loadMore();
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                      }),
            ),
          ),
        ]),
        bottomNavigationBar: const BottomBar(),
      ),
    );
  }
}
