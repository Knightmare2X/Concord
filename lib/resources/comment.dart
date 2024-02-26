import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String text;
  final String uid;
  final likes;
  final String commentId;
  final String postId;
  final DateTime datePublished;
  final String displayName;
  final String profImage;

  const Comment(
      {
        required this.text,
        required this.uid,
        required this.likes,
        required this.commentId,
        required this.postId,
        required this.datePublished,
        required this.displayName,
        required this.profImage,
      });

  static Comment fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Comment(
      text: snapshot["text"],
      uid: snapshot["uid"],
      likes: snapshot["likes"],
      commentId: snapshot["commentId"],
      postId: snapshot["postId"],
      datePublished: snapshot["datePublished"],
      displayName: snapshot['displayName'],
      profImage: snapshot['profImage'],
    );
  }

  Map<String, dynamic> toJson() => {
    "text": text,
    "uid": uid,
    "likes": likes,
    "commentId": commentId,
    "postId": postId,
    "datePublished": datePublished,
    'displayName': displayName,
    'profImage': profImage,
  };
}

/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:concord/model/persist_nav_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../model/nav_bar.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final FirebaseAuth auth = FirebaseAuth.instance;
final storage = new FlutterSecureStorage();



Future<void> signup(BuildContext context) async {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
  final DateTime dateTime = DateTime.now();
  int totalViews = 0;

  saveUserInfoToFirestore() async{

    GoogleSignInAccount? gCurrentUser = googleSignIn.currentUser;
    User? user = auth.currentUser;
    var uid = user?.uid;

    if (googleSignInAccount != null) {
      await _firestore.collection("Users").doc(uid).set({
        "username": gCurrentUser?.displayName,
        "uid": uid,
        "email": gCurrentUser?.email,
        "photoURL": gCurrentUser?.photoUrl,
        "creationDate": dateTime,
        "followers": [],
        "following": [],
        "totalViews": totalViews,
      });
    }
  }

  if (googleSignInAccount != null) {

    final GoogleSignInAuthentication googleSignInAuthentication =
    await googleSignInAccount.authentication;
    final AuthCredential authCredential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken);

    // Getting users credential
    UserCredential result = await auth.signInWithCredential(authCredential);
    storeTokenAndData(result);
    User? user = result.user;

    await saveUserInfoToFirestore();

    if (result != null) {
      */
/*Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => NavBar()));*//*

      final username = await Navigator.push(context, MaterialPageRoute(builder: (context) => PersistNavBar()));
    } // if result not null we simply call the MaterialpageRoute,
    // for go to the HomePage screen
  }



}



Future<void> storeTokenAndData(UserCredential userCredential) async {
  await storage.write(
      key: "token", value: userCredential.credential?.token.toString());
  await storage.write(
      key: "userCredential", value: userCredential.toString());
}

Future<String?> getToken() async {
  return await storage.read(key: "token");
}

*/
