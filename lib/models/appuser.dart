import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String userid;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final List sets;

  const AppUser({
    required this.userid,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.sets,
  });

  static AppUser fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return AppUser(
      userid: snapshot["user-id"],
      firstName: snapshot["first-name"],
      lastName: snapshot["last-name"],
      username: snapshot["username"],
      email: snapshot["email"],
      sets: snapshot["sets"],
    );
  }

  static AppUser none() {
    return const AppUser(
      userid: "",
      firstName: "",
      lastName: "",
      username: "",
      email: "",
      sets: [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "user-id": userid,
      "first-name": firstName,
      "last-name": lastName,
      "username": username,
      "email": email,
      "sets": sets,
    };
  }
}
