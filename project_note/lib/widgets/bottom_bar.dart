import 'package:flutter/material.dart';
import 'package:project_note/globals/globals.dart';
import 'package:project_note/providers/message_provider.dart';
import 'package:project_note/views/camera_picture.dart';
import 'package:provider/provider.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  late final TextEditingController _messagecontroller = TextEditingController();
  void _fireSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: color,
      content: Text(
        message.toString(),
        style: const TextStyle(color: Colors.white),
      ),
    ));
  }

  Future<void> _doForcedLogoutActivities() async {
    credentialsInstance.deleteTokenCredentials();
    Provider.of<MessageProvider>(context, listen: false).deleteAllMessages();
    _fireSnackBar("Session Expired !", Colors.red);
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/auth', (Route<dynamic> route) => false);
    });
  }

  Widget bottomSheet() {
    return SizedBox(
      height: screenHeight / 3,
      width: MediaQuery.of(context).size.width,
      child: Card(
        margin: const EdgeInsets.all(18.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  iconCreation(Icons.camera_alt, Colors.pink, "Camera"),
                  iconCreation(Icons.insert_photo, Colors.purple, "Image"),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  iconCreation(Icons.video_camera_front, Colors.black, "Video"),
                  iconCreation(Icons.person, Colors.blue, "Contact"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void sendMessage() async {
    try {
      await Provider.of<MessageProvider>(context, listen: false)
          .sendMessage(_messagecontroller.value.text.toString());
    } catch (e) {
      if (e.toString() == "401") {
        _doForcedLogoutActivities();
      } else {
        _fireSnackBar("Error ${e.toString()} occurred", Colors.red);
      }
    }
    _messagecontroller.clear();
  }

  Widget iconCreation(IconData icons, Color color, String text) {
    return InkWell(
      onTap: () async {
        Navigator.pop(context);
        try {
          if (text == 'Image') {
            await Provider.of<MessageProvider>(context, listen: false)
                .sendImage();
          } else if (text == "Camera") {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TakePictureScreen(camera: firstCamera),
                ));
          } else if (text == "Video") {
            await Provider.of<MessageProvider>(context, listen: false)
                .sendVideo();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Feature under Development!"),
            ));
          }
        } catch (e) {
          if (e.toString() == "401") {
            _doForcedLogoutActivities();
          } else if (e.toString() == "200") {
            _fireSnackBar("SuccessFully Uploaded", Colors.green);
          } else {
            _fireSnackBar("Error Code: ${e.toString()} occurred", Colors.red);
          }
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
      child: Material(
        elevation: 20,
        child: Container(
          padding: const EdgeInsets.only(top: 10),
          color: Colors.black,
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
                    color: Colors.white,
                  )),
              SizedBox(
                width: screenWidth * 0.75,
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
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(
                        width: 1.1,
                        color: Colors.grey,
                      ),
                    ),
                    border: const OutlineInputBorder(),
                    hintText: 'Enter Text',
                  ),
                ),
              ),
              IconButton(
                  onPressed: () {
                    sendMessage();
                  },
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
