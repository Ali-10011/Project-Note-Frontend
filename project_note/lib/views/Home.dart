import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bubble/bubble.dart';
import 'package:project_note/models/Message.dart';
import 'package:project_note/globals/globals.dart';
import 'package:intl/intl.dart';
import 'package:project_note/providers/MessageProvider.dart';
import 'package:project_note/views/ErrPage.dart';
import 'package:project_note/animations/HeroAnimation.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

  late final TextEditingController _messagecontroller = TextEditingController();
  Future<void> loadMore() async {
    try {
      if ((connection == ConnectionStatus.wifi) && (isLastPage == false)) {
        Provider.of<MessageProvider>(context, listen: false).getMoreMessages();
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


  Future<void> sendmessage() async {
    try {
      var response = await http.post(Uri.parse(API_URL), headers: {
        "Content-Type": "application/x-www-form-urlencoded"
      }, body: {
        'message': _messagecontroller.value.text.toString(),
        'path': '',
        'mediatype': 'text'
      });

      switch (response.statusCode) {
        case 200:
          {
            Map<dynamic, dynamic> jsonDecode = json.decode(response.body);
            print(jsonDecode);
            setState(() {
              _messageslist.insert(
                  0,
                  Message(
                      id: jsonDecode['result']['_id'],
                      username: jsonDecode['result']['username'],
                      datetime: jsonDecode['result']['createdAt'],
                      mediatype: 'text',
                      message: jsonDecode['result']['message'],
                      path: jsonDecode['result']['path'],
                      isUploaded: jsonDecode['result']['isUploaded']));
              newmessages++;
              Provider.of<MessageProvider>(context, listen: false)
                  .saveMessages();
            });
            print(jsonDecode['result']['_id']);
          }
          break;
        case 404:
          throw ("Cannot Find The Requested Resource");
        default:
          throw (response.statusCode.toString());

        //print(jsonDecode);
      }
    } catch (e) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ErrPage(statusCode: e.toString()),
          ));
    }
    _messagecontroller.clear();
  }


  Widget build(BuildContext context) {
    _messageslist = context.watch<MessageProvider>().messages;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
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
                        final format = DateFormat("h:mma");
                        final clockString = format
                            .format(DateTime.parse(_messageslist[i].datetime));
                        if (_messageslist[i].mediatype.compareTo('image') ==
                            0) {
                          return InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PhotoHero(
                                        photo: _messageslist[i].path.toString(),
                                      ),
                                    ));
                              },
                              child: Bubble(
                                style: styleMe,
                                child: ListTile(
                                  contentPadding:
                                      EdgeInsets.only(left: 0.0, right: 0.0),
                                  title: CachedNetworkImage(
                                      key: UniqueKey(),
                                      imageUrl:
                                          _messageslist[i].path.toString(),
                                      fit: BoxFit.cover),
                                  subtitle: Row(children: <Widget>[
                                    Text(
                                      clockString,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12),
                                    ),
                                    SizedBox(width: 10),
                                    Icon(
                                        (_messageslist[i].isUploaded == 'true')
                                            ? Icons.check
                                            : Icons.lock_clock,
                                        size: 12)
                                  ]),
                                ),
                              ));
                        } else {
                          return (Bubble(
                            style: styleMe,
                            child: ListTile(
                              contentPadding:
                                  EdgeInsets.only(left: 0.0, right: 0.0),
                              title: Text(_messageslist[i].message.toString()),
                              subtitle: Row(children: <Widget>[
                                Text(
                                  clockString,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12),
                                ),
                                SizedBox(width: 10),
                                Icon(
                                    (_messageslist[i].isUploaded == 'true')
                                        ? Icons.check
                                        : Icons.error,
                                    size: 12)
                              ]),
                            ),
                          ));
                        }
                      } else if (isLastPage) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(child: Text("All messages Loaded !")),
                        );
                      } else if (_messageslist.length < loadPerPage) {
                        // do nothing
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
