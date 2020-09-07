import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

final usersRef = Firestore.instance.collection('users');
final postRef = Firestore.instance.collection('posts');
final commentsRef = Firestore.instance.collection('comments');
final feedRef = Firestore.instance.collection('feeds');
final followersRef = Firestore.instance.collection('followers');
final followingsRef = Firestore.instance.collection('following');
final timelineRef = Firestore.instance.collection('timeline');
final StorageReference storageRef = FirebaseStorage.instance.ref();

updateUsers(String docId) async {
  final DocumentSnapshot doc = await usersRef.document(docId).get();
  if (doc.exists) {
    doc.reference.updateData({
      "username": "Aditya 01",
      "isAdmin": true,
      "postCount": 05,
    });
  }
}

createUser(String docId) async {
  final DocumentSnapshot doc = await usersRef.document(docId).get();
  doc.reference.setData({
    "username": "Aditya 010",
    "isAdmin": true,
    "postCount": 05,
  });
}

deleteUser(String docId) async {
  final DocumentSnapshot doc = await usersRef.document(docId).get();
  if (doc.exists) {
    doc.reference.delete();
  }
}
