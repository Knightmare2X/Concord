import 'dart:async';
import 'dart:typed_data';

import 'package:concord/widgets/persist_nav_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../resources/firestore.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({Key? key}) : super(key: key);

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  String username = '';
  bool showUsernameError = false;
  String? selectedImagePath;
  Uint8List? selectedImageBytes; // Define a Uint8List to hold image bytes
  bool _loading = false; // Track loading state

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

  Future<bool> _checkUniqueUsername(String username) async {
    return await FirestoreMethods().isUsernameUnique(username);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text(
            "Almost Done",
            style: TextStyle(
                fontFamily: "Pacifico",
                fontSize: 30,
                decoration: TextDecoration.underline),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (_loading) const LinearProgressIndicator(), // Add progress bar
              const SizedBox(height: 40),
              InkWell(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey,
                      radius: 90,
                      backgroundImage: selectedImageBytes != null
                          ? MemoryImage(selectedImageBytes!)
                          : null,
                      child: selectedImageBytes != null
                          ? null
                          : Image.asset(
                              'assets/icons/user.png',
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                    ),
                    if (selectedImageBytes == null &&
                        selectedImagePath !=
                            null) // Show loading indicator if image is being loaded
                      const CircularProgressIndicator(),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  border: Border.all(color: Colors.grey, width: 2.0),
                  borderRadius: const BorderRadius.all(Radius.circular(11)),
                ),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      username = value.trim();
                      showUsernameError = false;
                    });
                  },
                  maxLength: 15,
                  decoration: InputDecoration(
                    hintText: 'Username',
                    counterText: '',
                    errorText: showUsernameError ? 'Invalid username' : null,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 5),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Username should only have numbers, letter, underscores and fullstop",
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () async {
                    if (_loading) return; // Don't proceed if already loading
                    if (username.isEmpty || !isValidUsername(username)) {
                      setState(() {
                        showUsernameError = true;
                      });
                      return;
                    }
                    setState(() {
                      _loading = true; // Set loading state to true
                    });

                    // Your remaining code here
                    bool isUnique = await _checkUniqueUsername(username);
                    if (!isUnique) {
                      setState(() {
                        _loading = false; // Reset loading state
                      });
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Username already exists."),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                      return;
                    }

                    try {
                      final User user = FirebaseAuth.instance.currentUser!;
                      if (selectedImageBytes != null) {
                        await FirestoreMethods().uploadData(
                          username,
                          user.uid,
                          selectedImageBytes!,
                        );
                      } else {
                        await FirestoreMethods().uploadDataWithoutImage(
                          username,
                          user.uid,
                        );
                      }

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Welcome"),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PersistNavBar(),
                          ),
                        );
                      }
                    } catch (e) {
                      print("Error: $e");
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("An error occurred."),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    } finally {
                      setState(() {
                        _loading = false; // Reset loading state on completion
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue.shade200,
                  ),
                  child: const Text(
                    "Done",
                    style: TextStyle(
                      fontSize: 21,
                      color: Colors.white70,
                      fontFamily: 'Josefin',
                      fontWeight: FontWeight.bold,
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

  bool isValidUsername(String username) {
    return RegExp(r'^[a-zA-Z0-9_.]+$').hasMatch(username);
  }
}
