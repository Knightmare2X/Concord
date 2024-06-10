import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/song.dart';

class MusicProvider extends ChangeNotifier {
  List<Song> _songs = [];

  //current song playing index;
  int? _currentSongIndex;

  // audio player
  final AudioPlayer _audioPlayer = AudioPlayer();

  // durations
  Duration _currentDuration = Duration.zero;
  Duration _totalDuration = Duration.zero;

  // initially not playing
  bool _isPlaying = false;

  // loading state
  bool _isLoading = true;

  //constructor
  MusicProvider() {
    fetchSongs();
    listenToDuration();
  }

  // fetch songs from Firestore
  /*Future<void> fetchSongs() async {
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
  }*/

  Future<void> fetchSongs() async {
    try {
      _isLoading = true;
      notifyListeners();

      print("Fetching songs from Firestore...");
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Songs').get();
      print("Fetched ${snapshot.docs.length} songs.");

      _songs = snapshot.docs.map((doc) => Song.fromSnap(doc)).toList();
      print("Mapped songs: ${_songs.length}");

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      print("Error fetching songs: $e");
      notifyListeners();
    }
  }



  // play the song
  void play() async {
    if (_currentSongIndex != null) {
      final String path = _songs[_currentSongIndex!].audioUrl;
      await _audioPlayer.stop(); // stop current song
      await _audioPlayer.play(UrlSource(path)); //play the new song
      _isPlaying = true;
      notifyListeners();
    }
  }

  // pause the current song
  void pause() async {
    await _audioPlayer.pause();
    _isPlaying = false;
    notifyListeners();
  }

  //resume playing
  void resume() async {
    await _audioPlayer.resume();
    _isPlaying = true;
    notifyListeners();
  }

  //pause or resume
  void pauseOrResume() async {
    if (_isPlaying) {
      pause();
    } else {
      resume();
    }
    notifyListeners();
  }

  // seek to a specific position in the current song
  void seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  // play the next song
  void playNextSong() {
    if (_currentSongIndex != null) {
      if (_currentSongIndex! < _songs.length - 1) {
        //go to the next song if it's not the last song
        currentSongIndex = _currentSongIndex! + 1;
      } else {
        //if it's the last song, loop back to the first song
        currentSongIndex = 0;
      }
    }
  }

  //play previous song
  void playPreviousSong() async {
    // if more than 2 seconds have passed, restart the current song
    if (_currentDuration.inSeconds > 2) {
      seek(Duration.zero);
    }
    //if it's within first 2 second of the song , go to previous song
    else {
      if (_currentSongIndex! > 0) {
        currentSongIndex = _currentSongIndex! - 1;
      } else {
        // if it's the first song, loop back to  last song
        currentSongIndex = _songs.length - 1;
      }
    }
  }

  // listen to duration
  void listenToDuration() {
    //listen for total duration
    _audioPlayer.onDurationChanged.listen((newDuration) {
      _totalDuration = newDuration;
      notifyListeners();
    });

    //listen for current duration
    _audioPlayer.onPositionChanged.listen((newPosition) {
      _currentDuration = newPosition;
      notifyListeners();
    });

    //listen for song completion
    _audioPlayer.onPlayerComplete.listen((event) {
      playNextSong();
    });
  }

  /*
  GETTER
  */

  List<Song> get music => _songs;
  int? get currentSongIndex => _currentSongIndex;
  bool get isPlaying => _isPlaying;
  Duration get currentDuration => _currentDuration;
  Duration get totalDuration => _totalDuration;
  bool get isLoading => _isLoading;

  /*
  SETTER
  */

  set currentSongIndex(int? newIndex) {
    // update current song index
    _currentSongIndex = newIndex;

    if (newIndex != null) {
      play(); // play the song at the new index
    }

    //update UI
    notifyListeners();
  }
}
