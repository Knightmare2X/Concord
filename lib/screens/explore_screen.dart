import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:concord/model/image_card.dart';
import 'package:concord/resources/firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../utils/utils.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
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
          showSnackBar(context, 'Posted!');
          clearImage();
          _descriptionController.clear();
        } else {
          showSnackBar(context, res);
        }
      } else {
        throw Exception('User data not found.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showSnackBar(context, e.toString());
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
    return Scaffold(
      body: _file == null ? _buildImageGridView() : _buildImagePreview(),
    );
  }

  //place where you have all your feed
  Widget _buildImageGridView() {
    return Scaffold(
      body: ListView(
        physics: const ScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height / 9.5,
            width: MediaQuery.of(context).size.width,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height / 5,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: Column(
                children: [
                  Text(
                    'Explore',
                    style: TextStyle(
                      fontSize: 52,
                      fontFamily: 'Josefin',
                    ),
                  ),
                  IconButton(
                    onPressed: () => imagePick(),
                    icon: Icon(
                      Icons.add_box_outlined,
                      size: 35,
                    ),
                  ),
                ],
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Posts')
                .orderBy('datePublished', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              final List<QueryDocumentSnapshot> docs = snapshot.data!.docs;
              return Expanded(
                child: MasonryGridView.count(
                  shrinkWrap: true,
                  itemCount: docs.length,
                  physics: const ScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  itemBuilder: (context, index) => ImageCard(
                    snap: docs[index].data(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
  return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('Users').doc(user.uid).get(),
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
          return Text('User not found'); // handle if user not found
        }

        Map<String, dynamic> userData = snapshot.data!.data() as Map<String, dynamic>;
        String username = userData['username'];
        String photoURL = userData['photoURL'];

        return Scaffold(
          body: WillPopScope(
            onWillPop: () async {
              clearImage();
              Navigator.of(context).pop();
              return false;
            },
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _isLoading ? LinearProgressIndicator() : Container(),
                    Container(),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: Image.memory(
                        _file!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(
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
                                  DateFormat('dd MMMM yyyy').format(DateTime.now()),
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
                            decoration: InputDecoration(
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
                        child: Text('Post'),
                        style: OutlinedButton.styleFrom(
                          primary: Colors.blueAccent,
                          side: BorderSide(color: Colors.lightBlue),
                        ),
                      ),
                    ),
                    SizedBox(
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
