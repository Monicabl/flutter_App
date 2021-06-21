// import 'package:firebase_auth/firebase_auth.dart';
import 'dart:html';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/page/counter.dart';
import 'package:flutter_app/page/onboarding.dart';
import 'package:flutter_app/services/GoogleAuthService.dart';
import 'package:flutter_app/user/register.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late String _email = '';
  late String _password = '';
  TextEditingController inputEmailController = new TextEditingController();
  TextEditingController inputPasswordController = new TextEditingController();
  late SharedPreferences _prefer;
  final auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    checkAuthSessionGoogle(context);
    setLocalStorage();
  }

  void checkAuthSessionGoogle(context) {
    if (auth.currentUser != null) {
      navigateToCounter(context);
    }
  }

  void setLocalStorage() async {
    // habilita que la variable _prefer pueda guardar, obtener o eliminar datos del local storage
    _prefer = await SharedPreferences.getInstance();
  }

  //Sing In, Email
  void signIn() async {
    try {
      UserCredential userCredential =
          await GoogleAuthService.signInWithPassword(_email, _password);
      //saveCredentials(userCredential);
      navigateToCounter(context);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }

  // void saveCredentials(UserCredential userCredential) {
  //   print(userCredential);
  //   _prefer.setString('email', _email);
  //   _prefer.setString('password', _password);
  // }

  Future<void> createUserDocument(UserCredential userCredential) async {
    _email = userCredential.user!.email!;
    CollectionReference userCollection =
        FirebaseFirestore.instance.collection("users");

    await userCollection.add({
      'email': _email,
      'name': "",
      'last_name': "",
      'counter': 0,
    });
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
      navigateToCounter(context);
      return;
    }
    await createUserDocument(credential);
    navigateToOnboarding(context);
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
        navigateToCounter(context);
        return;
      }
      await createUserDocument(credential);
      navigateToOnboarding(context);
    } catch (e) {}
  }

  void navigateToOnboarding(context) {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => OnBoardingPage()));
  }

  void navigateToCounter(context) {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => CounterPag()));
  }

  void toRegister(context) {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => Register()));
  }

//----------------------->>
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
                controller: inputEmailController,
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
                controller: inputPasswordController,
                onChanged: (value) {
                  setState(() {
                    _password = value.trim();
                  });
                }),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              RaisedButton(
                  color: Theme.of(context).accentColor,
                  child: Text('SignIn'),
                  onPressed: signIn),
              RaisedButton(
                  color: Theme.of(context).accentColor,
                  child: Text('Sign Up'),
                  onPressed: () => toRegister(context)),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  onPrimary: Colors.black,
                ),
                icon: FaIcon(FontAwesomeIcons.google, color: Colors.red),
                label: Text('Sign In with Google'),
                onPressed: () => handleBtnGoogle(context),
                // onPressed: () {
                //   final provider = Provider.of<GoogleSingInProvider>(context,
                //       listen: false);
                //   provider.googleLogin();
                // }
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  onPrimary: Colors.black,
                ),
                icon: FaIcon(FontAwesomeIcons.facebook, color: Colors.blue),
                label: Text('Sign In with Facebook'),
                onPressed: () => handleBtnFacebook(context),
                // onPressed: () {
                //   final provider = Provider.of<GoogleSingInProvider>(context,
                //       listen: false);
                //   provider.googleLogin();
                // }
              )
            ],
          )
        ],
      ),
    );
  }
}
