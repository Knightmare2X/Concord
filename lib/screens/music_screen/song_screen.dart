import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../resources/music_provider.dart';
import '../../widgets/like_animation.dart';
import '../../widgets/neu_box.dart';
import '../upload_screen/upload_song.dart';
import 'music_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../resources/firestore.dart';

class SongScreen extends StatelessWidget {
  const SongScreen({Key? key}) : super(key: key);

  // Convert duration into min:sec
  String formatTime(Duration duration) {
    String twoDigitSeconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    String formattedTime = "${duration.inMinutes}:$twoDigitSeconds";
    return formattedTime;
  }

  @override
  Widget build(BuildContext context) {
    final User user = FirebaseAuth.instance.currentUser!;
    return Consumer<MusicProvider>(builder: (context, value, child) {
      // Check if loading
      if (value.isLoading) {
        return const Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: CircularProgressIndicator(), // Or any other placeholder widget
          ),
        );
      }

      // Get music
      final music = value.music;

      // Check if music list is empty
      if (music.isEmpty) {
        // Handle the case where music list is empty
        return const Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Text(
              "No songs available",
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }

      // Get current song index
      final currentSongIndex = value.currentSongIndex ?? 0;

      // Return scaffold UI
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 25, right: 25, bottom: 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button
                    IconButton(
                      onPressed: () => Navigator.push(
                          context, MaterialPageRoute(builder: (context) => const UploadSong())),
                      icon: const Icon(Icons.add_box_outlined),
                    ),

                    // Menu button
                    IconButton(
                      onPressed: () => Navigator.push(
                          context, MaterialPageRoute(builder: (context) => const MusicScreen())),
                      icon: const Icon(Icons.menu),
                    ),
                  ],
                ),

                // Album artwork
                NeuBox(
                  child: Column(
                    children: [
                      // Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: music[currentSongIndex].albumArtUrl,
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: MediaQuery.of(context).size.width * 0.9,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Song and artist name
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  music[currentSongIndex].songName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                Text(music[currentSongIndex].artistName),
                              ],
                            ),

                            // Heart like
                            LikeAnimation(
                              isAnimating: music[currentSongIndex].likes.contains(user.uid),
                              child: GestureDetector(
                                onTap: () async {
                                  print("Icon tapped!");

                                  // Optimistically update UI
                                  if (music[currentSongIndex].likes.contains(user.uid)) {
                                    music[currentSongIndex].likes.remove(user.uid);
                                  } else {
                                    music[currentSongIndex].likes.add(user.uid);
                                  }
                                  value.notifyListeners(); // Notify listeners to update UI

                                  // Update Firestore
                                  await FirestoreMethods().likeSong(
                                    music[currentSongIndex].songId,
                                    user.uid,
                                    music[currentSongIndex].likes,
                                  );
                                },
                                child: music[currentSongIndex].likes.contains(user.uid)
                                    ? const Icon(
                                  Icons.favorite_border,
                                )
                                    : const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                ),
                              ),
                            ),

                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25.0),

                // Song duration progress
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Start time
                              Text(formatTime(value.currentDuration)),
                              // End time
                              Text(formatTime(value.totalDuration)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Song duration progress slider
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0),
                      ),
                      child: Slider(
                        min: 0,
                        max: value.totalDuration.inSeconds.toDouble(),
                        value: value.currentDuration.inSeconds.toDouble(),
                        activeColor: Colors.lightBlue,
                        onChanged: (double newValue) {
                          // During when the user is sliding around
                        },
                        onChangeEnd: (double newValue) {
                          // Sliding has finished, go to that position in song duration
                          value.seek(Duration(seconds: newValue.toInt()));
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // Playback controls
                Row(
                  children: [
                    // Skip previous
                    Expanded(
                      child: GestureDetector(
                        onTap: value.playPreviousSong,
                        child: const NeuBox(
                          child: Icon(Icons.skip_previous),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20.0),

                    // Play/pause
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: value.pauseOrResume,
                        child: NeuBox(
                          child: Icon(value.isPlaying ? Icons.pause : Icons.play_arrow),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20.0),

                    // Skip forward
                    Expanded(
                      child: GestureDetector(
                        onTap: value.playNextSong,
                        child: const NeuBox(
                          child: Icon(Icons.skip_next),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}