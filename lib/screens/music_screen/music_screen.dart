import 'package:concord/resources/music_provider.dart';
import 'package:concord/screens/music_screen/song_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../resources/song.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({Key? key}) : super(key: key);

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  //get Music provider
  late final dynamic musicProvider;

  @override
  void initState() {
    super.initState();
    // get music provider

    musicProvider = Provider.of<MusicProvider>(context, listen: false);
  }

  // go to a song
  void goToSong(int songIndex) {
    //update current song index
    musicProvider.currentSongIndex = songIndex;

    // navigate to song page
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const SongScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<MusicProvider>(builder: (context, value, child) {
        // get the playlist
        final List<Song> music = value.music;

        //return list view UI
        return ListView.builder(
            itemCount: music.length,
            itemBuilder: (context, index) {
              // get individual song
              final Song song = music[index];
              return ListTile(
                title: Text(song.songName),
                subtitle: Text(song.artistName),
                leading: Image.asset(song.albumArtImagePath),
                onTap: () => goToSong(index),
              );
            });
      }),
    );
  }
}
