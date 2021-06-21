import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/page/login.dart';
import 'package:flutter_app/page/onboarding.dart';
import 'package:flutter_app/user/profile.dart';
import 'package:flutter_app/widget/buttom.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CounterPag extends StatefulWidget {
  CounterPag({Key? key}) : super(key: key);
  @override
  _CounterState createState() => _CounterState();
}

class _CounterState extends State<CounterPag> {
  final auth = FirebaseAuth.instance;
  int _count = 0;
  late String _name = '';
  late QueryDocumentSnapshot? userDocument;

  TextEditingController inputNameController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    try {
      getUserData();
      _loadCounter();
    } catch (e) {
      print(e);
    }
  }

  void getUserData() async {
    CollectionReference userCollection =
        FirebaseFirestore.instance.collection("users");

    QuerySnapshot users = await userCollection
        .where('email', isEqualTo: auth.currentUser!.email)
        .limit(1)
        .get();
    userDocument = users.docs[0];
    setState(() {
      _count = userDocument!.get('counter');
      _name = users.docs[0].get("name");
      inputNameController.text = _name;
    });
  }

  void toProfile(context) => Navigator.of(context)
      .pushReplacement(MaterialPageRoute(builder: (_) => Profile()));

  void goToOnBoarding(context) => Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => OnBoardingPage()),
      );
  void logout(context) {
    auth.signOut();
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => Login()));
  }

//-------------->>
  //Cargando el valor del contador en el inicio
  void _loadCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('count', 0);
    setState(() {
      _count = 0;
      CollectionReference userCollection =
          FirebaseFirestore.instance.collection("users");
      userCollection.doc(userDocument!.id).update({'counter': _count});
    });
  }

  //Incrementando el contador después del clic
  void _incrementCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      // ignore: unnecessary_statements
      _count <= (prefs.getInt('count') ?? 0) + _count++;
      prefs.setInt('count', _count);
      CollectionReference userCollection =
          FirebaseFirestore.instance.collection("users");
      userCollection.doc(userDocument!.id).update({'counter': _count});
    });
  }

//---------------->>
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('Contador'), actions: <Widget>[
          FlatButton.icon(
              onPressed: () {},
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(' Hola: $_name'),
              Text(
                'The number is: $_count',
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              ButtonWidget(
                text: 'Back',
                onClicked: () => goToOnBoarding(context),
              ),
            ],
          ),
        ),
        floatingActionButton: _crearButtoms(),
      );

  Widget _crearButtoms() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 30.0,
        ),
        FloatingActionButton(
          child: Icon(Icons.restore),
          onPressed: _loadCounter,
          tooltip: 'Contador en 0',
        ),
        Expanded(
          child: SizedBox(),
        ),
        FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: _incrementCounter,
          tooltip: 'Incrementa el contador',
        ),
      ],
    );
  }
}
