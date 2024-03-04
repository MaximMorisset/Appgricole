import './booking_screen.dart';
import 'package:flutter/material.dart';
import '../services/utils.dart';
import './CRUD/materiel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MaterielListView extends StatefulWidget {
  const MaterielListView({super.key});

  @override
  _MaterielListViewState createState() => _MaterielListViewState();
}

class _MaterielListViewState extends State<MaterielListView> {
  late Stream<QuerySnapshot<Materiel>> _materielsStream;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _materielsStream = DatabaseService().getMateriels();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchTextChanged,
            decoration: const InputDecoration(
              hintText: 'Rechercher...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot<Materiel>>(
            stream: _materielsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Erreur: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('Aucun matériel trouvé'));
              }
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  Materiel materiel = snapshot.data!.docs[index].data();
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingScreen(materielData: materiel),
                        ),
                      );
                    },
                    child: ListTile(
                      title: Text(materiel.nom),
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(materiel.imageUrl),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _onSearchTextChanged(String searchText) {
    setState(() {
      if (searchText.isEmpty) {
        _materielsStream = DatabaseService().getMateriels();
      } else {
        _materielsStream = DatabaseService().searchMateriels(searchText);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
