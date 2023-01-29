import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project_note/globals/globals.dart';
import 'package:file_picker/file_picker.dart';
import 'package:project_note/providers/MessageProvider.dart';
import 'package:project_note/views/ErrPage.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  late final TextEditingController _messagecontroller = TextEditingController();
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

  Future<void> sendOfflineMessage() async {

      Provider.of<MessageProvider>(context, listen: false)
          .addOfflineMessage(_messagecontroller.value.text.toString());
      _messagecontroller.clear();
   
  }
   Future<void> sendOnlineMessage() async {
    Provider.of<MessageProvider>(context, listen: false)
        .sendMessage(_messagecontroller.value.text.toString());
    _messagecontroller.clear();
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
                    // messageslist.insert(
                    //     0,
                    //     Message(
                    //         id: jsonDecode['result']['_id'],
                    //         username: jsonDecode['result']['username'],
                    //         datetime: jsonDecode['result']['createdAt'],
                    //         mediatype: 'image',
                    //         message: jsonDecode['result']['message'],
                    //         path: jsonDecode['result']['path'],
                    //         isUploaded: jsonDecode['result']['isUploaded']));
                    // newmessages++;
                    // Provider.of<MessageProvider>(context, listen: false)
                    //     .saveMessages();
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

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                  onPressed: sendOnlineMessage,
                  icon: const Icon(
                    Icons.send,
                    color: Colors.blueAccent,
                  ))
            ],
          ),
        ));
  }
}
