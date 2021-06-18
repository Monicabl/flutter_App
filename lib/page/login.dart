// import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/page/home.dart';
import 'package:flutter_app/page/onboarding.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late String _email;
  late String _password;
  late SharedPreferences _prefer;
  final auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    //User? user = auth.currentUser;
    //print(user);
    checkSession();
  }

  void checkSession() async {
    _prefer = await SharedPreferences.getInstance();

// Set
    //prefs.setString('session', 'loquesea');

// Get
    String? email = _prefer.getString('_email');
    String? password = _prefer.getString('_password');
    if (email != null) {
      _email = email;
      _password = password!;
      signIn();
    }

// Remove
    //prefs.remove('apiToken');
  }

  void register() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email,
        password: _password,
      );
      _prefer.setString('_email', _email);
      _prefer.setString('_password', _password);
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => OnBoardingPage()));
      print(userCredential);
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

  void signIn() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email,
        password: _password,
      );
      _prefer.setString('_email', _email);
      _prefer.setString('_password', _password);
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) => HomePag()));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(hintText: 'email'),
                onChanged: (value) {
                  setState(() {
                    _email = value.trim();
                  });
                }),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
                obscureText: true,
                decoration: InputDecoration(hintText: 'password'),
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
                  child: Text('SignIn'),
                  onPressed: signIn),
              RaisedButton(
                  color: Theme.of(context).accentColor,
                  child: Text('SignUp'),
                  onPressed: register),
            ],
          )
        ],
      ),
    );
  }
}
