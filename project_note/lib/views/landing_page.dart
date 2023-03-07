import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:project_note/globals/globals.dart';
import 'package:project_note/views/authentication_page.dart';
import 'package:project_note/views/home_loader.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  void _switchToPage(final snapShotData) {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context)
          .pushReplacement(animatedLandingTransition(snapShotData));
    });
  }

  Route animatedLandingTransition(final isValid) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          (isValid == false) ? const Auth() : const LoadingState(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeIn;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
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

  Widget createBody() {
    return Scaffold(
      body: Stack(children: [
        ClipRRect(
          child: Image.asset('assets/landing_page.jpg',
              fit: BoxFit.cover, height: MediaQuery.of(context).size.height),
        ),
        Positioned(
          top: 100,
          left: screenWidth * 0.33,
          child: Center(
            child: Text(
              "Note",
              style: TextStyle(
                  fontSize: 60,
                  foreground: Paint()
                    ..shader = const LinearGradient(
                      colors: <Color>[Colors.white, Colors.black],
                    ).createShader(
                      const Rect.fromLTWH(0.0, 0.0, 300.0, 50.0),
                    )),
            ),
          ),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return FutureBuilder(
      future: credentialsInstance.isTokenValid(),
      builder: (context, dataSnapshot) {
        if (dataSnapshot.connectionState == ConnectionState.waiting) {
          return createBody();
        } else if (dataSnapshot.connectionState == ConnectionState.done) {
          _switchToPage(dataSnapshot.data);

          return createBody();
        } else if (dataSnapshot.hasError) {
          return Container();
        } else {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircularProgressIndicator(),
                Text("Ooops, something unexpected happened")
              ],
            ),
          );
        }
      },
    );
  }
}
