import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:translatr_backend/models/appuser.dart' as model;

class AuthTings {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static model.AppUser currentUser = model.AppUser.none();

  // TODO: handle possible errors
  Future<model.AppUser> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot documentSnapshot =
        await _firestore.collection('users').doc(currentUser.uid).get();

    return model.AppUser.fromSnap(documentSnapshot);
  }

  Future<String> registerUser({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
  }) async {
    // check to make sure all fields are entered
    if (firstName.isEmpty ||
        lastName.isEmpty ||
        username.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      return "Please enter all fields.";
    }

    // returned string indicating whether or not operation was successful
    String res = "Some error occurred";

    try {
      // register user with firebase authentication
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      model.AppUser _user = model.AppUser(
        userid: cred.user!.uid,
        firstName: firstName,
        lastName: lastName,
        username: username,
        email: email,
        sets: [],
      );

      // add user to our database
      await _firestore
          .collection("users")
          .doc(cred.user!.uid)
          .set(_user.toMap());

      res = "success";
    } catch (err) {
      return err.toString();
    }

    return res;
  }

  Future<String> authenticateUser({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      return "Please enter all fields.";
    }

    String res = "Some error occurred at authenticateUser method";
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      AuthTings.currentUser = await getUserDetails();
      res = "success";
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
