import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
//import 'package:firebase_core/firebase_core.dart ' as firebase_core;
import 'package:firebase_core/firebase_core.dart' as firebase_core;

class Storage {
  final firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instanceFor(
          bucket: "gs://project-note-bca4a.appspot.com");

  Future<void> uploadfile(String filePath, String fileName) async {
    File file = File(filePath);
    try {
      await storage.ref('Images/$fileName').putFile(file);
    } on firebase_core.FirebaseException catch (e) {
      print(e);
    }
  }

  Future<String> downloadURL(String imageName) async {
    try {
      String downloadURL = await storage.ref('Images/${imageName}').getDownloadURL();
      return downloadURL;
    } on firebase_core.FirebaseException catch (e) {
      print(e);
      throw Exception('Firebase Error: ${e}');
    }
  }
}
