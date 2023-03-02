import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project_note/models/credentials_model.dart';

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
  bool _isLoading = false;

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(mainAxisAlignment: MainAxisAlignment.center, children: <
            Widget>[
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.75,
            child: TextFormField(
              controller: _usernamecontroller,
              // inputFormatters: [
              //   FilteringTextInputFormatter.allow(RegExp(
              //       r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")),
              // ],
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.person),
                hintText: 'JohnDoe',
                labelText: 'username',
              ),

              onSaved: (String? value) {
                // This optional block of code can be used to run
                // code when the user saves the form.
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (value == null) {
                  return 'Please enter your user name.';
                } else if (value.length < 6) {
                  return 'Username must be of 6 characters or more';
                } else if (value.contains(' ')) {
                  return 'Username cannot contain space character';
                }
                return null;
              },
              onChanged: (username) {
                //Repition of code till I find a better alternative

                setState(() {
                  _warningmessage = '';
                  if (username.length >= 6 &&
                      !username.contains(' ') &&
                      (username.isNotEmpty)) {
                    _usernamebuttonenabled = true;
                  } else {
                    _usernamebuttonenabled = false;
                  }
                });
              },
              textInputAction: TextInputAction.next,
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.75,
            child: TextFormField(
              obscureText: _hidepassword,
              controller: _passwordcontroller,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.password),
                suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _hidepassword = !_hidepassword;
                      });
                    },
                    icon: const Icon(Icons.lock)),
                hintText: 'I_amAlive',
                labelText: 'password',
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (value == null) {
                  return 'Please enter your password.';
                } else if (value.length < 6) {
                  return 'Length of password must be of 6 characters or more';
                } else if (value.contains(' ')) {
                  return 'Password cannot contain space character';
                }

                return null;
              },
              onChanged: (value) {
                _warningmessage = '';
                setState(() {
                  if (value.length >= 6 &&
                      !value.contains(' ') &&
                      (value.isNotEmpty)) {
                    _passwordbuttonenabled = true;
                  } else {
                    _passwordbuttonenabled = false;
                  }
                });
              },
              textInputAction: TextInputAction.next,
            ),
          ),
          TextButton(
              onPressed: () {},
              child: Text(
                _warningmessage,
                style: const TextStyle(color: Colors.redAccent),
              )),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _isLoading
                ? [const CircularProgressIndicator()]
                : [
                    ElevatedButton(
                        onPressed: (_usernamebuttonenabled &&
                                _passwordbuttonenabled)
                            ? () {
                                setState(() {
                                  _isLoading = true;
                                  FocusManager.instance.primaryFocus?.unfocus();
                                });
                                loginUser(
                                    _usernamecontroller.value.text.toString(),
                                    _passwordcontroller.value.text.toString());
                              }
                            : null,
                        child: const Text('Log in')),
                    const SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                        onPressed: (_usernamebuttonenabled &&
                                _passwordbuttonenabled)
                            ? () {
                                setState(() {
                                  _isLoading = true;
                                  FocusManager.instance.primaryFocus?.unfocus();
                                });
                                registerUser(
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

  Future<void> loginUser(String username, String password) async {
    try {
      var response = await http.post(
          Uri.parse('http://localhost:3000/api/auth/login'),
          headers: {"Content-Type": "application/x-www-form-urlencoded"},
          body: {'username': username, 'password': password});
      switch (response.statusCode) {
        case 200:
          Map<dynamic, dynamic> jsonDecode = json.decode(response.body);
          UserCredentials credentialsInstance = UserCredentials();
          credentialsInstance.saveToken(jsonDecode['token']);

          break;
        default:
          setState(() {
            _warningmessage = response.body.toString();
          });
      }
    } catch (e) {
      //Report Error to User
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> registerUser(String username, String password) async {
    try {
      var response = await http.post(
          Uri.parse('http://localhost:3000/api/auth/register'),
          headers: {"Content-Type": "application/x-www-form-urlencoded"},
          body: {'username': username, 'password': password});
      switch (response.statusCode) {
        case 200:
          Map<dynamic, dynamic> jsonDecode = json.decode(response.body);
          UserCredentials credentialsInstance = UserCredentials();
          credentialsInstance.saveToken(jsonDecode['token']);

          break;
        default:
          setState(() {
            _warningmessage = response.body.toString();
          });
      }
    } catch (e) {
      //Report Error to User
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
    }
    setState(() {
      _isLoading = false;
    });
  }
}
