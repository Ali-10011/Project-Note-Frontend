import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project_note/globals/globals.dart';
import 'package:project_note/models/credentials_model.dart';
import 'package:project_note/views/register_page.dart';
import '../widgets/custom_snackbar.dart';

class Auth extends StatefulWidget {
  const Auth({Key? key}) : super(key: key);

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late final TextEditingController _usernamecontroller= TextEditingController();
   
  late final TextEditingController _passwordcontroller =
      TextEditingController();

  bool _hidepassword = true;
  bool _usernamebuttonenabled = true;
  bool _passwordbuttonenabled = true;
  bool _isLoading = false;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _pushLoadingPage() {
    fireSnackBar(
        "Welcome $sessionUserName !", Colors.green, Colors.white, context);
    Navigator.of(context).pushReplacementNamed('/initial');
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const SignupPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.ease;

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
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple, Colors.blue],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ),
          ),
          child: ListView(
              padding: EdgeInsets.fromLTRB(20, screenHeight * 0.1, 20, 20),
              children: <Widget>[
                RotationTransition(
                  turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
                  child: InkWell(
                    onTap: () {
                      _controller.isCompleted
                          ? _controller.reset()
                          : _controller.forward();
                    },
                    onDoubleTap: () {
                      _controller.isCompleted
                          ? _controller.forward()
                          : _controller.stop();
                    },
                    child: const Center(
                      child: Text(
                        "Note",
                        style: TextStyle(
                            backgroundColor: Colors.transparent, fontSize: 50),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.18,
                ),
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
                const SizedBox(
                  height: 50,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _isLoading
                      ? [const CircularProgressIndicator()]
                      : [
                          ElevatedButton.icon(
                              style: ButtonStyle(
                                elevation: MaterialStateProperty.all(15),
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.blue),
                              ),
                              onPressed: (_usernamebuttonenabled &&
                                      _passwordbuttonenabled)
                                  ? () {
                                      setState(() {
                                        _isLoading = true;
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                      });
                                      loginUser(
                                          _usernamecontroller.value.text
                                              .toString(),
                                          _passwordcontroller.value.text
                                              .toString());
                                    }
                                  : null,
                              icon: const Icon(Icons.login_outlined),
                              label: const Padding(
                                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                child: Text('Log in'),
                              )),
                          const SizedBox(
                            width: 10,
                          ),
                        ],
                ),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(_createRoute());
                    },
                    child: const Text('Sign Up Instead ?')),
              ]),
        ),
      ),
    );
  }

  Future<void> loginUser(String username, String password) async {
    try {
      var response = await http.post(Uri.parse('${apiUrl}auth/login'),
          headers: {"Content-Type": "application/x-www-form-urlencoded"},
          body: {'username': username, 'password': password});
      switch (response.statusCode) {
        case 200:
          {
            Map<dynamic, dynamic> jsonDecode = json.decode(response.body);
            UserCredentials credentialsInstance = UserCredentials();
            credentialsInstance.saveTokenCredentials(
                jsonDecode['token'], jsonDecode['tokenExpiry'], username);
            sessionUserName = username;
            _pushLoadingPage();

            break;
          }
        default:
          fireSnackBar(
              response.body.toString(), Colors.red, Colors.white, context);
      }
    } catch (e) {
      fireSnackBar(e.toString(), Colors.red, Colors.white, context);
    }
    setState(() {
      _isLoading = false;
    });
  }
}
