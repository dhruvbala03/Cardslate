import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:translatr_backend/resources/auth_tings.dart';
import 'package:uuid/uuid.dart';
import 'package:translatr_backend/models/set.dart' as model;

class DatabaseTings {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<model.Set> downloadSet({required String setid}) async {
    DocumentSnapshot documentSnapshot =
        await _firestore.collection('sets').doc(setid).get();
    return model.Set.fromSnap(documentSnapshot);
  }

  Future<List<model.Set>> downloadUserSets({required String userid}) async {
    List<String> setids = AuthTings.currentUser.sets as List<String>;
    List<model.Set> sets = [];
    for (String setid in setids) {
      model.Set s = await downloadSet(setid: setid);
      sets.add(s);
    }
    return sets;
  }

  Future<model.Set> createAndUploadSet({
    required String title,
    required String description,
    required String userid,
    required String username,
  }) async {
    // asking for userid here because we don't want to make extra calls to firebase auth when we can just get it from our state management
    String res = "Some error occurred";
    try {
      // creates unique set id (based on time)
      String setid = const Uuid().v1();
      model.Set s = model.Set(
        setid: setid,
        title: title,
        ownerid: userid,
        ownerName: username,
        description: description,
        datePublished: DateTime.now(),
        terms: [],
      );

      // add set to database
      _firestore.collection('sets').doc(setid).set(s.toJson());

      // add set id to user document in database
      _firestore.collection('users').doc(userid).update({
        'sets': FieldValue.arrayUnion([setid]),
      });

      return s;
    } catch (err) {
      return model.Set.none();
    }
    return model.Set.none(); // TODO: improve
  }

  Future<String> updateSet({
    required String setid,
    required String title,
    required String description,
  }) async {
    String res = "Some error occurred";
    try {
      await _firestore.collection('sets').doc(setid).update({
        'title': title,
        'description': description,
      });
      res = "success";
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  Future<String> deleteSet({required String setid}) async {
    String res = "Some error occurred";
    try {
      await _firestore.collection('posts').doc(setid).delete();
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> addTermToSet({
    required String front,
    required String back,
    required String setid,
  }) async {
    String res = "Some error occurred";
    try {
      await _firestore.collection('sets').doc(setid).update({
        'terms': FieldValue.arrayUnion([
          {front: back}
        ]),
      });
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  Future<String> addTermsToSet({
    required List<Map<String, String>> terms,
    required String setid,
  }) async {
    String res = "Some error occurred";
    try {
      await _firestore.collection('sets').doc(setid).update({
        'terms': FieldValue.arrayUnion(terms),
      });
    } catch (err) {
      return err.toString();
    }
    return res;
  }
}
