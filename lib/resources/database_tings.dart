import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:translatr_backend/resources/auth_tings.dart';
import 'package:uuid/uuid.dart';
import 'package:translatr_backend/models/set.dart' as model;

// TODO: what is static and what is not
class DatabaseTings {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<model.Set> downloadSet({required String setid}) async {
    DocumentSnapshot documentSnapshot =
        await _firestore.collection('sets').doc(setid).get();
    return model.Set.fromSnap(documentSnapshot);
  }

  Future<List<model.Set>> downloadUserSets({required String userid}) async {
    List setids = AuthTings.currentUser.sets;
    List<model.Set> sets = [];
    for (String setid in setids) {
      model.Set s = await downloadSet(setid: setid);
      sets.add(s);
    }
    return sets;
  }

  // TODO: exc
  Map<String, String> extractTermsFromSet({required model.Set s}) {
    return (s.terms as Map<String, String>);
  }

  Future<model.Set> createAndUploadSet({
    required String title,
    required String description,
    required String userid,
    required String username,
    required List<String> terms,
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
        terms: terms,
      );

      // add set to local user
      AuthTings.currentUser.sets.add(setid);

      // add set to database
      _firestore.collection('sets').doc(setid).set(s.toMap());

      // add set id to user document in database
      _firestore.collection('users').doc(userid).update({
        'sets': FieldValue.arrayUnion([setid]),
      });

      return s;
    } catch (err) {
      return model.Set.none(); // TODO: improve
    }
  }

  Future<String> updateSet({
    required String setid,
    required String title,
    required String description,
    required List<String> terms,
  }) async {
    String res = "Some error occurred";
    try {
      await _firestore.collection('sets').doc(setid).update({
        'title': title,
        'description': description,
        'terms': terms,
      });
      res = "success";
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  Future<String> deleteSet({required model.Set set}) async {
    String res = "Some error occurred";
    try {
      // remove set from local user
      AuthTings.currentUser.sets.remove(set.setid);
      // remove set from database
      await _firestore.collection('sets').doc(set.setid).delete();
      await _firestore.collection('users').doc(set.ownerid).update({
        'sets': FieldValue.arrayRemove([set.setid]),
      }); // TODO: is there a more efficient way of doing this?
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // TODO: make this work
  Future<String> addTermToSet({
    required String front,
    required String back,
    required model.Set s,
  }) async {
    String res = "Some error occurred";
    try {
      await _firestore.collection('sets').doc(s.setid).update({
        'terms': FieldValue.arrayUnion([front]),
      });
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  Future<String> removeTermFromSet({
    required String front,
    required model.Set s,
  }) async {
    String res = "Some error occurred";
    try {
      await _firestore
          .collection('sets')
          .doc(s.setid)
          .collection('terms')
          .doc(front)
          .delete();
    } catch (err) {
      return err.toString();
    }
    return res;
  }
}
