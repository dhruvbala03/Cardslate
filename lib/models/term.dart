import 'package:cloud_firestore/cloud_firestore.dart';

class Term {
  final String termId;
  final String setId;
  final String front;
  final String back;

  const Term({
    required this.termId,
    required this.setId,
    required this.front,
    required this.back,
  });

  static Term fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Term(
      termId: snapshot["term-id"],
      setId: snapshot["set-id"],
      front: snapshot["front"],
      back: snapshot["back"],
    );
  }

  static Term none() {
    return const Term(
      termId: "",
      setId: "",
      front: "",
      back: "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "term-id": termId,
      "set-id": setId,
      "front": front,
      "back": back,
    };
  }
}
