import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:concord/widgets/persist_nav_bar.dart';
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
    GoogleSignInAccount? googleSignInAccount;

    try {
      // Attempt to sign in silently
      print("Attempting silent sign-in...");
      googleSignInAccount = await _googleSignIn.signInSilently();
      print("Silent sign-in successful: ${googleSignInAccount?.email}");
    } catch (e) {
      print("Silent sign-in failed: $e");
    }

    // If silent sign-in fails, proceed with manual sign-in
    if (googleSignInAccount == null) {
      print("Attempting manual Google sign-in...");
      googleSignInAccount = await _googleSignIn.signIn();
      print("Manual Google sign-in successful: ${googleSignInAccount?.email}");
    }

    if (googleSignInAccount != null) {
      print("Fetching Google authentication credentials...");
      GoogleSignInAuthentication googleAuth = await googleSignInAccount.authentication;
      print("Access token: ${googleAuth.accessToken}");
      print("ID token: ${googleAuth.idToken}");

      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print("Signing in with Firebase using Google credentials...");
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        print("User signed in: ${user.email}");

        print("Checking if user document exists in Firestore...");
        DocumentSnapshot userDoc = await _firestore.collection('Users').doc(user.uid).get();
        print("User document exists: ${userDoc.exists}");

        if (userDoc.exists && userDoc.get('username') != null) {
          print("Username found in Firestore. Navigating to PersistNavBar...");
          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const PersistNavBar()),
            );
          }
        } else {
          print("Username not found. Creating user document in Firestore...");
          await _firestore.collection('Users').doc(user.uid).set({
            'email': user.email,
            'uid': user.uid,
            'followers': [],
            'following': [],
            'totalViews': 0,
            'creationDate': DateTime.now(),
          });
          print("User document created. Navigating to CreateDescPicScreen...");
          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const CreateDescPicScreen()),
            );
          }
        }
      } else {
        print("Firebase sign-in failed. User is null.");
      }
    } else {
      throw Exception("Google Sign-In failed. googleSignInAccount is null.");
    }
  } catch (error) {
    print("Sign-in error: $error");
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in failed')),
      );
    }
  }
}



Future<void> signOut(BuildContext context) async {
  try {
    await _googleSignIn.signOut(); // Sign out from Google
    await _auth.signOut();
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()));
    } // Sign out from Firebase Authentication
    // Navigate to the authentication screen
  } catch (error) {
    print(error);
  }
}
