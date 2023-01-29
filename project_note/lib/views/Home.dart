import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bubble/bubble.dart';
import 'package:project_note/models/Message.dart';
import 'package:project_note/globals/globals.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:project_note/models/FirebaseStorage.dart';
import 'package:project_note/providers/MessageProvider.dart';
import 'package:project_note/views/ErrPage.dart';
import 'package:uuid/uuid.dart';
import 'package:project_note/animations/HeroAnimation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Message> _messageslist = [];
  final controller = ScrollController();
  Storage storage = Storage();

  late final TextEditingController _messagecontroller = TextEditingController();
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
    checkConnection();
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

  void checkConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      // connection = ConnectionStatus.mobileNetwork;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Connected to a mobile network !"),
      ));
    } else if (connectivityResult == ConnectivityResult.wifi) {
      //connection = ConnectionStatus.wifi;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Connected to a Wifi !"),
      ));
    } else {
      //connection = ConnectionStatus.noConnection;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("No Network Connection Found !"),
      ));
    }
  }

  Widget bottomSheet() {
    return Container(
      height: 278,
      width: MediaQuery.of(context).size.width,
      child: Card(
        margin: const EdgeInsets.all(18.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconCreation(
                      Icons.insert_drive_file, Colors.indigo, "Document"),
                  const SizedBox(
                    width: 40,
                  ),
                  iconCreation(Icons.camera_alt, Colors.pink, "Camera"),
                  const SizedBox(
                    width: 40,
                  ),
                  iconCreation(Icons.insert_photo, Colors.purple, "Gallery"),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconCreation(Icons.headset, Colors.orange, "Audio"),
                  const SizedBox(
                    width: 40,
                  ),
                  iconCreation(Icons.location_pin, Colors.teal, "Location"),
                  const SizedBox(
                    width: 40,
                  ),
                  iconCreation(Icons.person, Colors.blue, "Contact"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget iconCreation(IconData icons, Color color, String text) {
    return InkWell(
      onTap: () async {
        var uuid = const Uuid();
        var newfilename = uuid.v1();
        Navigator.pop(context);
        if (text == 'Gallery') {
          final results = await FilePicker.platform.pickFiles(
              allowMultiple: false,
              type: FileType.custom,
              allowedExtensions: ['png', 'jpg']);
          if (results == null) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('No File Was Selected.'),
            ));
            return null;
          }

          final path = results.files.single.path;
          final fileName = results.files.single.name;

          storage.uploadfile(path!, newfilename).then((value) async {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Image Sent !'),
            ));
            try {
              var response = await http.post(Uri.parse(API_URL), headers: {
                "Content-Type": "application/x-www-form-urlencoded"
              }, body: {
                'message': 'new message',
                'path': value,
                'mediatype': 'image'
              });

              switch (response.statusCode) {
                case 200:
                  Map<dynamic, dynamic> jsonDecode = json.decode(response.body);
                  setState(() {
                    _messageslist.insert(
                        0,
                        Message(
                            id: jsonDecode['result']['_id'],
                            username: jsonDecode['result']['username'],
                            datetime: jsonDecode['result']['createdAt'],
                            mediatype: 'image',
                            message: jsonDecode['result']['message'],
                            path: jsonDecode['result']['path'],
                            isUploaded: jsonDecode['result']['isUploaded']));
                    newmessages++;
                    Provider.of<MessageProvider>(context, listen: false)
                        .saveMessages();
                  });
                  break;
                case 404:
                  throw ("Cannot Find The Requested Resource");
                default:
                  throw (response.statusCode.toString());
              }
            } catch (e) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ErrPage(statusCode: e.toString()),
                  ));
            }
          });
        } //print(text);
        else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Feature under Development!"),
          ));
        }
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color,
            child: Icon(
              icons,
              // semanticLabel: "Help",
              size: 29,
              color: Colors.white,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              // fontWeight: FontWeight.w100,
            ),
          )
        ],
      ),
    );
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
    checkConnection();
  }

  Future<void> sendOfflineMessage() async {
    setState(() {
      // print(newMessageID.toString());
      Provider.of<MessageProvider>(context, listen: false)
          .addOfflineMessage(_messagecontroller.value.text.toString());
      _messagecontroller.clear();
    });
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
      bottomNavigationBar: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          //color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                  //padding: EdgeInsets.all(0.0),
                  onPressed: () {
                    showModalBottomSheet(
                        backgroundColor: Colors.transparent,
                        context: context,
                        builder: (builder) => bottomSheet());
                  },
                  icon: const Icon(
                    Icons.add,
                    color: Colors.black,
                  )),
              Container(
                width: MediaQuery.of(context).size.width * 0.75,
                child: TextField(
                  controller: _messagecontroller,
                  maxLines: 3,
                  minLines: 1,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      onPressed: () {
                        _messagecontroller.clear();
                      },
                      icon: const Icon(Icons.clear),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                    border: const OutlineInputBorder(),
                    hintText: 'Enter Text',
                  ),
                ),
              ),
              IconButton(
                  onPressed: sendOfflineMessage,
                  icon: const Icon(
                    Icons.send,
                    color: Colors.blueAccent,
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
