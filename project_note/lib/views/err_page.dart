import 'package:flutter/material.dart';
import 'package:project_note/views/landing_page.dart';

class ErrPage extends StatefulWidget {
  final String statusCode;
  const ErrPage({super.key, required this.statusCode});

  @override
  State<ErrPage> createState() => _ErrPageState();
}

class _ErrPageState extends State<ErrPage> {
  void switchToLandingPage() {
    Navigator.of(context).pushReplacement(animatedLandingTransition());
  }

  Route animatedLandingTransition() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const LandingPage(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text(
              widget.statusCode,
              style: const TextStyle(
                  color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            IconButton(
                onPressed: () {
                  switchToLandingPage();
                },
                icon: const Icon(Icons.refresh_rounded))
          ],
        ),
      ),
    );
  }
}
