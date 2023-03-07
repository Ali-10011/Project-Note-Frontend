import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:project_note/globals/globals.dart';
import 'package:project_note/services/forced_logout.dart';

class ProfileHero extends StatefulWidget {
  const ProfileHero({super.key});

  @override
  State<ProfileHero> createState() => _ProfileHeroState();
}

class _ProfileHeroState extends State<ProfileHero> {
  @override
  Widget build(BuildContext context) {
    timeDilation = 1.0;
    return Hero(
      tag: "Profile",
      child: Material(
        child: SafeArea(
          child: ListView(
              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      padding: const EdgeInsets.all(0.0),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(
                        Icons.cancel_rounded,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: const CircleAvatar(
                    radius: 70,
                    backgroundImage: AssetImage('assets/placeholder.png'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8.0, 0.0, 8.0),
                  child: Center(
                      child: Text(
                    sessionUserName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 26),
                  )),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(40, 0, 40, screenHeight * 0.1),
                  child: const Divider(thickness: 3.0, height: 30),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ElevatedButton.icon(
                      style: ButtonStyle(
                        elevation: MaterialStateProperty.all(20),
                        backgroundColor: MaterialStateProperty.all(Colors.red),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context)
                            .pushReplacement(animatedLogoutTransition());
                      },
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Logout')),
                )
              ]),
        ),
      ),
    );
  }
}
