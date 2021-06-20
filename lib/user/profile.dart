import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/page/counter.dart';
import 'package:flutter_app/page/login.dart';
import 'package:flutter_app/page/onboarding.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late String _name = '';
  late String _lastName = '';
  late SharedPreferences _prefer;

  TextEditingController inputNameController = new TextEditingController();
  TextEditingController inputLastNameController = new TextEditingController();

  late QueryDocumentSnapshot userDocument;
  // La persona checadora de sesion
  final auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void getUserData() async {
    CollectionReference userCollection =
        FirebaseFirestore.instance.collection("users");

    QuerySnapshot users = await userCollection
        .where('email', isEqualTo: auth.currentUser!.email)
        .limit(1)
        .get();

    userDocument = users.docs[0];

    _name = users.docs[0].get("name");
    _lastName = users.docs[0].get("last_name");

    inputNameController.text = _name;
    inputLastNameController.text = _lastName;
  }

  void savePerfilData(context) {
    CollectionReference userCollection =
        FirebaseFirestore.instance.collection("users");
    userCollection
        .doc(userDocument.id)
        .update({'name': _name, 'last_name': _lastName});
    toOnboarding(context);
  }

  void toOnboarding(context) => Navigator.of(context)
      .pushReplacement(MaterialPageRoute(builder: (_) => OnBoardingPage()));

  void toCount(context) => Navigator.of(context)
      .pushReplacement(MaterialPageRoute(builder: (_) => CounterPag()));

  void toProfile(context) => Navigator.of(context)
      .pushReplacement(MaterialPageRoute(builder: (_) => Profile()));

  void logout(context) {
    auth.signOut();
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => Login()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Perfil'), actions: <Widget>[
          FlatButton.icon(
              onPressed: () => toCount(context),
              icon: const Icon(Icons.countertops),
              textColor: Colors.white,
              label: Text('Contador')),
          FlatButton.icon(
              onPressed: () => toProfile(context),
              icon: const Icon(Icons.person),
              textColor: Colors.white,
              label: Text('Perfil')),
          FlatButton.icon(
              onPressed: () => logout(context),
              icon: const Icon(Icons.logout),
              textColor: Colors.white,
              label: Text('LogOut'))
        ]),
        body: Column(children: [
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(hintText: 'Name'),
                  controller: inputNameController,
                  onChanged: (value) {
                    setState(() {
                      _name = value.trim();
                    });
                  })),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
                keyboardType: TextInputType.name,
                decoration: InputDecoration(hintText: 'Last Name'),
                controller: inputLastNameController,
                onChanged: (value) {
                  setState(() {
                    _lastName = value.trim();
                  });
                }),
          ),
          RaisedButton(
              color: Theme.of(context).accentColor,
              child: Text('Guardar Datos'),
              onPressed: () => savePerfilData(context))
        ]));
  }
}
