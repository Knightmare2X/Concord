import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/song.dart';
import '../resources/firestore.dart';

class MusicProvider extends ChangeNotifier {
  List<Song> _songs = [];
  int? _currentSongIndex;
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _currentDuration = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isPlaying = false;
  bool _isLoading = true;

  MusicProvider() {
    fetchSongs();
    listenToDuration();
  }

  Future<void> fetchSongs() async {
    try {
      _isLoading = true;
      notifyListeners();

      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Songs').get();
      _songs = snapshot.docs.map((doc) => Song.fromSnap(doc)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      print("Error fetching songs: $e");
      notifyListeners();
    }
  }

  void play() async {
    if (_currentSongIndex != null) {
      final String path = _songs[_currentSongIndex!].audioUrl;
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(path));
      _isPlaying = true;

      // Track listen
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirestoreMethods().listenToSong(_songs[_currentSongIndex!].songId, user.uid);
      }

      notifyListeners();
    }
  }

  void pause() async {
    await _audioPlayer.pause();
    _isPlaying = false;
    notifyListeners();
  }

  void resume() async {
    await _audioPlayer.resume();
    _isPlaying = true;
    notifyListeners();
  }

  void pauseOrResume() async {
    if (_isPlaying) {
      pause();
    } else {
      resume();
    }
    notifyListeners();
  }

  void seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  void playNextSong() {
    if (_currentSongIndex != null) {
      if (_currentSongIndex! < _songs.length - 1) {
        currentSongIndex = _currentSongIndex! + 1;
      } else {
        currentSongIndex = 0;
      }
    }
  }

  void playPreviousSong() async {
    if (_currentDuration.inSeconds > 2) {
      seek(Duration.zero);
    } else {
      if (_currentSongIndex! > 0) {
        currentSongIndex = _currentSongIndex! - 1;
      } else {
        currentSongIndex = _songs.length - 1;
      }
    }
  }

  void listenToDuration() {
    _audioPlayer.onDurationChanged.listen((newDuration) {
      _totalDuration = newDuration;
      notifyListeners();
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      _currentDuration = newPosition;
      notifyListeners();
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      playNextSong();
    });
  }

  List<Song> get music => _songs;
  int? get currentSongIndex => _currentSongIndex;
  bool get isPlaying => _isPlaying;
  Duration get currentDuration => _currentDuration;
  Duration get totalDuration => _totalDuration;
  bool get isLoading => _isLoading;

  set currentSongIndex(int? newIndex) {
    _currentSongIndex = newIndex;
    if (newIndex != null) {
      play();
    }
    notifyListeners();
  }
}
