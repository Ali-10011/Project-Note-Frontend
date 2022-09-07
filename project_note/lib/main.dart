import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _emailcontroller = TextEditingController();
  final TextEditingController _passwordcontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(mainAxisAlignment: MainAxisAlignment.center, children: <
            Widget>[
          Container(
            width: MediaQuery.of(context).size.width * 0.5,
            child: TextFormField(
              controller: _emailcontroller,
              keyboardType: const TextInputType.numberWithOptions(),
              // inputFormatters: [
              //   FilteringTextInputFormatter.allow(RegExp(
              //       r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")),
              // ],
              decoration: const InputDecoration(
                icon: Icon(Icons.person),
                hintText: 'JohnDoe@gmail.com',
                labelText: 'Email',
              ),
              onSaved: (String? value) {
                // This optional block of code can be used to run
                // code when the user saves the form.
              },
              // validator: (String? value) {
              //   return (value != null && value.contains('@'))
              //       ? 'Do not use the @ char.'
              //       : null;
              // },
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.5,
            child: TextFormField(
              controller: _passwordcontroller,
              decoration: const InputDecoration(
                icon: Icon(Icons.person),
                hintText: 'I_amAlive',
                labelText: 'Password',
              ),
              onSaved: (String? value) {
                // This optional block of code can be used to run
                // code when the user saves the form.
              },
              // validator: (String? value) {
              //   return (value != null && value.contains('@'))
              //       ? 'Do not use the @ char.'
              //       : null;
              // },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () async {
                    try {
                      var response = await http
                          .post(Uri.parse('http://localhost:3000/'), headers: {
                        "Content-Type": "application/x-www-form-urlencoded"
                      }, body: {
                        'authtype': 'login',
                        'username': _emailcontroller.value.text.toString(),
                        'password': _passwordcontroller.value.text.toString()
                      });

                      if (response.statusCode == 200) {
                        print(response.body);
                      } else {
                        print(json.decode(response.body));
                      }
                    } catch (e) {
                      print(e.toString());
                    }
                  },
                  child: const Text('Log in')),
              SizedBox(
                width: 10,
              ),
              ElevatedButton(
                  onPressed: () async {
                    try {
                      var response = await http
                          .post(Uri.parse('http://localhost:3000/'), headers: {
                        "Content-Type": "application/x-www-form-urlencoded"
                      }, body: {
                        'authtype': 'signup'.toString(),
                        'username': _emailcontroller.value.text.toString(),
                        'password': _passwordcontroller.value.text.toString()
                      });

                      if (response.statusCode == 200) {
                        print(response.body);
                      } else {
                        print(json.decode(response.body));
                      }
                    } catch (e) {
                      print(e.toString());
                    }
                  },
                  child: const Text('Sign up'))
            ],
          ),
        ]),
      ),
    );
  }
}
