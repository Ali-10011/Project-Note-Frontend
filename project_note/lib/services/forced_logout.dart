import 'package:flutter/material.dart';
import '../widgets/custom_snackbar.dart';
import '../views/logout_page.dart';

void forcedLogOut(BuildContext context) {
  fireSnackBar("Session Expired !", Colors.red, Colors.white, context);
  Navigator.of(context).pushReplacement(animatedLogoutTransition());
}

Route animatedLogoutTransition() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => const Logout(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.easeIn;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
