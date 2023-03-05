import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:project_note/globals/globals.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  void _switchToPage(final snapShotData) {
    Future.delayed(const Duration(seconds: 2), () {
      if (snapShotData == false) {
        Navigator.pushReplacementNamed(context, '/auth');
      } else {
        Navigator.pushReplacementNamed(context, '/initial');
      }
    });
  }

  void setConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.mobile) {
      connection = ConnectionStatus.mobileNetwork;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      connection = ConnectionStatus.wifi;
    } else {
      connection = ConnectionStatus.noConnection;
    }
 
  }

  @override
  initState() {
    super.initState();
    setConnection();
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
