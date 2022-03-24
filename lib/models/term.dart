import 'package:cloud_firestore/cloud_firestore.dart';

class Term {
  final String termId;
  final String front;
  final String back;

  const Term({
    required this.termId,
    required this.front,
    required this.back,
  });

  static Term fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Term(
      termId: snapshot["term-id"],
      front: snapshot["front"],
      back: snapshot["back"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "term-id": termId,
      "front": front,
      "back": back,
    };
  }
}
