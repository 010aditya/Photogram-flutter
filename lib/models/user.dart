import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String username;
  final String id;
  final String bio;
  final String displayName;
  final String photoUrl;
  final String email;

  User(
      {this.id,
      this.username,
      this.email,
      this.photoUrl,
      this.displayName,
      this.bio});

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
        id: doc["id"],
        username: doc["username"],
        photoUrl: doc["photoUrl"],
        email: doc["email"],
        bio: doc["bio"],
        displayName: doc['displayName']);
  }
}
