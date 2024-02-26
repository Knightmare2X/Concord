import 'package:concord/model/nav_bar.dart';
import 'package:concord/resources/auth.dart';
import 'package:concord/resources/firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'dart:math';

import '../main.dart';
import '../model/follow_button.dart';
import '../model/image_card.dart';
import '../utils/utils.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {

  final String uid;

  const ProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth auth = FirebaseAuth.instance;
  var userData = {};
  int viewLen = 0;
  int followers = 0;
  int following = 0;
  bool isFollowing = false;
  bool isLoading = false;




  final List<String> imageUrls = [
    // Add your image URLs here
    "https://plus.unsplash.com/premium_photo-1688114984765-308599ec1e13?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=387&q=80",
    "https://images.unsplash.com/photo-1662010021854-e67c538ea7a9?ixlib=rb-4.0.3&ixid=M3wxMjA3fDF8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=352&q=80",
    "https://images.unsplash.com/photo-1661956602153-23384936a1d3?ixlib=rb-4.0.3&ixid=M3wxMjA3fDF8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1170&q=80",
    "https://plus.unsplash.com/premium_photo-1688464908902-35c67647df83?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=435&q=80",
  ];

  @override
  Widget build(BuildContext context) {
    int backgroundIndex = Random().nextInt(imageUrls.length);

    return isLoading
        ? const Center(
      child: CircularProgressIndicator(),
    )
        : Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child:  StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Users')
                .doc(widget.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              if (!snapshot.hasData || snapshot.data == null) {
                return Center(
                  child: Text(
                    'No data available',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                );
              }

              var userSnap = snapshot.data!;

              // Check if the document exists
              if (userSnap.exists) {
                userData = userSnap.data()! as dynamic;
                followers = userData['followers']?.length ?? 0;
                following = userData['following']?.length ?? 0;
                isFollowing = userData['followers']?.contains(FirebaseAuth.instance.currentUser!.uid) ?? false;
                viewLen = userData['totalViews'] ?? 0;
              } else {
                showSnackBar(
                  context,
                  'User data not found.',
                );
              }
              return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 6, left: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                userData['username'] ?? ' User Profile',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Josefin',
                                ),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              // Show modal bottom sheet when the settings icon is tapped
                              if (FirebaseAuth.instance.currentUser!.uid == widget.uid)
                                IconButton(
                                  icon: Icon(Icons.settings),
                                  onPressed: () {
                                    // Show the modal bottom sheet
                                    showModalBottomSheet<void>(
                                      context: context,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                        ),
                                      ),
                                      builder: (BuildContext context) {
                                        return Container(
                                          height: 200,
                                          alignment: Alignment.center,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  primary: Colors.red,
                                                  minimumSize: const Size.fromHeight(50),
                                                ),
                                                onPressed: () /*async {
                                                  try{
                                                    await googleSignIn.signOut();
                                                    await auth.signOut();
                                                    Navigator.of(context, rootNavigator: true).pushReplacement(MaterialPageRoute(
                                                        builder: (context) => LoginScreen(),
                                                    ));
                                                  }catch (e) {
                                                    print('Error signing out: $e');
                                                  }*/
              { signOut(context);
                                                },
                                                child: Text(
                                                  "Sign Out",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),


                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, top: 8, bottom: 8),
                          child: GridView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: imageUrls.length,
                            gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                            ),
                            itemBuilder: (context, index) {
                              final imageUrl = imageUrls[index];

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          FullScreenImage(imageUrl: imageUrl),
                                    ),
                                  );
                                },
                                child: Hero(
                                  tag: imageUrl,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              image: DecorationImage(
                                image:
                                NetworkImage(imageUrls[backgroundIndex]),
                                fit: BoxFit.cover,
                                colorFilter: ColorFilter.mode(
                                  Colors.black.withOpacity(0.5),
                                  BlendMode.darken,
                                ),
                              ),
                            ),
                            child: Row(
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FullScreenImage(
                                            imageUrl: userData['photoURL']),
                                      ),
                                    );
                                  },
                                  child: Hero(
                                    tag: "profile_avatar",
                                    child: Container(
                                      width:
                                      MediaQuery.of(context).size.width *
                                          0.2,
                                      // Adjust the multiplier as needed
                                      height:
                                      MediaQuery.of(context).size.width *
                                          0.2,
                                      // You can use size.height for different orientation
                                      child: CircleAvatar(
                                        backgroundImage: NetworkImage(
                                            userData['photoURL']),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.01),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Expanded(
                                    flex: 3,
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _buildStat(
                                            context, "Views",
                                      NumberFormat.compact().format(viewLen).toLowerCase()),
                                        SizedBox(width: 16),
                                        _buildStat(context, "Followers",
                                            NumberFormat.compact().format(followers).toLowerCase()),
                                        SizedBox(width: 16),
                                        _buildStat(context, "Following",
                                            NumberFormat.compact().format(following).toLowerCase()),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        FirebaseAuth.instance.currentUser!.uid == widget.uid
                            ? FollowButton(
                          text: 'Edit Profile',
                          backgroundColor: Color.fromRGBO(0, 0, 0, 1),
                          textColor: Colors.white,
                          borderColor: Colors.grey,
                          function: () {},
                        )
                            : isFollowing
                            ? FollowButton(
                            text: 'Unfollow',
                            backgroundColor: Colors.white,
                            textColor: Colors.black,
                            borderColor: Colors.grey,
                            function: () async {
                              bool success = await FirestoreMethods().followUser(
                                  FirebaseAuth
                                      .instance.currentUser!.uid,
                                  userData['uid']);
                              if (success) {
                                setState(() {
                                  isFollowing = true;
                                  followers--;
                                });
                              }  else{
                                print("error in upload");
                              }
                            })
                            : FollowButton(
                          text: 'Follow',
                          backgroundColor: Colors.blue,
                          textColor: Colors.white,
                          borderColor: Colors.blue,
                          function: () async {
                            bool success = await FirestoreMethods().followUser(
                                FirebaseAuth
                                    .instance.currentUser!.uid,
                                userData['uid']);
                            if (success) {
                              setState(() {
                                isFollowing = true;
                                followers++;
                              });
                            }  else{
                              print("error in upload");
                            }
                          },
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, top: 8, bottom: 8),
                          child: FutureBuilder<
                              QuerySnapshot<Map<String, dynamic>>>(
                            future: FirebaseFirestore.instance
                                .collection('Posts')
                                .where('uid', isEqualTo: widget.uid)
                                .orderBy('datePublished',
                                descending:
                                true) // Order by datePublished in descending order
                                .get(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              if (!snapshot.hasData ||
                                  snapshot.data == null) {
                                return Center(
                                  child: Text(
                                    'No posts',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                );
                              }

                              final docs = snapshot.data!.docs;

                              return MasonryGridView.count(
                                shrinkWrap: true,
                                itemCount: snapshot.data!.docs.length,
                                physics: const ScrollPhysics(),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 5,
                                  horizontal: 0,
                                ),
                                // the number of columns
                                crossAxisCount: 2,
                                // vertical gap between two items
                                mainAxisSpacing: 8,
                                // horizontal gap between two items
                                crossAxisSpacing: 8,
                                itemBuilder: (context, index) => ImageCard(
                                  snap: snapshot.data!.docs[index].data(),
                                ),
                              );
                            },
                          ),
                        )
                      ],
                    );
            }
          ),
        ),
      ),

    );
  }
}

Widget _buildStat(BuildContext context, String label, String value) {
  final fontSize = MediaQuery.of(context).size.width *
      0.04; // Adjust the multiplier as needed
  return Align(
    alignment: Alignment.center,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: fontSize),
        ),
      ],
    ),
  );
}

class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
          color: Colors.black,
          child: Center(
            child: Hero(
              tag: imageUrl,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
