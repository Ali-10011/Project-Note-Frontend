import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
//import 'package:firebase_core/firebase_core.dart ' as firebase_core;
import 'package:firebase_core/firebase_core.dart' as firebase_core;

class Storage {
  final firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instanceFor(
          bucket: "gs://project-note-bca4a.appspot.com");

  Future<String> uploadfile(String filePath, String fileName) async {
    final imageref = storage.ref('Images/${fileName}');
    File file = File(filePath);

    try {
      await imageref.putFile(file);
      String url = await imageref.getDownloadURL();
      return url;
    } on firebase_core.FirebaseException catch (e) {
      print(e);
      throw Exception('Firebase Error: ${e}');
    }
  }

  Future<String> downloadURL(String imageName) async {
    try {
      String downloadURL =
          await storage.ref('Images/${imageName}').getDownloadURL();
      return downloadURL;
    } on firebase_core.FirebaseException catch (e) {
      print(e);
      throw Exception('Firebase Error: ${e}');
    }
  }
}
