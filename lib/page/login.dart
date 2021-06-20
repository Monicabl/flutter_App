// import 'package:firebase_auth/firebase_auth.dart';
import 'dart:html';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/page/counter.dart';
import 'package:flutter_app/page/onboarding.dart';
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
    setDebugDataOnInput();
  }

  void setDebugDataOnInput() {
    _email = "rocky@gmail.com";
    _password = "secret";
    inputEmailController.text = _email;
    inputPasswordController.text = _password;
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

  //Sing In with Email
  void signIn() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email,
        password: _password,
      );
      saveCredentials(userCredential);
      navigateToCounter(context);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }

  void navigateToOnboarding() {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => OnBoardingPage()));
  }

  void saveCredentials(UserCredential userCredential) {
    print(userCredential);
    _prefer.setString('email', _email);
    _prefer.setString('password', _password);
  }

  void navigateToCounter(context) {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => CounterPag()));
  }

  void toRegister(context) {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => Register()));
  }

// SinIn with Google
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
    saveCredentials(credential);
    navigateToCounter(context);
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
            mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                label: Text('Sign Up with Google'),
                onPressed: () => handleBtnGoogle(context),
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
