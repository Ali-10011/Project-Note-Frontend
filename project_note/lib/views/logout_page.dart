import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../globals/globals.dart';
import '../providers/message_provider.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';

class Logout extends StatefulWidget {
  const Logout({super.key});

  @override
  State<Logout> createState() => _LogoutState();
}

class _LogoutState extends State<Logout> {
  void doLogoutActivities() async {
    credentialsInstance.deleteTokenCredentials();
    Provider.of<MessageProvider>(context, listen: false).deleteAllMessages();
    Future.delayed(const Duration(milliseconds: 1500), () {
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/auth', (Route<dynamic> route) => false);
    });
  }

  @override
  void initState() {
    super.initState();
    doLogoutActivities();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SpinKitFadingCircle(
        color: Colors.white,
      ),
    );
  }
}
