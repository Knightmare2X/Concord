import 'dart:typed_data';

import 'package:concord/model/persist_nav_bar.dart';
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final Uint8List? bytes = await pickedFile.readAsBytes();
     if (bytes != null) {
       setState(() {
         selectedImageBytes = bytes;
       });
     }

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
          title: Text(
            "Almost Done",
            style: TextStyle(
                fontFamily: "Pacifico",
                fontSize: 30,
                decoration: TextDecoration.underline),
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 40),
                InkWell(
                  onTap: _pickImage,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey,
                        radius: 90,
                        child: selectedImageBytes != null
                            ? null
                            : Icon(Icons.person,
                            size: 80,
                            color: Colors
                                .white), // Show icon only if image is not loaded
                        backgroundImage: selectedImageBytes != null
                            ? MemoryImage(selectedImageBytes!)
                            : null,
                      ),
                      if (selectedImageBytes == null &&
                          selectedImagePath !=
                              null) // Show loading indicator if image is being loaded
                        CircularProgressIndicator(),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    border: Border.all(color: Colors.grey, width: 2.0),
                    borderRadius: BorderRadius.all(Radius.circular(11)),
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
                      errorText:
                      showUsernameError ? 'Username cannot be empty' : null,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (username.isEmpty) {
                        setState(() {
                          showUsernameError = true;
                        });
                        return;
                      }

                      bool isUnique = await _checkUniqueUsername(username);

                      if (!isUnique) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Username already exists."),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        return;
                      }

                      try {
                        final User user = FirebaseAuth.instance.currentUser!;
                        await FirestoreMethods().uploadData(
                            username, user.uid, selectedImageBytes!);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Welcome"),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PersistNavBar()));
                      } catch (e) {
                        print("Error: $e");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("An error occurred."),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue.shade200,
                    ),
                    child: Text(
                      "Done",
                      style: TextStyle(
                          fontSize: 21,
                          color: Colors.white70,
                          fontFamily: 'Josefin',
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
