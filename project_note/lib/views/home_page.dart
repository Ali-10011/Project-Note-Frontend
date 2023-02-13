import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:project_note/animations/profile_hero.dart';
import 'package:project_note/models/message_model.dart';
import 'package:project_note/globals/globals.dart';
import 'package:project_note/providers/message_provider.dart';
import 'package:project_note/views/err_page.dart';
import 'package:project_note/animations/image_hero.dart';
import 'package:project_note/views/video_player.dart';
import 'package:project_note/widgets/image_tile.dart';
import 'package:project_note/widgets/video_tile.dart';
import 'package:project_note/widgets/message_tile.dart';
import 'package:provider/provider.dart';
import 'package:project_note/widgets/bottom_bar.dart';

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

  Future<void> loadMore() async {
    try {
      if ((connection == ConnectionStatus.wifi) && (isLastPage == false)) {
        Provider.of<MessageProvider>(context, listen: false).getMessages();
      }
    } on Exception catch (e) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ErrPage(statusCode: e.toString()),
          ));
    }
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      if ((connection == ConnectionStatus.wifi)) {
        if (controller.position.maxScrollExtent == controller.offset) {
          if (!(isLastPage)) {
            try {
              loadMore();
            } on Exception catch (e) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ErrPage(statusCode: e.toString()),
                  ));
            }
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
    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: ()
          {
            Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ProfileHero()),
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
              Icons.wifi,
              color: (connection == ConnectionStatus.wifi)
                  ? Colors.blue
                  : Colors.white,
            ),
            onPressed: () async {
              var connectivityResult =
                  await (Connectivity().checkConnectivity());
              setState(() {
                if (connectivityResult == ConnectivityResult.wifi) {
                  connection = (connection == ConnectionStatus.wifi)
                      ? ConnectionStatus.noConnection
                      : ConnectionStatus.wifi;
                } else {
                  connection = ConnectionStatus.noConnection;
                }
                if (connection == ConnectionStatus.wifi) {
                  Provider.of<MessageProvider>(context, listen: false)
                      .uploadOfflineMessages();
                }
              });
              // do something
            },
          )
        ],
      ),
      body: CustomScrollView(controller: controller, reverse: true, slivers: [
        SliverToBoxAdapter(
          child: Container(
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
                          return Hero(
                            tag: _messageslist[i].id,
                            child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PhotoHero(
                                          messageEntry: _messageslist[i],
                                        ),
                                      ));
                                },
                                child: imageTile(_messageslist[i], context)),
                          );
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
                        Provider.of<MessageProvider>(context, listen: false)
                            .getMessages();
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
    );
  }
}