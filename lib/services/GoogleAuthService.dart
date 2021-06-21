import 'package:firebase_auth/firebase_auth.dart';

class GoogleAuthService {
  static Future<UserCredential> signUp(String email, String password) async {
    return await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  static Future<UserCredential> signInWithPassword(
      String email, String password) async {
    return await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  static Future<UserCredential> signInWithGoogle() async {
    // Create a new provider
    GoogleAuthProvider googleProvider = GoogleAuthProvider();

    googleProvider
        .addScope('https://www.googleapis.com/auth/contacts.readonly');
    googleProvider.setCustomParameters({'login_hint': 'user@example.com'});

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithPopup(googleProvider);
  }

  static Future<UserCredential> signInWithFacebook() async {
    // Create a new provider
    FacebookAuthProvider facebookProvider = FacebookAuthProvider();

    facebookProvider.addScope('email');
    facebookProvider.setCustomParameters({
      'display': 'popup',
    });

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithPopup(facebookProvider);

    // Or use signInWithRedirect
    // return await FirebaseAuth.instance.signInWithRedirect(facebookProvider);
  }
}
