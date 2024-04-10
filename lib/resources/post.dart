import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String description;
  final String uid;
  final dynamic likes;
  final dynamic views;
  final String postId;
  final DateTime datePublished;
  final String postUrl;
  final String displayName;
  final String profImage;

  const Post({
    required this.description,
    required this.uid,
    required this.likes,
    required this.views,
    required this.postId,
    required this.datePublished,
    required this.postUrl,
    required this.displayName,
    required this.profImage,
  });

  static Post fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Post(
      description: snapshot["description"],
      uid: snapshot["uid"],
      likes: snapshot["likes"],
      views: snapshot["views"],
      postId: snapshot["postId"],
      datePublished: snapshot["datePublished"],
      postUrl: snapshot['postUrl'],
      displayName: snapshot['displayName'],
      profImage: snapshot['profImage'],
    );
  }

  Map<String, dynamic> toJson() => {
        "description": description,
        "uid": uid,
        "likes": likes,
        "views": views,
        "postId": postId,
        "datePublished": datePublished,
        'postUrl': postUrl,
        'displayName': displayName,
        'profImage': profImage,
      };
}
