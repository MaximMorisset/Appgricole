import 'dart:io';

import '../Materials/CRUD/materiel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gallery_picker/gallery_picker.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late final CollectionReference<Materiel> _materielsRef;

  DatabaseService() {
    _materielsRef = _firestore.collection('materiels').withConverter<Materiel>(
          fromFirestore: (snapshot, _) => Materiel.fromFirestore(snapshot),
          toFirestore: (materiel, _) => materiel.toJson(),
        );
  }

  Stream<QuerySnapshot<Materiel>> getMateriels() {
    return _materielsRef.snapshots();
  }

  Future<void> addMateriels({
    required String nom,
    required String imageUrl,
    required bool probleme,
    required Timestamp updatedOn,
  }) async {
    try {
      await _materielsRef.add(Materiel(
        nom: nom,
        imageUrl: imageUrl,
        probleme: probleme,
        updatedOn: updatedOn,
      ));
    } catch (e) {
      print(e);
      throw Exception(
          'Une erreur s\'est produite lors de l\'ajout du matériel');
    }
  }

  Future<void> updateMateriel(
      String materielId, Materiel updatedMateriel) async {
    try {
      await FirebaseFirestore.instance
          .collection('materiels')
          .doc(materielId)
          .update({
        'nom': updatedMateriel.nom,
        'probleme': updatedMateriel.probleme,
        'updatedOn': updatedMateriel.updatedOn,
        // Gardez l'URL de l'image inchangée
      });
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du matériel: $e');
    }
  }

  void deleteMateriel(String materielId) async {
    try {
      await _materielsRef.doc(materielId).delete();
    } catch (e) {
      print(e);
      throw Exception(
          'Une erreur s\'est produite lors de la suppression du matériel');
    }
  }

  Stream<QuerySnapshot<Materiel>> searchMateriels(String searchText) {
    return _materielsRef
        .where('nom', isGreaterThanOrEqualTo: searchText)
        .where('nom', isLessThan: searchText + 'z')
        .snapshots();
  }
}

Future<File?> getImageFromGallery(BuildContext context) async {
  try {
    List<MediaFile>? singleMedia =
        await GalleryPicker.pickMedia(context: context, singleMedia: true);
    return singleMedia?.first.getFile();
  } catch (e) {
    print(e);
    throw Exception(
        'Une erreur s\'est produite lors de la sélection de l\'image');
  }
}
