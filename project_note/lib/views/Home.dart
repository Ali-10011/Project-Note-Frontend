import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bubble/bubble.dart';
import 'package:project_note/model/Message.dart';
import 'package:project_note/globals/globals.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:project_note/model/firebaseStorage.dart';
import 'package:uuid/uuid.dart';
import 'package:project_note/services/heroAnimation.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final controller = ScrollController();
  Storage storage = Storage();
  late TextEditingController _messagecontroller = TextEditingController();
  Future<void> LoadMore() async {
    await getMoreMessages();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      if (controller.position.maxScrollExtent == controller.offset) {
        if (!(IsLastPage)) {
          LoadMore();
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
                  SizedBox(
                    width: 40,
                  ),
                  iconCreation(Icons.camera_alt, Colors.pink, "Camera"),
                  SizedBox(
                    width: 40,
                  ),
                  iconCreation(Icons.insert_photo, Colors.purple, "Gallery"),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconCreation(Icons.headset, Colors.orange, "Audio"),
                  SizedBox(
                    width: 40,
                  ),
                  iconCreation(Icons.location_pin, Colors.teal, "Location"),
                  SizedBox(
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
        var uuid = Uuid();
        var newfilename = uuid.v1();

        if (text == 'Gallery') {
          final results = await FilePicker.platform.pickFiles(
              allowMultiple: false,
              type: FileType.custom,
              allowedExtensions: ['png', 'jpg']);
          if (results == null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('No File Was Selected.'),
            ));
            return null;
          }

          final path = results.files.single.path;
          final fileName = results.files.single.name;

          storage.uploadfile(path!, newfilename).then((value) async {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Image Sent !'),
            ));
            try {
              var response = await http
                  .post(Uri.parse('http://localhost:3000/home'), headers: {
                "Content-Type": "application/x-www-form-urlencoded"
              }, body: {
                'message': 'new message',
                'path': value,
                'mediatype': 'image'
              });

              if (response.statusCode == 200) {
                Map<dynamic, dynamic> jsonDecode = json.decode(response.body);
                setState(() {
                  messageslist.insert(
                      0,
                      Message(
                          userName: jsonDecode['result']['username'],
                          datetime: jsonDecode['result']['createdAt'],
                          mediaType: 'image',
                          message: jsonDecode['result']['text'],
                          path: jsonDecode['result']['path']));
                  newmessages++;
                });

                //print(jsonDecode);
              } else {
                //Navigator.pushReplacementNamed(context, '/err'); //thinking of directing to errpage if any exception comes
                throw Exception('cannot store message');
              }
            } catch (e) {
              print(e.toString());
            }
          });
        } //print(text);
        Navigator.pop(context);
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
          SizedBox(
            height: 5,
          ),
          Text(
            text,
            style: TextStyle(
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
      var response =
          await http.post(Uri.parse('http://localhost:3000/home'), headers: {
        "Content-Type": "application/x-www-form-urlencoded"
      }, body: {
        'message': _messagecontroller.value.text.toString(),
        'path': '',
        'mediatype': 'text'
      });

      if (response.statusCode == 200) {
        Map<dynamic, dynamic> jsonDecode = json.decode(response.body);
        setState(() {
          messageslist.insert(
              0,
              Message(
                  userName: jsonDecode['result']['username'],
                  datetime: jsonDecode['result']['createdAt'],
                  mediaType: 'text'.toString(),
                  message: jsonDecode['result']['text'],
                  path: jsonDecode['result']['path']));
          newmessages++;
           print("CALLED THE FUNCTION IN HERE");
        saveMessages();
        });
       
        //print(jsonDecode);
      } else {
        //Navigator.pushReplacementNamed(context, '/err'); //thinking of directing to errpage if any exception comes
        throw Exception('cannot store message');
      }
    } catch (e) {
      print(e.toString());
    }
    _messagecontroller.clear();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(
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
            child: (messageslist.isEmpty)
                ? Center(child: Text('Start Typing.... '))
                : ListView.builder(
                    reverse: true,
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    itemCount: messageslist.length + 1,
                    itemBuilder: (context, i) {
                      if (i < messageslist.length) {
                        final format = DateFormat("h:mma");
                        final clockString = format
                            .format(DateTime.parse(messageslist[i].datetime));
                        // DateTime FirstdateTime = DateTime.parse(messageslist[i].datetime); //current message
                        //   DateTime SeconddateTime = DateTime.parse(messageslist[i].datetime);
                        // final DateFormat formatter = DateFormat('yyyy-MM-dd');
                        // String thismessage = formatter.format(FirstdateTime);
                        // String previousmessage = formatter.format(SeconddateTime);
                        // if(FirstdateTime.isBefore(SeconddateTime))
                        if (messageslist[i].mediaType.compareTo('image') == 0) {
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PhotoHero(
                                      photo: messageslist[i].path.toString(),
                                    ),
                                  ));
                            },
                            child: Bubble(
                                style: styleMe,
                                child: Container(
                                    color: Colors.white,
                                    width:
                                        MediaQuery.of(context).size.width * 0.6,
                                    height: MediaQuery.of(context).size.height *
                                        0.45,
                                    child: CachedNetworkImage(
                                        key: UniqueKey(),
                                        imageUrl:
                                            messageslist[i].path.toString(),
                                        fit: BoxFit.cover))),
                          );
                        } else {
                  
                          return (Bubble(
                              style: styleMe,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(messageslist[i].message.toString()),
                                  Text(
                                    clockString,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12),
                                  ),
                                ],
                              )));
                        }
                      } else if (IsLastPage) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(child: Text("All messages Loaded !")),
                        );
                      } else if (messageslist.length < LoadPerPage) {
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
                  icon: Icon(
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
                      icon: Icon(Icons.clear),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                    border: OutlineInputBorder(),
                    hintText: 'Enter Text',
                  ),
                ),
              ),
              IconButton(
                  onPressed: sendmessage,
                  icon: Icon(
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
