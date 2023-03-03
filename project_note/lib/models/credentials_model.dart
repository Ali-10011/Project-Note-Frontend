import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserCredentials {
  //This class will store/load/delete/check the token

  final _secureStorage = const FlutterSecureStorage();
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
}
