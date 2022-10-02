// import 'package:project_note/model/Message.dart';
// import 'package:flutter/material.dart';
// import 'package:bubble/bubble.dart';

// class MessagesList extends StatefulWidget {
//   const MessagesList({Key? key}) : super(key: key);

//   @override
//   State<MessagesList> createState() => _MessagesListState();
// }

// class _MessagesListState extends State<MessagesList> {
//   @override
//   static const styleMe = BubbleStyle(
//     nip: BubbleNip.rightCenter,
//     color: Color.fromARGB(255, 225, 255, 199),
//     borderColor: Colors.blue,
//     borderWidth: 1,
//     elevation: 4,
//     margin: BubbleEdges.only(top: 8, left: 50),
//     alignment: Alignment.topRight,
//   );

//   Widget build(BuildContext context) {
//     Future<List<Message>> data = getMessages();
//     return FutureBuilder(
//       future: data,
//       builder: (context, AsyncSnapshot snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Container(child: Text('Loading'));
//         } else if (snapshot.hasError) {
//           return Container(child: Text('Error !'));
//         } else {
//           return ListView.builder(
//               reverse: true,
//               shrinkWrap: true,
//               physics: ClampingScrollPhysics(),
//               itemCount: snapshot.data.length,
//               itemBuilder: (context, i) {
//                 while (i < snapshot.data.length) {
//                   return (Bubble(
//                       style: styleMe, child: Text(snapshot.data[i].message)));
//                 }

//                 return Container();
//               });
//         }
//       },
//     );
//   }
// }
