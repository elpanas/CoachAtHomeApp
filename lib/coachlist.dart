import 'dart:convert';
import 'dart:io';
import 'package:coachapp/favourites.dart';
import 'package:coachapp/globals.dart';
import 'package:coachapp/models/coach.dart';
import 'package:coachapp/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class CoachesList extends StatefulWidget {
  @override
  _CoachesListState createState() => _CoachesListState();
}

class _CoachesListState extends State<CoachesList> {
  final storage = FlutterSecureStorage();
  final TextEditingController searchController = TextEditingController();
  String _message = '';
  bool isreg = false;
  bool _showProgress = true;
  String myID = '';
  String username = '';
  List<Coach> coaches = List<Coach>();

  @override
  void initState() {
    checkPin();
    loadCoaches();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: Drawer(
            child: ListView(padding: EdgeInsets.zero, children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
                color: Colors.orange,
                image: DecorationImage(
                    fit: BoxFit.fitWidth,
                    image: AssetImage('assets/images/backdraw.png'))),
            child: Stack(children: <Widget>[
              Positioned(
                  bottom: 12.0,
                  child: Text('Ciao ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                      ))),
            ]),
          ),
          if (isreg)
            ListTile(
              leading: Icon(Icons.account_box),
              title: Text('Il Mio Profilo'),
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => Profile(myID))),
            ),
          ListTile(
              leading: Icon(Icons.favorite),
              title: Text('Preferiti'),
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => Favourites())))
        ])),
        appBar: AppBar(title: Text('PT nella tua zona')),
        body: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (_) => searchCoaches(searchController.text),
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Cerca...',
                  hintStyle: TextStyle(fontSize: 14),
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            if (_message != '')
              Expanded(
                child: Container(
                  alignment: Alignment.bottomCenter,
                  child: Text(_message),
                ),
              ),
            if (_showProgress) _buildLoader(),
            Expanded(
                child: ListView.builder(
              itemCount: coaches.length,
              itemBuilder: ((BuildContext context, int index) {
                return Card(
                  elevation: 2,
                  child: ListTile(
                    title: Text(coaches[index].name),
                    subtitle: Text(coaches[index].city),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  Profile(coaches[index].id)));
                    },
                  ),
                );
              }),
            )),
          ],
        ));
  }

  Widget _buildLoader() {
    return Expanded(
      child: SizedBox(
        height: MediaQuery.of(context).size.height / 1.3,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  void checkPin() async {
    try {
      await storage.read(key: 'pin').then((value) => isreg = (value != null));
      myID = await storage.read(key: 'id');
      username = await storage.read(key: 'username');
    } catch (_) {
      isreg = false;
    }
  }

  Future loadCoaches() async {
    Position position = await Geolocator.getLastKnownPosition();
    if (position == null) position = await Geolocator.getCurrentPosition();
    final latitude = position.latitude.toString();
    final longitude = position.longitude.toString();
    final params = '/latitude/' + latitude + '/longitude/' + longitude;
    final res = await http
        .get(url + 'coach' + params)
        .timeout(Duration(seconds: 2), onTimeout: () {
      setState(() => {_showProgress = false, _message = "Non ho trovato PT"});
      return null;
    });
    if (res != null) {
      if (res.statusCode == HttpStatus.ok) {
        final resJson = jsonDecode(res.body);
        coaches = resJson.map<Coach>((data) => Coach.fromJson(data)).toList();
        setState(() => {coaches = coaches, _showProgress = false});
      } else {
        setState(() => {_message = "Non ho trovato PT", _showProgress = false});
      }
    }
  }

  void searchCoaches(search) {
    if (search != '')
      setState(() => coaches =
          coaches.where((element) => element.name.startsWith(search)).toList());
    else
      loadCoaches();
  }
}
