import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:translatr_backend/resources/auth_tings.dart';
import 'package:uuid/uuid.dart';
import 'package:translatr_backend/models/set.dart' as modelset;
import 'package:translatr_backend/models/term.dart' as modelterm;

// TODO: what is static and what is not
class DatabaseTings {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<modelset.Set> downloadSet({required String setid}) async {
    DocumentSnapshot setSnapshot =
        await _firestore.collection('sets').doc(setid).get();
    return modelset.Set.fromSnap(setSnapshot);
  }

  Future<List<modelset.Set>> downloadUserSets({required String userid}) async {
    List setids = AuthTings.currentUser.sets;
    List<modelset.Set> sets = [];
    for (String setid in setids) {
      modelset.Set s = await downloadSet(setid: setid);
      sets.add(s);
    }
    return sets;
  }

  Future<List<modelterm.Term>> extractTermsFromSet({
    required modelset.Set set,
  }) async {
    if (set.setid.isEmpty) return [];
    List<modelterm.Term> terms = [];
    for (String termid in set.terms) {
      DocumentSnapshot termSnapshot = await _firestore
          .collection('sets')
          .doc(set.setid)
          .collection('terms')
          .doc(termid)
          .get();
      terms.add(modelterm.Term.fromSnap(termSnapshot));
    }
    return terms;
  }

  Future<modelset.Set> createAndUploadSet({
    required String title,
    required String description,
    required String userid,
    required String username,
    // required List<String> terms,
  }) async {
    // asking for userid here because we don't want to make extra calls to firebase auth when we can just get it from our state management
    String res = "Some error occurred";
    try {
      // creates unique set id (based on time)
      String setid = const Uuid().v1();
      modelset.Set s = modelset.Set(
        setid: setid,
        title: title,
        ownerid: userid,
        ownerName: username,
        description: description,
        datePublished: DateTime.now(),
        terms: [],
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
      print("error creating new set");
      return modelset.Set.none(); // TODO: improve
    }
  }

  Future<String> updateSet({
    required String setid,
    required String title,
    required String description,
  }) async {
    String res = "Some error occurred";
    try {
      await _firestore
          .collection('sets')
          .doc(setid)
          .update({'title': title, 'description': description});
      res = "success";
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  Future<String> deleteSet({required modelset.Set set}) async {
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
  Future<modelterm.Term> newTermToSet({
    required String front,
    required String back,
    required modelset.Set set,
  }) async {
    String res = "Some error occurred";
    try {
      // creates unique term id (based on time)
      String termId = const Uuid().v1();
      modelterm.Term term = modelterm.Term(
        termid: termId,
        setid: set.setid,
        front: front,
        back: back,
      );
      // add termid to registry in set
      await _firestore.collection('sets').doc(set.setid).update({
        'terms': FieldValue.arrayUnion([termId]),
      });
      // add term to its own document
      await _firestore
          .collection('sets')
          .doc(set.setid)
          .collection('terms')
          .doc(termId)
          .set(term.toMap());
      return term;
    } catch (err) {
      return modelterm.Term.none();
    }
  }

  Future<String> deleteTerm({
    required modelterm.Term term,
  }) async {
    String res = "Some error occurred";
    try {
      await _firestore.collection('sets').doc(term.setid).update({
        'terms': FieldValue.arrayRemove([term.termid]),
      });
      await _firestore
          .collection('sets')
          .doc(term.setid)
          .collection('terms')
          .doc(term.termid)
          .delete();
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  // TODO: implement
  Future<String> editTerm({
    required modelterm.Term term,
    required String front,
    required String back,
  }) async {
    String res = "Some error occurred";
    try {
      await _firestore
          .collection('sets')
          .doc(term.setid)
          .collection('terms')
          .doc(term.termid)
          .update({
        'front': front,
        'back': back,
      });
    } catch (err) {
      return err.toString();
    }
    return res;
  }
}
