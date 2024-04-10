import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../resources/firestore.dart';
import '../../utils/utils.dart';

class UploadImages extends StatefulWidget {
  const UploadImages({Key? key}) : super(key: key);

  @override
  State<UploadImages> createState() => _UploadImagesState();
}

class _UploadImagesState extends State<UploadImages> {
  final User user = FirebaseAuth.instance.currentUser!;
  Uint8List? _file;
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;
  bool _isClicked = true;

  Future<void> imagePick() async {
    Uint8List file = await pickImage(ImageSource.gallery);
    setState(() {
      _file = file;
    });
  }

  Future<void> postImage(String uid, username, profImage) async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Retrieve user data from Firestore
      DocumentSnapshot userSnapshot =
      await FirebaseFirestore.instance.collection('Users').doc(uid).get();
      if (userSnapshot.exists) {
        String username = userSnapshot['username'];
        String profImage = userSnapshot['photoURL'];

        // Upload post using retrieved username and photoURL
        String res = await FirestoreMethods().uploadPost(
          _descriptionController.text,
          _file!,
          uid,
          username,
          profImage,
        );

        if (res == "success") {
          setState(() {
            _isLoading = false;
            _isClicked = true;
          });
          if (context.mounted) {
            showSnackBar(context, 'Posted!');
          }
          clearImage();
          _descriptionController.clear();
        } else {
          if (context.mounted) {
            showSnackBar(context, res);
          }
        }
      } else {
        throw Exception('User data not found.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (context.mounted) {
        showSnackBar(context, e.toString());
      }
    }
  }

  void clearImage() {
    setState(() {
      _file = null;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _descriptionController.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: _file == null ? _buildUploadButton() : _buildImagePreview(),
    );
  }

  Widget _buildUploadButton(){
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white, // Border color
                  width: 2, // Border width
                ),
                borderRadius: BorderRadius.circular(10), // Rounded corners
              ),
              child: TextButton(
                onPressed: () => imagePick() ,
                child: const Text(
                  'Upload Image',
                  style: TextStyle(
                    color: Colors.white, // Text color
                    fontSize: 20, // Text size
                  ),
                ),
              ),
            ),
          ),
        ],
      )
    );
  }


  Widget _buildImagePreview() {
    return FutureBuilder<DocumentSnapshot>(
      future:
      FirebaseFirestore.instance.collection('Users').doc(user.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Text('User not found'); // handle if user not found
        }

        Map<String, dynamic> userData =
        snapshot.data!.data() as Map<String, dynamic>;
        String username = userData['username'];
        String photoURL = userData['photoURL'];

        return Scaffold(
          body: WillPopScope(
            onWillPop: () async {
              clearImage();
              Navigator.pop(context);
              return false;
            },
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _isLoading ? const LinearProgressIndicator() : Container(),
                    Container(),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: Image.memory(
                        _file!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(
                      height: 8.0,
                    ),
                    Column(
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16.0),
                            child: Container(
                              color: Colors.white24,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  DateFormat('dd MMMM yyyy')
                                      .format(DateTime.now()),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(photoURL),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: TextField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(
                              hintText: 'Write a caption...',
                              border: InputBorder.none,
                            ),
                            maxLines: 4,
                          ),
                        ),
                        // OutlinedButton
                      ],
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: OutlinedButton(
                        onPressed: () {
                          // This is what you should add in your code
                          if (_isClicked) {
                            _isClicked = false;
                            postImage(user.uid, username, photoURL);
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blueAccent,
                          side: const BorderSide(color: Colors.lightBlue),
                        ),
                        child: const Text('Post'),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

}
