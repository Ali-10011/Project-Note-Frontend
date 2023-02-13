import 'package:flutter/material.dart';

class ErrPage extends StatelessWidget {
  final String statusCode;
  const ErrPage({super.key, required this.statusCode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
      child: Text(statusCode, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),),
    ));
  }
}
