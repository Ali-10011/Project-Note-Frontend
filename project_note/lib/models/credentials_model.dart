import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserCredentials {
  //This class will store/load/delete/check the token

  final _secureStorage = const FlutterSecureStorage();
  late String username;

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: 'Bearer', value: token);
  }

  Future<String?> readToken() async {
    var readData = await _secureStorage.read(key: 'Bearer');
    return readData;
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: 'Bearer');
  }

  void setUsername(String username) {
    this.username = username;
  }

  String getUsername() {
    return username;
  }

  Future<void> logoutUser() async {
    //Delete all shared preferences and logout user
    deleteToken();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
  }
}
