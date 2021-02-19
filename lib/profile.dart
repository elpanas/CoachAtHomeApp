import 'dart:convert';
import 'dart:io';
import 'package:coachapp/globals.dart';
import 'package:coachapp/models/coach.dart';
import 'package:coachapp/models/coach_db.dart';
import 'package:coachapp/modprofile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:social_media_buttons/social_media_buttons.dart';
import 'package:http/http.dart' as http;

class Profile extends StatefulWidget {
  final String coachId;

  Profile(this.coachId);

  @override
  _ProfileState createState() => _ProfileState(coachId);
}

class _ProfileState extends State<Profile> {
  final storage = FlutterSecureStorage();
  CoachDb db = CoachDb();
  int idb;
  bool fav = false;
  bool _showProgress = true;
  bool _isreg = false;
  Coach profile;
  final String coachId;

  _ProfileState(this.coachId);

  @override
  void initState() {
    checkPin();
    checkCoaches();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pop(true);
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text('Profilo'),
            actions: [
              (_isreg)
                  ? Padding(
                      padding: EdgeInsets.only(right: 20),
                      child: GestureDetector(
                        child: Icon(Icons.edit),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ModProfile(profile))).then(
                              (result) => {if (result != null) loadProfile()});
                        },
                      ))
                  : Container()
            ],
          ),
          floatingActionButton: (!_isreg)
              ? FloatingActionButton(
                  child: (fav)
                      ? Icon(Icons.favorite)
                      : Icon(Icons.favorite_border),
                  onPressed: () {
                    addToFavs();
                  },
                )
              : null,
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                if (!_showProgress)
                  AspectRatio(
                      aspectRatio: 3 / 1,
                      child: Container(
                        color: Colors.orange,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildName(profile.name),
                            _buildBio('Segni particolari: bellissimo')
                          ],
                        ),
                      )),
                if (!_showProgress)
                  if (profile.phone != '')
                    ListTile(
                      title: Text(profile.phone),
                      leading: Icon(Icons.phone),
                      onTap: () {
                        _callNumber(profile.phone);
                      },
                    ),
                if (!_showProgress)
                  if (profile.mail != '')
                    ListTile(
                      title: Text(profile.mail),
                      leading: Icon(Icons.mail),
                      onTap: () {
                        _sendMail(profile.mail);
                      },
                    ),
                if (!_showProgress)
                  if (profile.web != '')
                    ListTile(
                      title: Text(profile.web),
                      leading: Icon(Icons.web),
                      onTap: () {
                        _launchURL(profile.web);
                      },
                    ),
                if (!_showProgress)
                  Divider(
                    color: Colors.grey,
                    indent: 20,
                    endIndent: 20,
                  ),
                if (!_showProgress)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (profile.im != null)
                        if (profile.im) buildWhatsAppButton(profile.phone),
                      if (profile.facebook != '')
                        buildFacebookButton(profile.facebook),
                      if (profile.instagram != '')
                        buildInstagramButton(profile.instagram),
                      if (profile.linkedin != '')
                        buildLinkedInButton(profile.linkedin)
                    ],
                  )
              ],
            ),
          ),
        ));
  }

  Widget _buildName(String ptName) {
    return Padding(
        padding: EdgeInsets.all(14.0),
        child: Text(
          ptName,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ));
  }

  Widget _buildBio(String ptBio) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Align(
        child: Text(
          ptBio,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
          ),
          maxLines: 6, // you can change it accordingly
          overflow: TextOverflow.ellipsis, // and this
        ),
        alignment: Alignment.center,
      ),
    );
  }

  Widget buildWhatsAppButton(ptNumber) {
    return SocialMediaButton.whatsapp(
      url: "https://wa.me/+39" + ptNumber,
      size: 35,
      color: Colors.green,
    );
  }

  Widget buildInstagramButton(ptInsta) {
    return SocialMediaButton.instagram(
      url: "https://www.instagram.com/" + ptInsta,
      size: 35,
      color: Colors.pink,
    );
  }

  Widget buildFacebookButton(ptFacebook) {
    return SocialMediaButton.facebook(
      url: "https://www.facebook.com/" + ptFacebook,
      size: 35,
      color: Colors.blue,
    );
  }

  Widget buildLinkedInButton(ptLinkedin) {
    return SocialMediaButton.linkedin(
      url: "https://www.linkedin.com/in/" + ptLinkedin,
      size: 35,
      color: Colors.cyan,
    );
  }

  void _callNumber(number) async {
    await FlutterPhoneDirectCaller.callNumber(number);
  }

  void _sendMail(ptMail) async {
    final Email email = Email(
      body: 'Email body',
      subject: 'Email subject',
      recipients: [ptMail],
      isHTML: false,
    );
    await FlutterEmailSender.send(email);
  }

  void _launchURL(ptUrl) async {
    if (await canLaunch(ptUrl)) {
      await launch(ptUrl);
    } else {
      throw 'Could not launch $ptUrl';
    }
  }

  void checkPin() async {
    try {
      await storage
          .read(key: 'id')
          .then((value) => {_isreg = (value == coachId), loadProfile()});
    } catch (_) {
      // ...
    }
  }

  void loadProfile() {
    http.get(url + 'coach/id/' + coachId).then((res) {
      if (res.statusCode == HttpStatus.ok) {
        final resJson = jsonDecode(res.body);
        profile = Coach.fromJson(resJson);
        setState(() => {profile = profile, _showProgress = false});
      } else
        setState(() => _showProgress = false);
    });
  }

  void checkCoaches() async {
    List<Coach> coaches = await db.leggiCoaches();
    var coach = coaches.where((element) => element.id.startsWith(coachId));
    if (coach.isNotEmpty) setState(() => {fav = true, idb = coach.first.idb});
  }

  Future addToFavs() async {
    Coach coach = Coach.toDb(profile.id, profile.name, profile.city);
    if (!fav) {
      idb = await db.inserisciCoach(coach);
      setState(() => fav = true);
    } else {
      db.eliminaCoach(idb);
      setState(() => fav = false);
    }
  }
}
