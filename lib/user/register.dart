import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/page/counter.dart';
import 'package:flutter_app/page/login.dart';
import 'package:flutter_app/page/onboarding.dart';
import 'package:flutter_app/services/GoogleAuthService.dart';
import 'package:flutter_app/user/profile.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  late String _email = '';
  late String _password = '';
  late String _name = '';
  late SharedPreferences _prefer;
  late QueryDocumentSnapshot userDocument;
  // La persona checadora de sesion
  final auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    try {
      checkSession();
      checkAuthSessionGoogle();
    } catch (e) {}
  }

  void checkAuthSessionGoogle() {
    if (auth.currentUser != null) {
      toOnboarding(context);
    }
  }

  void saveCredentials(UserCredential userCredential) {
    _email = userCredential.user!.email!;
    _prefer.setString('email', _email);
    _prefer.setString('password', _password);

    CollectionReference userCollection =
        FirebaseFirestore.instance.collection("users");

    userCollection.add({
      'email': _email,
      'name': "",
      'last_name': "",
      'counter': 0,
    });
  }

  void checkSession() async {
    _prefer = await SharedPreferences.getInstance();

    // Get
    String? email = _prefer.getString('_email');
    String? password = _prefer.getString('_password');
    if (email != null) {
      _email = email;
      _password = password!;
      register();
    }
  }

  void register() async {
    try {
      UserCredential userCredential =
          await GoogleAuthService.signUp(_email, _password);

      saveCredentials(userCredential);
      toOnboarding(context);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }

  void handleBtnGoogle(context) async {
    UserCredential credential = await GoogleAuthService.signInWithGoogle();
    CollectionReference userCollection =
        FirebaseFirestore.instance.collection("users");

    QuerySnapshot users = await userCollection
        .where('email', isEqualTo: credential.user!.email)
        .limit(1)
        .get();

    if (users.size == 1) {
      toCounter(context);
      return;
    }
    saveCredentials(credential);
    toOnboarding(context);
  }

  void handleBtnFacebook(context) async {
    try {
      UserCredential credential = await GoogleAuthService.signInWithFacebook();
      CollectionReference userCollection =
          FirebaseFirestore.instance.collection("users");

      QuerySnapshot users = await userCollection
          .where('email', isEqualTo: credential.user!.email)
          .limit(1)
          .get();

      if (users.size == 1) {
        toCounter(context);
        return;
      }
      saveCredentials(credential);
      toOnboarding(context);
    } catch (e) {}
  }

  // Future<bool> userWasRegister(String? email) async {
  //   try {
  //     // CollectionReference userCollection =
  //     //     FirebaseFirestore.instance.collection("users");

  //     // QuerySnapshot users =
  //     //     await userCollection.where('email', isEqualTo: email).limit(1).get();
  //     // return users.size == 1;
  //   } catch (e) {
  //     return false;
  //   }
  // }

  void toOnboarding(context) => Navigator.of(context)
      .pushReplacement(MaterialPageRoute(builder: (_) => OnBoardingPage()));

  void toCounter(context) => Navigator.of(context)
      .pushReplacement(MaterialPageRoute(builder: (_) => CounterPag()));

  void toLogin() {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => Login()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Registro'),
        ),
        body: Column(children: [
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(hintText: 'Email'),
                  onChanged: (value) {
                    setState(() {
                      _email = value.trim();
                    });
                  })),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
                keyboardType: TextInputType.name,
                decoration: InputDecoration(hintText: 'Password'),
                onChanged: (value) {
                  setState(() {
                    _password = value.trim();
                  });
                }),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              RaisedButton(
                color: Theme.of(context).accentColor,
                child: Text('Registrar'),
                onPressed: () => register(),
              ),
              RaisedButton(
                color: Theme.of(context).accentColor,
                child: Text('Regresar Login'),
                onPressed: () => toLogin(),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  onPrimary: Colors.black,
                ),
                icon: FaIcon(FontAwesomeIcons.google, color: Colors.red),
                label: Text('Sign Up with Google'),
                onPressed: () => handleBtnGoogle(context),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  onPrimary: Colors.black,
                ),
                icon: FaIcon(FontAwesomeIcons.facebook, color: Colors.blue),
                label: Text('Sign Up with Facebook'),
                onPressed: () => handleBtnFacebook(context),
              ),
            ],
          )
        ]));
  }
}
