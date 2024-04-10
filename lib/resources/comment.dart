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

  const Comment({
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
