import './CRUD/materiel.dart';
import './CRUD/reservation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({Key? key, required this.materielData}) : super(key: key);

  final Materiel materielData;

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late List<Reservation> reservations = []; // Liste pour stocker les réservations

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.materielData.nom),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            alignment: Alignment.center,
            child: Image.network(
              widget.materielData.imageUrl, // URL de l'image du matériel
              width: 200, // Largeur de l'image
              height: 200, // Hauteur de l'image
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('reservation').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Une erreur s\'est produite: ${snapshot.error}'),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Nom')),
                      DataColumn(label: Text('Date de Prise')),
                      DataColumn(label: Text('Date de Remise')),
                      DataColumn(label: Text('Surf Prev')),
                      DataColumn(label: Text('Problème')),
                    ],
                    rows: _buildRows(snapshot.data!.docs),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          DateTime firstDate = DateTime.now();
          DateTime? pickedStartDate = await showRoundedDatePicker(
            context: context,
            initialDate: firstDate,
            firstDate: firstDate,
            lastDate: DateTime(2100),
            borderRadius: 16,
          );
          if (pickedStartDate != null) {
            DateTime? pickedEndDate = await showRoundedDatePicker(
              context: context,
              initialDate: pickedStartDate,
              firstDate: pickedStartDate,
              lastDate: DateTime(2100),
              borderRadius: 16,
            );
            if (pickedEndDate != null) {
              // Afficher un dialogue pour entrer la surface
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  double surface = 0.0;
                  return AlertDialog(
                    title: const Text("Surface"),
                    content: TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: "Entrez la surface (en m²)",
                      ),
                      onChanged: (value) {
                        surface = double.tryParse(value) ?? 0.0;
                      },
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Annuler'),
                      ),
                      TextButton(
                        onPressed: () {
                          // Effectuer la réservation et l'enregistrer dans Firestore
                          makeReservation(
                            pickedStartDate,
                            pickedEndDate,
                            widget.materielData.id,
                            surface,
                          );
                          Navigator.of(context).pop();
                        },
                        child: const Text('Confirmer'),
                      ),
                    ],
                  );
                },
              );
            }
          }
        },
        child: const Icon(Icons.calendar_today),
      ),
    );
  }

  // Fonction pour enregistrer une réservation dans Firestore
  Future<void> makeReservation(DateTime startDate, DateTime endDate, String materielId, double surface) async {
    try {
      // Convertir les dates en format Timestamp pour Firestore
      Timestamp startTimestamp = Timestamp.fromDate(startDate);
      Timestamp endTimestamp = Timestamp.fromDate(endDate);

      // Enregistrer la réservation dans la collection "reservation" de Firestore
      await FirebaseFirestore.instance.collection('reservation').add({
        'userName': FirebaseAuth.instance.currentUser?.email, // Nom d'utilisateur = mail de l'utilisateur connecté
        'startDate': startTimestamp,
        'endDate': endTimestamp,
        'surface': surface,
        'problems': widget.materielData.probleme, // Problèmes = problème trouvé dans la table de matériel
        'materielId': materielId, // ID du matériel
      });

      // Afficher un message de confirmation à l'utilisateur
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Votre réservation a été enregistrée avec succès !"),
        ),
      );
    } catch (e) {
      // Afficher un message d'erreur en cas d'échec de l'enregistrement de la réservation
      print("Erreur lors de l'enregistrement de la réservation: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Une erreur s'est produite lors de l'enregistrement de la réservation."),
        ),
      );
    }
  }

  // Fonction pour formater la date (enlever les heures)
  String formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  List<DataRow> _buildRows(List<QueryDocumentSnapshot> documents) {
    return documents.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return DataRow(
        cells: [
          DataCell(Text(data['userName'].toString())),
          DataCell(Text(formatDate((data['startDate'] as Timestamp).toDate()))),
          DataCell(Text(formatDate((data['endDate'] as Timestamp).toDate()))),
          DataCell(Text(data['surface'].toString())),
          DataCell(data['problems'] ?  const Icon(Icons.close, color: Colors.red) : const Icon(Icons.check, color: Colors.green)),
        ],
      );
    }).toList();
  }
}
