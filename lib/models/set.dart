import 'package:cloud_firestore/cloud_firestore.dart';

class Set {
  final String setid;
  final String title;
  final String ownerid;
  final String ownerName;
  final String description;
  final DateTime datePublished;
  final List terms;

  const Set({
    required this.setid,
    required this.title,
    required this.ownerid,
    required this.ownerName,
    required this.description,
    required this.datePublished,
    required this.terms,
  });

  static Set fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Set(
      setid: snapshot["set-id"],
      title: snapshot["title"],
      ownerid: snapshot["owner-id"],
      ownerName: snapshot["owner-name"],
      description: snapshot["description"],
      datePublished: snapshot["date-published"],
      terms: snapshot["this.terms"],
    );
  }

  static Set none() {
    return Set(
      setid: "",
      title: "",
      ownerid: "",
      ownerName: "",
      description: "",
      datePublished: DateTime.now(),
      terms: [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "set-id": setid,
      "title": title,
      "owner-id": ownerid,
      "owner-name": ownerName,
      "description": description,
      "date-published": datePublished,
      "terms": terms,
    };
  }
}
