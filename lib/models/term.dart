import 'package:cloud_firestore/cloud_firestore.dart';

class Term {
  final String termid;
  final String setid;
  final String front;
  final String back;

  const Term({
    required this.termid,
    required this.setid,
    required this.front,
    required this.back,
  });

  static Term fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Term(
      termid: snapshot["term-id"],
      setid: snapshot["set-id"],
      front: snapshot["front"],
      back: snapshot["back"],
    );
  }

  static Term none() {
    return const Term(
      termid: "",
      setid: "",
      front: "",
      back: "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "term-id": termid,
      "set-id": setid,
      "front": front,
      "back": back,
    };
  }
}
