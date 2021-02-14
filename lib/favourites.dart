import 'package:coachapp/models/coach.dart';
import 'package:coachapp/models/coach_db.dart';
import 'package:coachapp/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Favourites extends StatefulWidget {
  @override
  _FavouritesState createState() => _FavouritesState();
}

class _FavouritesState extends State<Favourites> {
  final storage = FlutterSecureStorage();
  final TextEditingController searchController = TextEditingController();
  CoachDb db;
  int id;
  String _message = '';
  List<Coach> coaches = List<Coach>();

  @override
  void initState() {
    db = CoachDb();
    loadCoaches();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Preferiti')),
        body: Column(
          children: <Widget>[
            if (_message != '')
              Expanded(
                child: Container(
                  alignment: Alignment.bottomCenter,
                  child: Text(_message),
                ),
              ),
            Container(),
            Expanded(
                child: FutureBuilder(
                    future: loadCoaches(),
                    builder: (BuildContext context,
                        AsyncSnapshot<dynamic> snapshot) {
                      List<Coach> lista = snapshot.data;
                      return ListView.builder(
                        itemCount: (lista == null) ? 0 : lista.length,
                        itemBuilder: (_, index) {
                          return Card(
                              elevation: 2,
                              child: Dismissible(
                                  key: Key(lista[index].idb.toString()),
                                  onDismissed: (_) {
                                    db.eliminaCoach(lista[index].idb);
                                  },
                                  child: ListTile(
                                    title: Text(lista[index].name ?? ''),
                                    subtitle: Text(lista[index].city ?? ''),
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  Profile(lista[index].id)));
                                    },
                                  )));
                        },
                      );
                    })),
          ],
        ));
  }

  Future loadCoaches() async {
    List<Coach> coaches = await db.leggiCoaches();
    setState(() {
      if (coaches.isEmpty) _message = 'Non hai preferiti';
    });
    return coaches;
  }
}
