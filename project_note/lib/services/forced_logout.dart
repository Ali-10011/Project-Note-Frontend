import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../globals/globals.dart';
import '../providers/message_provider.dart';
import '../widgets/custom_snackbar.dart';

Future<void> doForcedLogoutActivities(BuildContext context) async {
  credentialsInstance.deleteTokenCredentials();
  Provider.of<MessageProvider>(context, listen: false).deleteAllMessages();
  fireSnackBar("Session Expired !", Colors.red, Colors.white, context);
  Future.delayed(const Duration(seconds: 1), () {
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/auth', (Route<dynamic> route) => false);
  });
}
