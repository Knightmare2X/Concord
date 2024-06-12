import 'package:cloud_firestore/cloud_firestore.dart';

class Song {
  final String songName;
  final String artistName;
  final String albumArtUrl;
  final String audioUrl;
  final String writerName;
  final String producerName;
  final String uid;
  final DateTime datePublished;
  final String songId;
  final dynamic likes;
  final dynamic listens;
  final dynamic totalListens;

  Song({
    required this.songName,
    required this.artistName,
    required this.albumArtUrl,
    required this.audioUrl,
    required this.writerName,
    required this.producerName,
    required this.uid,
    required this.datePublished,
    required this.songId,
    required this.likes,
    required this.listens,
    required this.totalListens,
  });

  static Song fromSnap(DocumentSnapshot snap){
    var snapshot = snap.data() as Map<String, dynamic>;

    return Song(
      songName: snapshot['songName'],
      artistName: snapshot['artistName'],
      albumArtUrl: snapshot['albumArtUrl'],
      audioUrl: snapshot['audioUrl'],
      writerName: snapshot['writerName'],
      producerName: snapshot['producerName'],
      uid: snapshot['uid'],
      datePublished:  (snapshot['datePublished'] as Timestamp).toDate(),
      songId: snapshot['songId'],
      likes: snapshot["likes"],
      listens: snapshot["listens"],
      totalListens: snapshot['totalListens'],
    );

  }

  Map<String, dynamic> toJson() => {
    'songName': songName,
    'artistName': artistName,
    'albumArtUrl': albumArtUrl,
    'audioUrl': audioUrl,
    'writerName': writerName,
    'producerName': producerName,
    'uid': uid,
    'datePublished': datePublished,
    'songId': songId,
    "likes": likes,
    "listens": listens,
    "totalListens": totalListens,
  };


}
