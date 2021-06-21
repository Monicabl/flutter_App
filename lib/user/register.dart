import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/page/counter.dart';
import 'package:flutter_app/page/login.dart';
import 'package:flutter_app/page/onboarding.dart';
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
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email,
        password: _password,
      );
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

  // void getUserData() async {
  //   try {
  //     CollectionReference userCollection =
  //         FirebaseFirestore.instance.collection("users");

  //     QuerySnapshot users = await userCollection
  //         .where('email', isEqualTo: auth.currentUser!.email)
  //         .limit(1)
  //         .get();

  //     userDocument = users.docs[0];
  //     _name = users.docs[0].get("name");
  //   } catch (e) {}
  // }

  Future<UserCredential> signInWithGoogle() async {
    // Create a new provider
    GoogleAuthProvider googleProvider = GoogleAuthProvider();

    googleProvider
        .addScope('https://www.googleapis.com/auth/contacts.readonly');
    googleProvider.setCustomParameters({'login_hint': 'user@example.com'});

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithPopup(googleProvider);
  }

  void handleBtnGoogle(context) async {
    UserCredential credential = await signInWithGoogle();
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
                  decoration: InputDecoration(hintText: 'EMAIL'),
                  onChanged: (value) {
                    setState(() {
                      _email = value.trim();
                    });
                  })),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
                keyboardType: TextInputType.name,
                decoration: InputDecoration(hintText: 'PASSWORD'),
                onChanged: (value) {
                  setState(() {
                    _password = value.trim();
                  });
                }),
          ),
          RaisedButton(
            color: Theme.of(context).accentColor,
            child: Text('Registrar'),
            onPressed: () => register(),
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
          RaisedButton(
            color: Theme.of(context).accentColor,
            child: Text('Regresar Login'),
            onPressed: () => toLogin(),
          ),
        ]));
  }
}
