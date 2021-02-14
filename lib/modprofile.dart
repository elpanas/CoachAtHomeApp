import 'dart:convert';
import 'dart:io';
import 'package:coachapp/models/coach.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:coachapp/globals.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ModProfile extends StatefulWidget {
  final Coach profile;

  ModProfile(this.profile);

  @override
  _ModProfileState createState() => _ModProfileState(profile);
}

class _ModProfileState extends State<ModProfile> {
  final Coach profile;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController fullController = TextEditingController();
  final TextEditingController cellController = TextEditingController();
  final TextEditingController mailController = TextEditingController();
  final TextEditingController webController = TextEditingController();
  final TextEditingController fbController = TextEditingController();
  final TextEditingController instaController = TextEditingController();
  final TextEditingController linkController = TextEditingController();
  final TextEditingController imController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final storage = FlutterSecureStorage();
  String pin = '';
  bool _checked;

  _ModProfileState(this.profile);

  @override
  void initState() {
    checkPin();
    _checked = profile.im ?? false;
    fullController.text = profile.name;
    if (profile.phone != '') cellController.text = profile.phone;
    if (profile.mail != '') mailController.text = profile.mail;
    if (profile.web != '') webController.text = profile.web;
    if (profile.facebook != '') fbController.text = profile.facebook;
    if (profile.instagram != '') instaController.text = profile.instagram;
    if (profile.linkedin != '') linkController.text = profile.linkedin;
    if (profile.bio != '') bioController.text = profile.bio;
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    fullController.dispose();
    cellController.dispose();
    mailController.dispose();
    webController.dispose();
    fbController.dispose();
    instaController.dispose();
    linkController.dispose();
    imController.dispose();
    bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Modifica Profilo')),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.save),
            onPressed: () {
              if (_formKey.currentState.validate())
                modProfile().then((res) {
                  if (res.statusCode == HttpStatus.ok)
                    Navigator.pop(context, true);
                  else
                    print(res.statusCode);
                });
            }),
        body: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: TextFormField(
                          controller: fullController,
                          keyboardType: TextInputType.name,
                          decoration: InputDecoration(
                            icon: Icon(Icons.account_circle),
                            hintText: 'Nome',
                            hintStyle: TextStyle(fontSize: 18),
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Inserire un valore';
                            }
                            return null;
                          },
                        ))
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: TextFormField(
                          controller: cellController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            icon: Icon(Icons.phone),
                            hintText: 'Telefono',
                            hintStyle: TextStyle(fontSize: 18),
                          ),
                        )),
                        //Container(height: 25),
                        Expanded(
                            child: CheckboxListTile(
                          title: Text('WhatsApp'),
                          value: _checked,
                          onChanged: (bool value) {
                            setState(() => _checked = value);
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        ))
                      ],
                    ),
                    TextFormField(
                      controller: bioController,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        hintText: 'Qualcosa di te...',
                        hintStyle: TextStyle(fontSize: 18),
                      ),
                    ),
                    TextFormField(
                      controller: mailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        icon: Icon(Icons.mail),
                        hintText: 'E-mail',
                        hintStyle: TextStyle(fontSize: 18),
                      ),
                    ),
                    TextFormField(
                      controller: fbController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        icon: Icon(MdiIcons.facebook),
                        hintText: 'Facebook',
                        hintStyle: TextStyle(fontSize: 18),
                      ),
                    ),
                    TextFormField(
                      controller: instaController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        icon: Icon(MdiIcons.instagram),
                        hintText: 'Instagram',
                        hintStyle: TextStyle(fontSize: 18),
                      ),
                    ),
                    TextFormField(
                      controller: linkController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        icon: Icon(MdiIcons.linkedin),
                        hintText: 'LinkedIn',
                        hintStyle: TextStyle(fontSize: 18),
                      ),
                    ),
                    TextFormField(
                      controller: webController,
                      keyboardType: TextInputType.url,
                      decoration: InputDecoration(
                        icon: Icon(MdiIcons.web),
                        hintText: 'Il tuo sito/blog',
                        hintStyle: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  void checkPin() async {
    pin = await storage.read(key: 'pin');
    print(pin);
  }

  Future modProfile() async {
    return http.put(
      url + 'coach',
      headers: <String, String>{
        'Content-Type': 'application/json',
        HttpHeaders.authorizationHeader: 'Basic ' + this.pin
      },
      body: jsonEncode(<String, dynamic>{
        'id': profile.id.toString(),
        'phone': cellController.text ?? '',
        'instant_msg': _checked,
        'mail': mailController.text ?? '',
        'web': webController.text ?? '',
        'facebook': fbController.text ?? '',
        'instagram': instaController.text ?? '',
        'linkedin': linkController.text ?? '',
        'bio': bioController.text ?? ''
      }),
    );
  }
}
