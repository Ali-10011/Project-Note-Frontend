import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/widgets.dart';
import 'package:project_note/globals/globals.dart';
import 'package:provider/provider.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  void _switchToPage(final snapShotData) {
    if (snapShotData == false) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        //To Navigate From a Future  Builder
        Navigator.pushReplacementNamed(context, '/auth');
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        //To Navigate From a Future  Builder
        Navigator.pushReplacementNamed(context, '/initial');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: credentialsInstance.isTokenValid(),
      builder: (context, dataSnapshot) {
        if (dataSnapshot.connectionState == ConnectionState.waiting) {
          return ClipRRect(
            child: Image.asset('assets/landing_page.jpg'),
          );
        } else if (dataSnapshot.connectionState == ConnectionState.done) {
          _switchToPage(dataSnapshot.data);
          return ClipRRect(
            child: Image.asset(
              'assets/landing_page.jpg',
              fit: BoxFit.fill,
            ),
          );
        } else if (dataSnapshot.hasError) {
          return Container();
        } else {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircularProgressIndicator(),
                Text("Ooops, something unexpeccted Happened")
              ],
            ),
          );
        }
      },
    );
  }
}
