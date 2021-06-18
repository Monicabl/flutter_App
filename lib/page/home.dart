import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/page/login.dart';
import 'package:flutter_app/page/onboarding.dart';
import 'package:flutter_app/widget/buttom.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePag extends StatefulWidget {
  HomePag({Key? key}) : super(key: key);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomePag> {
  final auth = FirebaseAuth.instance;
  int _count = 0;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Contador'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'The number is: $_count',
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              ButtonWidget(
                text: 'Back',
                onClicked: () => goToOnBoarding(context),
              ),
              FlatButton(
                  child: Text('Logout'),
                  onPressed: () {
                    print(':)');
                    auth.signOut();
                    print('fghjk');
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => Login()));
                  })
            ],
          ),
        ),
        floatingActionButton: _crearButtoms(),
      );

  void goToOnBoarding(context) => Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => OnBoardingPage()),
      );
  @override
  void initState() {
    super.initState();
    User? user = auth.currentUser;
    //print(user);
    checkSession();
  }

  void checkSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

// Set
    //prefs.setString('session', 'loquesea');

// Get
    String? token = prefs.getString('session');
    print(token);

// Remove
    //prefs.remove('apiToken');
  }

  Widget _crearButtoms() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 30.0,
        ),
        FloatingActionButton(
          child: Icon(Icons.restore),
          onPressed: () {
            setState(() {
              _count = 0;
            });
          },
          tooltip: 'Contador en 0',
        ),
        Expanded(
          child: SizedBox(),
        ),
        FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            setState(() {
              _count++;
              if (_count == 20) {
                _count = 0;
              }
            });
          },
          tooltip: 'Incrementa el contador',
        ),
      ],
    );
  }
}
