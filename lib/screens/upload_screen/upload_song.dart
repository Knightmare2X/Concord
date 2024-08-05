import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';

import '../../resources/music_provider.dart';
import 'preview_screen.dart';

class UploadSong extends StatefulWidget {
  const UploadSong({Key? key}) : super(key: key);

  @override
  State<UploadSong> createState() => _UploadSongState();
}

class _UploadSongState extends State<UploadSong> {
  String? selectedImagePath;
  Uint8List? selectedImageBytes;
  String? selectedAudioPath;
  final TextEditingController songNameController = TextEditingController();
  final TextEditingController performedByController = TextEditingController();
  final TextEditingController writtenByController = TextEditingController();
  final TextEditingController producedByController = TextEditingController();
  final AudioPlayer audioPlayer = AudioPlayer();

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final Uint8List bytes = await pickedFile.readAsBytes();
      setState(() {
        selectedImageBytes = bytes;
      });
    }
  }

  Future<void> _pickAudio() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null) {
      final String? path = result.files.single.path;
      if (path != null) {
        // Check the duration of the audio file
        await audioPlayer.setSourceUrl(path);
        final Duration? duration = await audioPlayer.getDuration();
        if (duration != null && duration.inSeconds <= 105) {
          setState(() {
            selectedAudioPath = path;
          });
        } else {
          // Show an error if the audio file is too long
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Audio file is longer than 1 minute 45 seconds')),
          );
        }
      }
    }
  }

  void _upload() {
    if (selectedImageBytes != null && selectedAudioPath != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PreviewScreen(
            imageBytes: selectedImageBytes!,
            audioPath: selectedAudioPath!,
            songName: songNameController.text,
            performedBy: performedByController.text,
            writtenBy: writtenByController.text,
            producedBy: producedByController.text,
          ),
        ),
      ).then((_) {
        // After returning from PreviewScreen, refresh the songs in MusicProvider
        final musicProvider = Provider.of<MusicProvider>(context, listen: false);
        musicProvider.fetchSongs();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both an image and an audio file')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildUploadButton(),
    );
  }

  Widget _buildUploadButton() {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              InkWell(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.width * 0.9,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: selectedImageBytes == null
                          ? const Center(
                        child: Text(
                          'Upload Albumart',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                          : ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.memory(
                          selectedImageBytes!,
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: MediaQuery.of(context).size.width * 0.9,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    if (selectedImageBytes == null && selectedImagePath != null)
                      const CircularProgressIndicator(),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextButton(
                  onPressed: _pickAudio,
                  child: Text(
                    selectedAudioPath == null
                        ? 'Upload Master file'
                        : 'Audio Selected: ${selectedAudioPath!.split('/').last}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: const Text(
              'Note: The song duration must not be greater than 1 minute 45 seconds',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              )),
          ),
              const SizedBox(height: 20),
              _buildTextField('Song Name', songNameController),
              const SizedBox(height: 20),
              _buildTextField('Performed by', performedByController),
              const SizedBox(height: 20),
              _buildTextField('Written by', writtenByController),
              const SizedBox(height: 20),
              _buildTextField('Produced by', producedByController),
              const SizedBox(height: 20),
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextButton(
                  onPressed: _upload,
                  child: const Text(
                    'Preview',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: 20),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
