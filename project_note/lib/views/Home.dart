import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bubble/bubble.dart';
import 'package:project_note/model/Message.dart';
import 'package:project_note/constants/constant.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final controller = ScrollController();

  Future<void> LoadMore() async {
    await getMessages();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      
      if (controller.position.maxScrollExtent == controller.offset) {
        LoadMore();
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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
      onTap: () {
        print(text);
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

  late TextEditingController _messagecontroller = TextEditingController();
  static const styleMe = BubbleStyle(
    nip: BubbleNip.rightCenter,
    color: Color.fromARGB(255, 225, 255, 199),
    borderColor: Colors.blue,
    borderWidth: 1,
    elevation: 4,
    margin: BubbleEdges.only(top: 8, left: 50),
    alignment: Alignment.topRight,
  );
  Widget build(BuildContext context) {
    return Scaffold(
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
                        return (Bubble(
                            style: styleMe,
                            child: Text(messageslist[i].message.toString())));
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
      bottomNavigationBar: Container(
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
              width: MediaQuery.of(context).size.width * 0.85,
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
                onPressed: () async {
                  try {
                    var response = await http.post(
                        Uri.parse('http://localhost:3000/home'),
                        headers: {
                          "Content-Type": "application/x-www-form-urlencoded"
                        },
                        body: {
                          'message': _messagecontroller.value.text.toString()
                        });

                    if (response.statusCode == 200) {
                      Map<dynamic, dynamic> jsonDecode =
                          json.decode(response.body);
                      setState(() {
                        messageslist.insert(
                            0,
                            Message(
                                userName: jsonDecode['result']['username'],
                                date: jsonDecode['result']['createdAt'],
                                mediaType:
                                    jsonDecode['result']['path'] ?? 'text',
                                message: jsonDecode['result']['text'],
                                path: jsonDecode['result']['path']));
                      });

                      //print(jsonDecode);
                    } else {
                      throw Exception('cannot store message');
                    }
                  } catch (e) {
                    print(e.toString());
                  }
                  _messagecontroller.clear();
                },
                icon: Icon(
                  Icons.send,
                  color: Colors.blueAccent,
                ))
          ],
        ),
      ),
    );
  }
}
