import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ProfileHero extends StatelessWidget {
  const ProfileHero({super.key});

  @override
  Widget build(BuildContext context) {
    timeDilation = 1.0;
    return Hero(
      tag: "Profile",
      child: Material(
        child: SafeArea(
          child: ListView(
              padding: const EdgeInsets.fromLTRB(0, 8.0, 0.0, 8.0),
              children: <Widget>[
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: const CircleAvatar(
                    radius: 70,
                    backgroundImage: AssetImage('assets/placeholder.png'),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(0, 8.0, 0.0, 8.0),
                  child: Center(
                      child: Text(
                    'Ali Hussnain',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
                  )),
                ),
                const Divider(thickness: 3.0, height: 30),
                RichText(
                  text: const TextSpan(
                      text:
                          "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum."),
                  selectionRegistrar: SelectionContainer.maybeOf(context),
                  selectionColor: const Color(0xAF6694e8),
                )
              ]),
        ),
      ),
    );
  }
}