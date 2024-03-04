/*import 'package:Appgricool/Materials/booking_screen.dart';
import 'package:Appgricool/services/utils.dart';
import 'package:flutter/material.dart';
import 'package:Appgricool/Materials/CRUD/add.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MaterielListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Materiel>>(
      stream: DatabaseService().getMateriels(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('Aucun matériel trouvé'));
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            Materiel materiel = snapshot.data!.docs[index].data();
            return InkWell(
              splashColor: Colors.transparent,
              onTap: () {
                  Navigator.push(context,MaterialPageRoute(builder: (context) => BookingScreen(materielData:materiel)));
                  
              },
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.6),
                      offset: Offset(4, 4),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(
                          materiel.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          materiel.nom,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}*/
import './booking_screen.dart';
import 'package:flutter/material.dart';
import '../services/utils.dart';
import './CRUD/materiel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MaterielListView extends StatefulWidget {
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
            decoration: InputDecoration(
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
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Erreur: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('Aucun matériel trouvé'));
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
