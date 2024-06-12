import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:concord/model/comment.dart';
import 'package:concord/model/post.dart';
import 'package:concord/resources/storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import '../model/song.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //upload post
  Future<String> uploadPost(
    String description,
    Uint8List file,
    String uid,
    displayName,
    profImage,
  ) async {
    String res = "Some error occured";
    try {
      String photoUrl =
          await StorageMethods().uploadImageToStorage('Posts', file, true);

      String postId = const Uuid().v1();
      Post post = Post(
        description: description,
        uid: uid,
        postId: postId,
        datePublished: DateTime.now(),
        postUrl: photoUrl,
        profImage: profImage,
        displayName: displayName,
        likes: [],
        views: [],
      );

      _firestore.collection('Posts').doc(postId).set(
            post.toJson(),
          );

      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  //icon tap liking post
  Future<void> tLikePost(String postId, String uid, List likes) async {
    try {
      if (likes.contains(uid)) {
        await _firestore.collection('Posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      } else {
        await _firestore.collection('Posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid]),
        });
      }
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }

  // double tap liking post
  Future<void> dLikePost(String postId, String uid, List likes) async {
    try {
      await _firestore.collection('Posts').doc(postId).update({
        'likes': FieldValue.arrayUnion([uid]),
      });
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }

  //post views length

  Future<void> viewPost(String postId, String uid, List views) async {
    try {
      // Check if the user has already viewed the post
      if (!views.contains(uid)) {
        // Update the post's view count
        await _firestore.collection('Posts').doc(postId).update({
          'views': FieldValue.arrayUnion([uid]),
        });

        // Get the user ID of the post owner
        DocumentSnapshot postOwnerSnapshot =
            await _firestore.collection('Posts').doc(postId).get();

        final postOwnerData = postOwnerSnapshot.data() as Map<String, dynamic>;
        String postOwnerId = postOwnerData['uid'] as String;

        // Update the post owner's "totalViews" field
        await _firestore.collection('Users').doc(postOwnerId).update({
          'totalViews': FieldValue.increment(1),
        });
      } else {
        print("User has already viewed this post.");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  // Total views

  // upload comments

  Future<String> uploadComment(
    String postId,
    String text,
    String uid,
    displayName,
    profImage,
  ) async {
    String res = "Some error occured";
    try {
      if (text.isNotEmpty) {
        String commentId = const Uuid().v1();

        Comment comment = Comment(
          text: text,
          uid: uid,
          likes: [],
          commentId: commentId,
          postId: postId,
          datePublished: DateTime.now(),
          displayName: displayName,
          profImage: profImage,
        );

        _firestore
            .collection('Posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set(
              comment.toJson(),
            );
      }
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  //liking comment

  Future<void> likeComment(
      String commentId, String postId, String uid, List likes) async {
    try {
      if (likes.contains(uid)) {
        await _firestore
            .collection('Posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      } else {
        await _firestore
            .collection('Posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .update({
          'likes': FieldValue.arrayUnion([uid]),
        });
      }
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }

  //uploading users total views
  //
  // Future<String> totViews(String uid,String postId,List views) async {
  //   try{
  //
  //   }
  // }

//Deleting Post
  Future<String> deletePost(String postId) async {
    String res = "some error occurred";
    try {
      await _firestore.collection('Posts').doc(postId).delete();
      res = 'success';
    } catch (err) {
      print(err.toString());
    }
    return res;
  }

// Future<void> postComment(String postId, String text, String uid, String displayName, String profImage) async{
//
//   try {
//     if(text.isNotEmpty){
//       String commentId = Uuid().v1();
//       await _firestore.collection('Posts').doc(postId).collection('comments').doc(commentId).set({
//         'profImage': profImage,
//         'displayName': displayName,
//         'uid': uid,
//         'text': text,
//         'commentId': commentId,
//         'date published': DateTime.now(),
//       });
//
//     }else{
//       print('text is empty');
//     }
//   } catch(e) {
//     print(
//       e.toString(),
//     );
//   }
// }
  Future<bool> followUser(String uid, String followId) async {
    try {
      DocumentSnapshot snap =
          await _firestore.collection('Users').doc(uid).get();
      List following = (snap.data()! as dynamic)['following'];

      if (following.contains(followId)) {
        await _firestore.collection('Users').doc(followId).update({
          'followers': FieldValue.arrayRemove([uid])
        });

        await _firestore.collection('Users').doc(uid).update({
          'following': FieldValue.arrayRemove([followId])
        });
      } else {
        await _firestore.collection('Users').doc(followId).update({
          'followers': FieldValue.arrayUnion([uid])
        });

        await _firestore.collection('Users').doc(uid).update({
          'following': FieldValue.arrayUnion([followId])
        });
      }
      return true;
    } catch (e) {
      print(e.toString());
    }
    return false;
  }

  Future<void> uploadFourPhotos(List<Uint8List> photoFiles, String uid) async {
    try {
      List<String> photoUrls = [];

      for (int i = 0; i < photoFiles.length; i++) {
        String photoUrl = await StorageMethods()
            .uploadImageToStorage('Users/$uid/DescPic', photoFiles[i], true);
        photoUrls.add(photoUrl);
      }

      // Update the user's document in Firestore with the uploaded photo URLs
      await _firestore.collection('Users').doc(uid).update({
        'descPic': photoUrls,
      });
    } catch (err) {
      print(err.toString());
    }
  }

  Future<void> uploadData(username, String uid, Uint8List imageFile) async {
    try {
      String photoUrl = await StorageMethods()
          .uploadImageToStorage('Users/$uid/ProfPic', imageFile, true);

      await _firestore.collection('Users').doc(uid).update({
        'username': username,
        'photoURL': photoUrl,
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> uploadDataWithoutImage(String username, String uid) async {
    try {
      await _firestore
          .collection('Users')
          .doc(uid)
          .update({'username': username});
    } catch (e) {
      print(e.toString());
      throw e;
    }
  }

  Future<bool> isUsernameUnique(String username) async {
    try {
      // Query Firestore to check if the username already exists
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('username', isEqualTo: username)
          .get();

      // If no documents match the query, the username is unique
      return querySnapshot.docs.isEmpty;
    } catch (e) {
      // Handle any errors
      print("Error checking username uniqueness: $e");
      return false; // Assume username is not unique in case of an error
    }
  }

  // Upload song
  Future<String> uploadSong(
      Song song,
      Uint8List albumArtBytes,
      String audioPath,
      ) async {
    String res = "Some error occurred";
    try {
      String albumArtUrl = await StorageMethods().uploadImageToStorage('Songs/albumArts', albumArtBytes, true);
      String audioUrl = await StorageMethods().uploadFileToStorage('Songs/audioFiles', audioPath);

      String songId = const Uuid().v1();
      String uid = FirebaseAuth.instance.currentUser!.uid; // Get the UID of the current user

      Song newSong = Song(
        songName: song.songName,
        artistName: song.artistName,
        albumArtUrl: albumArtUrl,
        audioUrl: audioUrl,
        writerName: song.writerName,
        producerName: song.producerName,
        uid: uid,
        datePublished: DateTime.now(),
        songId: songId,
        likes: [],
        listens: [],
        totalListens: [],
      );

      _firestore.collection('Songs').doc(songId).set(newSong.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  //like songs
  Future<List> likeSong(String songId, String uid, List likes) async {
    try {
      if (likes.contains(uid)) {
        await _firestore.collection('Songs').doc(songId).update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      } else {
        await _firestore.collection('Songs').doc(songId).update({
          'likes': FieldValue.arrayUnion([uid]),
        });
      }

      // Get the updated likes list from Firestore
      DocumentSnapshot snapshot = await _firestore.collection('Songs').doc(songId).get();
      List updatedLikes = (snapshot.data() as Map<String, dynamic>)['likes'];
      return updatedLikes;
    } catch (e) {
      print(e.toString());
      return likes;
    }
  }

  //song listens

  Future<void> listenToSong(String songId, String uid) async {
    try {
      final now = DateTime.now();
      final songRef = _firestore.collection('Songs').doc(songId);
      final listenHistoryRef = songRef.collection('ListenHistory').doc(uid);
      final listenHistorySnapshot = await listenHistoryRef.get();

      if (listenHistorySnapshot.exists) {
        final data = listenHistorySnapshot.data() as Map<String, dynamic>;
        final listens = (data['listens'] as List<dynamic>)
            .map((e) => (e as Timestamp).toDate())
            .toList();
        final recentListens = listens.where((date) =>
            date.isAfter(now.subtract(Duration(hours: 24)))).toList();

        if (recentListens.length < 4) {
          recentListens.add(now);
          await listenHistoryRef.set({'listens': recentListens.map((date) => Timestamp.fromDate(date)).toList()});
        }
      } else {
        await listenHistoryRef.set({
          'listens': [Timestamp.fromDate(now)],
        });
      }

      // Update the song's listeners collection
      final listenersRef = songRef.collection('Listeners').doc(uid);
      await listenersRef.set({'lastListen': Timestamp.fromDate(now)});
    } catch (e) {
      print("Error in listenToSong: $e");
    }
  }
}





