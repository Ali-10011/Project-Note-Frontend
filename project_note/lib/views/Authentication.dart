import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Auth extends StatefulWidget {
  const Auth({Key? key}) : super(key: key);

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  late final TextEditingController _usernamecontroller =
      TextEditingController();
  final TextEditingController _passwordcontroller = TextEditingController();
  bool _hidepassword = true;
  bool _usernamebuttonenabled = false;
  bool _passwordbuttonenabled = false;
  String _warningmessage = '';
  @override
  initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(mainAxisAlignment: MainAxisAlignment.center, children: <
            Widget>[
          Container(
            width: MediaQuery.of(context).size.width * 0.5,
            child: TextFormField(
              controller: _usernamecontroller,
              // inputFormatters: [
              //   FilteringTextInputFormatter.allow(RegExp(
              //       r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")),
              // ],
              decoration: const InputDecoration(
                icon: Icon(Icons.person),
                hintText: 'JohnDoe',
                labelText: 'username',
              ),

              onSaved: (String? value) {
                // This optional block of code can be used to run
                // code when the user saves the form.
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your user name.';
                } else if (value.length < 6) {
                  return 'Username must be of 6 characters or more';
                } else if (value.contains(' ')) {
                  return 'Username cannot contain space character';
                }
                return null;
              },
              onChanged: (value) {
                //Repition of code till I find a better alternative
                setState(() {
                  if (value.length >= 6 &&
                      !value.contains(' ') &&
                      !(value == null || value.isEmpty)) {
                    _usernamebuttonenabled = true;
                  } else {
                    _usernamebuttonenabled = false;
                  }
                });
              },
              textInputAction: TextInputAction.next,
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.5,
            child: TextFormField(
              obscureText: _hidepassword,
              controller: _passwordcontroller,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.person),
                suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _hidepassword = !_hidepassword;
                      });
                    },
                    icon: Icon(Icons.lock)),
                hintText: 'I_amAlive',
                labelText: 'Password',
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password.';
                } else if (value.length < 6) {
                  return 'Length of password must be of 6 characters or more';
                } else if (value.contains(' ')) {
                  return 'Password cannot contain space character';
                }

                return null;
              },
              onChanged: (value) {
                //Repition of code till I find a better alternative
                setState(() {
                  if (value.length >= 6 &&
                      !value.contains(' ') &&
                      !(value == null || value.isEmpty)) {
                    _passwordbuttonenabled = true;
                  } else {
                    _passwordbuttonenabled = false;
                  }
                });
              },
              textInputAction: TextInputAction.next,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          TextButton(onPressed: () {}, child: Text(_warningmessage)),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: _usernamebuttonenabled && _passwordbuttonenabled
                      ? () async {
                          AuthType(
                              'login',
                              _usernamecontroller.value.text.toString(),
                              _passwordcontroller.value.text.toString());
                        }
                      : null,
                  child: const Text('Log in')),
              SizedBox(
                width: 10,
              ),
              ElevatedButton(
                  onPressed: _usernamebuttonenabled && _passwordbuttonenabled
                      ? () async {
                          AuthType(
                              'signup',
                              _usernamecontroller.value.text.toString(),
                              _passwordcontroller.value.text.toString());
                        }
                      : null,
                  child: const Text('Sign up')),
            ],
          ),
        ]),
      ),
    );
  }

  Future<void> AuthType(
      String authtype, String username, String password) async {
    try {
      var response = await http.post(Uri.parse('http://localhost:3000/'),
          headers: {
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: {
            'authtype': authtype,
            'username': username,
            'password': password
          });

      if (response.statusCode == 200) {
        Map<dynamic, dynamic> jsonDecode = json.decode(response.body);
        if (jsonDecode['message'].toString() == "OK") {
          Navigator.pushReplacementNamed(context, '/home');
        }
        setState(() {
          _warningmessage = jsonDecode['message'].toString();
        });
      } else {}
    } catch (e) {
      print(e.toString());
    }
  }
}
