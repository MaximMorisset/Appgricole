import 'package:cloud_firestore/cloud_firestore.dart';

class Materiel {
  final String nom;
  final String imageUrl;
  final bool probleme;
  final Timestamp updatedOn;
  late final String _id;

  Materiel({
    required this.nom,
    required this.imageUrl,
    required this.probleme,
    required this.updatedOn,
  });

  factory Materiel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    Map<String, dynamic> data = snapshot.data()!;
    return Materiel(
      nom: data['nom'],
      imageUrl: data['imageUrl'],
      probleme: data['probleme'],
      updatedOn: data['updatedOn'],
    ).._id = snapshot.id;
  }

  String get id => _id;

  Map<String, Object?> toJson() {
    return {
      'nom': nom,
      'probleme': probleme,
      'updatedOn': updatedOn,
      'imageUrl': imageUrl,
    };
  }
}