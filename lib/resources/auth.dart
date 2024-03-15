import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:concord/model/persist_nav_bar.dart';
import 'package:concord/screens/new_user_screens/create_desc_pic_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../screens/login_screen.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn();

Future<void> signUp(BuildContext context) async {
  try {
    // Sign in with Google
    GoogleSignInAccount? googleSignInAccount =
    await _googleSignIn.signInSilently();
    if (googleSignInAccount == null) {
      // If there are no previously authenticated accounts, initiate sign-in
      googleSignInAccount = await _googleSignIn.signIn();
    }
    if (googleSignInAccount != null) {
      GoogleSignInAuthentication googleAuth =
      await googleSignInAccount.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential =
      await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        // Check if the user document exists in Firestore
        DocumentSnapshot userDoc =
        await _firestore.collection('Users').doc(user.uid).get();

        if (userDoc.exists) {
          // If user document exists, check if username is present
          if (userDoc.get('username') != null) {
            // If username exists, navigate to home screen
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => PersistNavBar()));
            return;
          }
        }

        // If user document doesn't exist or username is not present, proceed with creating user document
        await _firestore.collection('Users').doc(user.uid).set({
          'email': user.email,
          'uid': user.uid,
          'followers': [],
          'following': [],
          'totalViews': 0,
          'creationDate': DateTime.now(),
        });
        // Navigate to create description and picture screen
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => CreateDescPicScreen()));
      }
    }
  } catch (error) {
    print(error);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sign in failed'),
      ),
    );
  }
}


Future<void> signOut(BuildContext context) async {
  try {
    await _googleSignIn.signOut(); // Sign out from Google
    await _auth.signOut(); // Sign out from Firebase Authentication
    Navigator.of(context, rootNavigator: true).pushReplacement(
        MaterialPageRoute(
            builder: (context) =>
                LoginScreen())); // Navigate to the authentication screen
  } catch (error) {
    print(error);
  }
}
