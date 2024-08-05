import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:concord/screens/music_screen/music_screen.dart';
import 'package:flutter/material.dart';

import '../../model/song.dart';
import '../../resources/firestore.dart';

class PreviewScreen extends StatefulWidget {
  final Uint8List imageBytes;
  final String audioPath;
  final String songName;
  final String performedBy;
  final String writtenBy;
  final String producedBy;

  const PreviewScreen({
    Key? key,
    required this.imageBytes,
    required this.audioPath,
    required this.songName,
    required this.performedBy,
    required this.writtenBy,
    required this.producedBy,
  }) : super(key: key);

  @override
  _PreviewScreenState createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration totalDuration = Duration.zero;
  Duration currentPosition = Duration.zero;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        totalDuration = duration;
      });
    });

    _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        currentPosition = position;
      });
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        isPlaying = false;
        currentPosition = Duration.zero;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playPauseAudio() {
    if (isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play(DeviceFileSource(widget.audioPath));
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  void _seekAudio(double seconds) {
    _audioPlayer.seek(Duration(seconds: seconds.toInt()));
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  void _uploadSong() async {
    setState(() {
      _isLoading = true;
    });

    Song song = Song(
      songName: widget.songName,
      artistName: widget.performedBy,
      albumArtUrl: '',
      audioUrl: '',
      writerName: widget.writtenBy,
      producerName: widget.producedBy,
      uid: '', // This should be set appropriately
      datePublished: DateTime.now(),
      songId: '',
      likes: '',
      listens: '',
      totalListens: '',
    );

    String res = await FirestoreMethods().uploadSong(song, widget.imageBytes, widget.audioPath);
    setState(() {
      _isLoading = false;
    });

    if (res == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Song uploaded successfully')));
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MusicScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res)));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _isLoading ? const LinearProgressIndicator() : Container(),
                Container(),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    widget.imageBytes,
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.width * 0.9,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.songName,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Performed by ${widget.performedBy}",
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                Text(
                  "Written by ${widget.writtenBy}",
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                Text(
                  "Produced by ${widget.producedBy}",
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 20),
                IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 50,
                  ),
                  onPressed: _playPauseAudio,
                ),
                const SizedBox(height: 20),
                Slider(
                  min: 0,
                  max: totalDuration.inSeconds.toDouble(),
                  value: currentPosition.inSeconds.toDouble(),
                  onChanged: (value) {
                    _seekAudio(value);
                  },
                  activeColor: Colors.lightBlue,
                  inactiveColor: Colors.white54,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(currentPosition),
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      _formatDuration(totalDuration),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _uploadSong,
                  child: const Text('Upload'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
