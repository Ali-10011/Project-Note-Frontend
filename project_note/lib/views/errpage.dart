import 'package:flutter/material.dart';

class ErrPage extends StatefulWidget {
  const ErrPage({Key? key}) : super(key: key);

  @override
  State<ErrPage> createState() => _ErrPageState();
}

class _ErrPageState extends State<ErrPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("Could not load messages :(")),
    );
  }
}
