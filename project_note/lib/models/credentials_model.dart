import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:project_note/globals/globals.dart';

class UserCredentials {
  //This class will store/load/delete/check the token

  final _secureStorage = const FlutterSecureStorage();
  Future<void> saveTokenCredentials(
      String token, String tokenExpiry, String userName) async {
    await _secureStorage.write(key: 'Username', value: userName);
    await _secureStorage.write(key: 'Bearer', value: token);
    await _secureStorage.write(key: 'TokenExpiry', value: tokenExpiry);
    
  }

  Future<String?> readToken() async {
    var readData = await _secureStorage.read(key: 'Bearer');
    return readData;
  }

  Future<String?> getUserName() async {
    return await _secureStorage.read(key: 'Username');
   
  }

  Future<String?> getTokenExpiry() async {
    return await _secureStorage.read(key: 'TokenExpiry');
  }

  Future<void> setSessionUserName() async {
    sessionUserName = await getUserName() ?? "Guest";
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
    await _secureStorage.delete(key: 'Username');
  }
}
