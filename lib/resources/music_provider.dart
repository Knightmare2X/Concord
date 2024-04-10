import 'package:audioplayers/audioplayers.dart';
import 'package:concord/resources/song.dart';
import 'package:flutter/material.dart';

class MusicProvider extends ChangeNotifier {
  final List<Song> _music = [
    Song(
        songName: "feel good",
        artistName: "ya boy",
        albumArtImagePath: "assets/albumart/img.png",
        audioPath: "assets/audio/feel_good.mp3",
        writerName: "ya boy",
        producerName: "ya boy"),
    Song(
        songName: "Careless",
        artistName: "sim smith",
        albumArtImagePath: "assets/albumart/img2.png",
        audioPath: "assets/audio/careless.mp3",
        writerName: "sim smith",
        producerName: "sim smith"),
  ];

  //current song playing index;

  int? _currentSongIndex;

  /*
  AUDIO PLAYER

 */
  // audio player
  final AudioPlayer _audioPlayer = AudioPlayer();

  // durations
  Duration _currentDuration = Duration.zero;
  Duration _totalDuration = Duration.zero;

  //constructor
  MusicProvider() {
    listenToDuration();
  }

  // initially not playing
  bool _isPlaying = false;

  // play the song
  void play() async {
    final String path = _music[_currentSongIndex!].audioPath;
    await _audioPlayer.stop(); // stop current song
    await _audioPlayer.play(AssetSource(path)); //play the new song
    _isPlaying = true;
    notifyListeners();
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
      if (_currentSongIndex! < _music.length - 1) {
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
        currentSongIndex = _music.length - 1;
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

  //dispose audio player

  /*
  GETTER
  */

  List<Song> get music => _music;
  int? get currentSongIndex => _currentSongIndex;
  bool get isPlaying => _isPlaying;
  Duration get currentDuration => _currentDuration;
  Duration get totalDuration => _totalDuration;

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