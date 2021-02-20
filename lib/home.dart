import 'package:coachapp/coachlist.dart';
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
      home: HomePage(),
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
  void initState() {
    checkPin();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FlatButton(
                  minWidth: size.width / 1.2,
                  color: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => CoachesList()),
                        (Route<dynamic> route) => false);
                  },
                  child: Text(
                    'Cerca',
                    style: TextStyle(color: Colors.black, fontSize: 20),
                  ),
                ),
                if (!_isreg)
                  FlatButton(
                    minWidth: size.width / 1.2,
                    color: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => RegistrationPage(true)));
                    },
                    child: Text(
                      'Entra',
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                  ),
                if (!_isreg)
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
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                  ),
                if (_isreg)
                  FlatButton(
                    minWidth: size.width / 1.2,
                    color: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onPressed: () {
                      _makeLogout();
                    },
                    child: Text(
                      'Esci',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void checkPin() async {
    try {
      myID = await storage.read(key: 'id');
      if (await storage.read(key: 'pin') != null) setState(() => _isreg = true);
    } catch (_) {
      // ...
    }
  }

  void _makeLogout() async {
    await storage.deleteAll();
    setState(() => _isreg = false);
  }
}
