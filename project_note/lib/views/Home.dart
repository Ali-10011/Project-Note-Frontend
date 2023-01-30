import 'package:flutter/material.dart';
import 'package:project_note/models/Message.dart';
import 'package:project_note/globals/globals.dart';
import 'package:project_note/providers/MessageProvider.dart';
import 'package:project_note/views/ErrPage.dart';
import 'package:project_note/animations/HeroAnimation.dart';
import 'package:project_note/widgets/image_tile.dart';
import 'package:project_note/widgets/message_tile.dart';
import 'package:provider/provider.dart';
import 'package:project_note/widgets/BottomBar.dart';

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
        title: const Text('Home'),
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
            onPressed: () {
              setState(() {
                connection = (connection == ConnectionStatus.wifi)
                    ? ConnectionStatus.noConnection
                    : ConnectionStatus.wifi;
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
                              child: imageTile(_messageslist[i]));
                        } else {
                          return (messageTile(_messageslist[i]));
                        }
                      } else if (isLastPage) {
                        return const Padding(
                          padding: EdgeInsets.fromLTRB(150, 10, 150, 10),
                          child: Divider(
                            height: 1,
                            thickness: 5,
                          ),
                        );
                      } else {
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
