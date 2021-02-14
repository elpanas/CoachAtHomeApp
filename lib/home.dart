//import 'package:coachapp/coachlist.dart';
import 'package:coachapp/coachlist.dart';
import 'package:coachapp/profile.dart';
import 'package:flutter/material.dart';
import 'package:coachapp/registration.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coach@Home',
      theme: ThemeData(
          primarySwatch: Colors.orange,
          visualDensity: VisualDensity.adaptivePlatformDensity),
      home: Scaffold(body: HomePage()),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final storage = FlutterSecureStorage();
  bool _isreg = false;
  String myID = '';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /*Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Image(image: AssetImage('assets/images/title.png')),
                  ),*/
              FlatButton(
                minWidth: size.width / 1.2,
                color: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => CoachesList()));
                },
                child: Text(
                  'Cerca',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
              FlatButton(
                minWidth: size.width / 1.2,
                color: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                onPressed: () {
                  if (_isreg)
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => Profile(myID)));
                  else
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => RegistrationPage(true)));
                },
                child: Text(
                  'Entra',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
              FlatButton(
                minWidth: size.width / 1.2,
                color: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => RegistrationPage(false)));
                },
                child: Text(
                  'Registrazione',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void checkPin() async {
    try {
      await storage.read(key: 'pin').then((value) => _isreg = (value != null));
      myID = await storage.read(key: 'id');
    } catch (_) {
      // ...
    }
  }
}
