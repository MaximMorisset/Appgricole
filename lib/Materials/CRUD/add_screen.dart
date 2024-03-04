import 'dart:io';

import '../../services/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/checkbox.dart';
import './materiel.dart';

class CRUD extends StatefulWidget {
  const CRUD({Key? key}) : super(key: key);

  @override
  State<CRUD> createState() => _CRUDState();
}

class _CRUDState extends State<CRUD> {
  final TextEditingController _textEditingController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();

  Future<String> _uploadImage(File imageFile) async {
    try {
      // Récupérer une référence vers le dossier de stockage Firebase où vous souhaitez enregistrer l'image
      Reference storageReference =
          FirebaseStorage.instance.ref().child('images').child('materiels');

      // Uploader le fichier image vers Firebase Storage
      UploadTask uploadTask = storageReference.putFile(imageFile);

      // Attendre que le téléchargement soit terminé et récupérer l'URL de l'image téléchargée
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
      String imageUrl = await taskSnapshot.ref.getDownloadURL();

      // Retourner l'URL de l'image téléchargée
      return imageUrl;
    } catch (error) {
      // Gérer les erreurs de téléchargement d'image ici
      print('Erreur lors du téléchargement de l\'image: $error');
      throw error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _appBar(),
      body: _buildUI(),
      floatingActionButton: FloatingActionButton(
        onPressed: _displayTextInputDialog,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      title: const Text(
        "Matériels",
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildUI() {
    return SafeArea(
      child: Column(
        children: [
          _materielsListView(),
        ],
      ),
    );
  }

  Widget _materielsListView() {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.80,
      width: MediaQuery.sizeOf(context).width,
      child: StreamBuilder<QuerySnapshot<Materiel>>(
        stream: _databaseService.getMateriels(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Une erreur est survenue.'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          List<QueryDocumentSnapshot<Materiel>> materiels = snapshot.data!.docs;
          if (materiels.isEmpty) {
            return Center(
              child: Text("Ajouter un Matériel"),
            );
          }

          return ListView.builder(
            itemCount: materiels.length,
            itemBuilder: (context, index) {
              QueryDocumentSnapshot<Materiel> materielSnapshot =
                  materiels[index];
              Materiel materiel = materielSnapshot.data();
              String materielId = materielSnapshot.id;

              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 10,
                ),
                child: ListTile(
                  tileColor: Theme.of(context).colorScheme.primaryContainer,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 100,
                        width: double.infinity,
                        child: Image.network(
                          materiel.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        materiel.nom,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Problème : ${materiel.probleme ? 'Oui' : 'Non'}',
                        style: TextStyle(
                          color: materiel.probleme ? Colors.red : Colors.green,
                        ),
                      )
                    ],
                  ),
                  subtitle: Text(
                    "Mise à Jour : ${DateFormat("dd/MM/yyyy h:mm").format(materiel.updatedOn.toDate())}",
                  ),
                  onTap: () {
                    _displayChoiceInputDialog(context, materiel, materielId);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _displayTextInputDialog() async {
    // Afficher une boîte de dialogue pour ajouter un nouveau matériel
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ajouter un Matériel'),
          content: TextField(
            controller: _textEditingController,
            decoration: const InputDecoration(
              hintText: "Nom du Matériel...",
            ),
          ),
          actions: <Widget>[
            // Bouton pour sélectionner une image depuis la galerie
            MaterialButton(
              color: Theme.of(context).colorScheme.primary,
              textColor: Colors.white,
              child: const Icon(Icons.upload),
              onPressed: () async {
                // Sélectionner une image depuis la galerie
                File? selectedImage = await getImageFromGallery(context);
                if (selectedImage != null) {
                  // Passer le fichier image sélectionné à la méthode _uploadImage
                  String imageUrl = await _uploadImage(selectedImage);
                  // Ajouter le matériel avec l'URL de l'image
                  _addMaterielWithImage(imageUrl);
                }
              },
            ),
            // Bouton pour ajouter un matériel sans image
            MaterialButton(
              color: Theme.of(context).colorScheme.primary,
              textColor: Colors.white,
              child: const Text('Ok'),
              onPressed: () async {
                String nom = _textEditingController.text;
                if (nom.isNotEmpty) {
                  // Ajouter le matériel sans image
                  try {
                    await _databaseService.addMateriels(
                      nom: nom,
                      imageUrl: '', // Définir l'URL de l'image comme vide
                      probleme: false,
                      updatedOn: Timestamp.now(),
                    );
                    // Fermer la boîte de dialogue
                    Navigator.pop(context);
                    _textEditingController.clear();
                  } catch (e) {
                    print(
                        'Une erreur est survenue lors de l\'ajout du matériel: $e');
                    // Gérer les erreurs d'ajout du matériel
                  }
                } else {
                  // Gérer le cas où aucun nom de matériel n'est saisi
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Veuillez saisir un nom de matériel.'),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _addMaterielWithImage(String imageUrl) async {
    String nom = _textEditingController.text;
    if (nom.isNotEmpty) {
      try {
        await _databaseService.addMateriels(
          nom: nom,
          imageUrl: imageUrl,
          probleme: false,
          updatedOn: Timestamp.now(),
        );
        // Fermer la boîte de dialogue
        Navigator.pop(context);
        _textEditingController.clear();
      } catch (e) {
        print('Une erreur est survenue lors de l\'ajout du matériel: $e');
        // Gérer les erreurs d'ajout du matériel
      }
    } else {
      // Gérer le cas où aucun nom de matériel n'est saisi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez saisir un nom de matériel.'),
        ),
      );
    }
  }

  void _displayChoiceInputDialog(
      BuildContext context, Materiel materiel, String materielId) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Supprimer ou Modifier"),
          actions: <Widget>[
            MaterialButton(
              color: Theme.of(context).colorScheme.primary,
              textColor: Colors.white,
              child: const Icon(Icons.delete),
              onPressed: () {
                _databaseService.deleteMateriel(materielId);
                Navigator.pop(context);
              },
            ),
            MaterialButton(
              color: Theme.of(context).colorScheme.primary,
              textColor: Colors.white,
              child: const Icon(Icons.edit),
              onPressed: () {
                Navigator.pop(context);
                _displayEditDialog(context, materiel, materielId);
              },
            ),
          ],
        );
      },
    );
  }

  void _displayEditDialog(
      BuildContext context, Materiel materiel, String materielId) {
    TextEditingController nomController =
        TextEditingController(text: materiel.nom);
    bool probleme = materiel.probleme;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Modifier Matériel"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Nom :"),
              TextField(
                controller: nomController,
                decoration: const InputDecoration(
                  hintText: "Entrez un nouveau nom",
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text("Problème :"),
                  CheckboxWidget(
                    initialValue: probleme,
                    onChanged: (value) {
                      setState(() {
                        probleme = value;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: <Widget>[
            MaterialButton(
              color: Theme.of(context).colorScheme.primary,
              textColor: Colors.white,
              child: const Text('Modifier'),
              onPressed: () async {
                String nom = nomController.text;
                if (nom.isNotEmpty) {
                  try {
                    // Mettre à jour le matériel dans la base de données
                    _databaseService.updateMateriel(
                      materielId,
                      Materiel(
                        nom: nom,
                        probleme: probleme,
                        updatedOn: Timestamp.now(),
                        imageUrl:
                            materiel.imageUrl, // Conserver l'URL de l'image
                      ),
                    );
                    Navigator.pop(context);
                  } catch (e) {
                    print(
                        'Une erreur est survenue lors de la mise à jour du matériel: $e');
                    // Gérer l'erreur ici
                  }
                } else {
                  // Gérer le cas où aucun nom de matériel n'est saisi
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Veuillez saisir un nom de matériel.'),
                  ));
                }
              },
            ),
          ],
        );
      },
    );
  }
}
