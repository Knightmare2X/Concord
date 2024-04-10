import 'package:concord/screens/music_screen/music_screen.dart';
import 'package:concord/screens/upload_screen/upload_song.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/neu_box.dart';
import '../../resources/music_provider.dart';

class SongScreen extends StatelessWidget {
  const SongScreen({Key? key}) : super(key: key);

  //convert duration into min: sec
  String formatTime(Duration duration) {
    String twoDigitSeconds =
        duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    String formattedTime = "${duration.inMinutes}: $twoDigitSeconds";

    return formattedTime;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicProvider>(builder: (context, value, child) {
      //get Music
      final music = value.music;

      // get current song index
      final currentSong = music[value.currentSongIndex ?? 0];

      //return scaffold UI
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 25, right: 25, bottom: 25),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              //app bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //backbutton
                  IconButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const UploadSong())),
                    icon: const Icon(Icons.add_box_outlined),
                  ),

                  //menu button
                  IconButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MusicScreen())),
                    icon: const Icon(Icons.menu),
                  ),
                ],
              ), // album artwork
              NeuBox(
                  child: Column(
                children: [
                  //image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(currentSong.albumArtImagePath),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //song and artist name
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentSong.songName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            Text(currentSong.artistName),
                          ],
                        ),

                        // heart like
                        const Icon(
                          Icons.favorite,
                          color: Colors.red,
                        )
                      ],
                    ),
                  )

                  //
                ],
              )),
              const SizedBox(height: 25.0),

              // song duration progress
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            //start time
                            Text(formatTime(value.currentDuration)), //end time
                            Text(formatTime(value.totalDuration)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // song duration progress slider
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                        thumbShape:
                            const RoundSliderThumbShape(enabledThumbRadius: 0)),
                    child: Slider(
                      min: 0,
                      max: value.totalDuration.inSeconds.toDouble(),
                      value: value.currentDuration.inSeconds.toDouble(),
                      activeColor: Colors.lightBlue,
                      onChanged: (double double) {
                        // during when the user is sliding around
                      },
                      onChangeEnd: (double double) {
                        // sliding has finished, go to that position in song duration
                        value.seek(Duration(seconds: double.toInt()));
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 25,
              ),

              // playback controls
              Row(
                children: [
                  //skip previous
                  Expanded(
                    child: GestureDetector(
                      onTap: value.playPreviousSong,
                      child: const NeuBox(
                        child: Icon(Icons.skip_previous),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 20.0,
                  ),
                  //play/pause
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: value.pauseOrResume,
                      child: NeuBox(
                        child: Icon(
                            value.isPlaying ? Icons.pause : Icons.play_arrow),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 20.0,
                  ),

                  //skip forward
                  Expanded(
                    child: GestureDetector(
                      onTap: value.playNextSong,
                      child: const NeuBox(
                        child: Icon(Icons.skip_next),
                      ),
                    ),
                  ),
                ],
              )
            ]),
          ),
        ),
      );
    });
  }
}
