import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class UserCredentials {
  //This class will store/load/delete/check the token

  final _secureStorage = const FlutterSecureStorage();
  Future<void> saveTokenCredentials(String token, String tokenExpiry) async {
    await _secureStorage.write(key: 'Bearer', value: token);
    await _secureStorage.write(key: 'TokenExpiry', value: tokenExpiry);
  }

  Future<String?> readToken() async {
    var readData = await _secureStorage.read(key: 'Bearer');
    return readData;
  }

  Future<String?> getTokenExpiry() async {
    return await _secureStorage.read(key: 'TokenExpiry');
  }

  Future<bool> isTokenValid() async {
    var tokenExpiry = await getTokenExpiry();
    if (tokenExpiry == null) {
      return false;
    }

    DateTime dateTime = DateTime.parse(tokenExpiry);

    if (dateTime.toLocal().compareTo(DateTime.now()) > 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> deleteTokenCredentials() async {
    await _secureStorage.delete(key: 'Bearer');
    await _secureStorage.delete(key: 'TokenExpiry');
  }
}
