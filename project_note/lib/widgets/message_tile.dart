import 'package:flutter/material.dart';
import 'package:bubble/bubble.dart';
import 'package:project_note/globals/globals.dart';
import 'package:project_note/models/message_model.dart';
import 'package:project_note/providers/message_provider.dart';
import 'package:project_note/services/forced_logout.dart';
import 'package:project_note/widgets/custom_snackbar.dart';
import 'package:provider/provider.dart';

Widget messageTile(Message messageEntry, BuildContext context) {
  final clockString = dateTimeString(DateTime.parse(messageEntry.datetime));

  return Bubble(
    style: styleMe,
    child: Padding(
      padding:
          const EdgeInsets.only(left: 8.0, right: 0.0, bottom: 0.0, top: 8.0),
      child: ListTile(
        title: Text(messageEntry.message),
        subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: [
                  Text(
                    clockString,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                      (messageEntry.isUploaded == 'true')
                          ? Icons.check
                          : Icons.error,
                      size: 12),
                ],
              ),
              IconButton(
                padding: const EdgeInsets.all(0),
                onPressed: () async {
                  try {
                    await Provider.of<MessageProvider>(context, listen: false)
                        .deleteMessage(messageEntry);
                  } catch (e) {
                    if (e == "401") {
                      fireSnackBar("Session Expired !", Colors.red,
                          Colors.white, context);
                      doForcedLogoutActivities(context);
                    } else {
                      fireSnackBar(
                          "Cannot Perform Action. Response statusCode : $e ",
                          Colors.red,
                          Colors.white,
                          context);
                    }
                  }
                },
                icon: const Icon(Icons.delete),
                color: Colors.black,
              )
            ]),
      ),
    ),
  );
}
