
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../resources/music_provider.dart';
import '../upload_screen/upload_song.dart';
import 'song_screen.dart';

class MusicScreen extends StatelessWidget {
  const MusicScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicProvider>(builder: (context, value, child) {
      // Get music
      final music = value.music;

      return Scaffold(
        appBar: AppBar(
          title: const Text('Music Library'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (context) => const UploadSong())),
            ),
          ],
        ),
        body: ListView.builder(
          itemCount: music.length,
          itemBuilder: (context, index) {
            final song = music[index];
            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(5.0),
                child: AspectRatio(
                  aspectRatio: 1/1,
                  child: Image.network(
                    song.albumArtUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              title: Text(song.songName),
              subtitle: Text(song.artistName),
              onTap: () {
                value.currentSongIndex = index;
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => const SongScreen()));
              },
            );
          },
        ),
      );
    });
  }
}
