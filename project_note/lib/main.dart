import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:project_note/views/Authentication.dart';
import 'package:project_note/views/Home.dart';
import 'package:project_note/views/ErrPage.dart';
import 'package:project_note/views/HomeLoader.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:project_note/providers/MessageProvider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  runApp(MultiProvider(providers: [ChangeNotifierProvider(create: (_) => MessageProvider())] ,child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Note',
      initialRoute: '/initial',
      routes: {
        '/auth': (context) => Auth(),
        '/home': (context) => Home(),
        '/initial': (context) => LoadingState(),
        '/err': (context) => ErrPage(),
       

      },
      debugShowCheckedModeBanner: false,
    );
  }
}
