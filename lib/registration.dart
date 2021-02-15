import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:coachapp/globals.dart';
import 'package:coachapp/coachlist.dart';

class RegistrationPage extends StatefulWidget {
  final login;

  RegistrationPage(this.login);

  @override
  _RegistrationPageState createState() => _RegistrationPageState(login);
}

class _RegistrationPageState extends State<RegistrationPage> {
  final login;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController firstController = TextEditingController();
  final TextEditingController fullController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController pswController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final storage = FlutterSecureStorage();
  String pin = '';
  String _title = 'Log In';

  _RegistrationPageState(this.login);

  @override
  void initState() {
    setTitle();
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    firstController.dispose();
    fullController.dispose();
    nameController.dispose();
    pswController.dispose();
    cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(_title)),
        body: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    if (!login)
                      Row(
                        children: [
                          Expanded(
                              child: TextFormField(
                            controller: firstController,
                            keyboardType: TextInputType.name,
                            decoration: InputDecoration(
                              icon: Icon(Icons.account_circle),
                              hintText: 'Nome',
                              hintStyle: TextStyle(fontSize: 18),
                            ),
                            validator: (value) {
                              if (value.isEmpty) return 'Inserire un valore';

                              return null;
                            },
                          )),
                          Container(width: 10),
                          Expanded(
                              child: TextFormField(
                            controller: fullController,
                            keyboardType: TextInputType.name,
                            decoration: InputDecoration(
                              hintText: 'Cognome',
                              hintStyle: TextStyle(fontSize: 18),
                            ),
                            validator: (value) {
                              if (value.isEmpty) return 'Inserire un valore';

                              return null;
                            },
                          )),
                        ],
                      ),
                    Container(height: 20),
                    Row(
                      children: [
                        Expanded(
                            child: TextFormField(
                          controller: nameController,
                          keyboardType: TextInputType.name,
                          decoration: InputDecoration(
                            icon: Icon(Icons.lock),
                            hintText: 'Username',
                            hintStyle: TextStyle(fontSize: 18),
                          ),
                          validator: (value) {
                            if (value.isEmpty) return 'Inserire un valore';

                            return null;
                          },
                        )),
                        Container(width: 10),
                        Expanded(
                            child: TextFormField(
                          controller: pswController,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            hintStyle: TextStyle(fontSize: 18),
                          ),
                          validator: (value) {
                            if (value.isEmpty) return 'Inserire un valore';

                            return null;
                          },
                        )),
                      ],
                    ),
                    Container(height: 20),
                    if (!login)
                      TextFormField(
                        controller: cityController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          icon: Icon(Icons.location_city),
                          hintText: 'Comune',
                          hintStyle: TextStyle(fontSize: 18),
                        ),
                        validator: (value) {
                          if (value.isEmpty) return 'Inserire un valore';

                          return null;
                        },
                      ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: RaisedButton(
                        child: Text(
                          'Invia',
                          style: TextStyle(color: Colors.white, fontSize: 19),
                        ),
                        color: Colors.orange,
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            if (!login) {
                              createUser(
                                      firstController.text,
                                      fullController.text,
                                      nameController.text,
                                      pswController.text)
                                  .then((res) {
                                if (res.statusCode == HttpStatus.ok)
                                  setVars(res).then((_) =>
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  CoachesList())));
                                else
                                  _buildError(context);
                              });
                            } else
                              makeLogin(nameController.text, pswController.text)
                                  .then((res) {
                                if (res.statusCode == HttpStatus.ok)
                                  setVars(res).then((_) =>
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  CoachesList())));
                                else
                                  _buildError(context);
                              });
                          }
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  ScaffoldFeatureController _buildError(context) {
    return Scaffold.of(context)
        .showSnackBar(SnackBar(content: Text('Something went wrong :(')));
  }

  void setTitle() async {
    if (!this.login) setState(() => _title = 'Registrazione');
  }

  Future createUser(String first, String full, String name, String psw) async {
    Position position = await Geolocator.getLastKnownPosition();
    if (position == null) position = await Geolocator.getCurrentPosition();
    return http.post(
      url + 'coach/',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(<String, dynamic>{
        'name': first + ' ' + full,
        'username': base64.encode(utf8.encode(name)),
        'password': base64.encode(utf8.encode(psw)),
        'location': {
          'type': "Point",
          'coordinates': [position.latitude, position.longitude]
        },
        'city': cityController.text
      }),
    );
  }

  Future makeLogin(String name, String psw) async {
    var pin = base64.encode(utf8.encode(name + ':' + psw));
    return http.get(
      url + 'coach/login',
      headers: <String, String>{
        HttpHeaders.authorizationHeader: 'Basic ' + pin
      },
    );
  }

  Future setVars(res) async {
    await storage.deleteAll();
    await storage.write(key: 'username', value: nameController.text);
    await storage.write(key: 'id', value: jsonDecode(res.body));
    return await storage.write(
        key: 'pin',
        value: base64.encode(
            utf8.encode(nameController.text + ':' + pswController.text)));
  }
}
