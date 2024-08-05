import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:concord/resources/auth.dart';
import 'package:concord/resources/firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';

import '../widgets/follow_button.dart';
import '../widgets/image_card.dart';
import '../utils/utils.dart';

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
  List<String> descPics = [
    "assets/placeholders/placeholder1.png",
    "assets/placeholders/placeholder2.png",
    "assets/placeholders/placeholder3.png",
    "assets/placeholders/placeholder4.png",
  ];

  @override
  void initState() {
    super.initState();
    _fetchDescPics();
  }

  Future<void> _fetchDescPics() async {
    setState(() {
      isLoading = true;
    });

    try {
      final userData = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.uid)
          .get();
      final descPicsData = userData['descPic'] as List<dynamic>;
      descPics = descPicsData.cast<String>(); // Convert to List<String>
    } catch (error) {
      print("Error fetching descPics: $error");
      // Handle error
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : SingleChildScrollView(
        child: SafeArea(
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Users')
                .doc(widget.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (!snapshot.hasData || snapshot.data == null) {
                return const Center(
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
                isFollowing = userData['followers']?.contains(
                    FirebaseAuth.instance.currentUser!.uid) ??
                    false;
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
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Josefin',
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        if (FirebaseAuth.instance.currentUser!.uid ==
                            widget.uid)
                          IconButton(
                            icon: const Icon(Icons.settings),
                            onPressed: () {
                              // Show the modal bottom sheet
                              showModalBottomSheet<void>(
                                context: context,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    topRight: Radius.circular(15),
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
                                            backgroundColor: Colors.red,
                                            minimumSize:
                                            const Size.fromHeight(50),
                                          ),
                                          onPressed: () {
                                            signOut(context);
                                          },
                                          child: const Text(
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
                      itemCount: descPics.length,
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemBuilder: (context, index) {
                        final imageUrl = descPics[index];

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
                              child: getImageWidget(imageUrl),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              if (userData['photoURL'] != null &&
                                  userData['photoURL'].isNotEmpty) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        FullScreenImage(
                                          imageUrl: userData['photoURL'],
                                        ),
                                  ),
                                );
                              }
                            },
                            child: Hero(
                              tag: "profile_avatar",
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width *
                                    0.2,
                                height:
                                MediaQuery.of(context).size.width *
                                    0.2,
                                child: userData['photoURL'] != null &&
                                    userData['photoURL'].isNotEmpty
                                    ? CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      userData['photoURL']),
                                )
                                    : Icon(
                                  Icons.account_circle,
                                  size: MediaQuery.of(context)
                                      .size
                                      .width *
                                      0.2,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width:
                            MediaQuery.of(context).size.width * 0.01,
                          ),
                          Expanded(
                            flex: 3,
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceEvenly,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildStat(
                                  context,
                                  "Views",
                                  NumberFormat.compact()
                                      .format(viewLen)
                                      .toLowerCase(),
                                ),
                                const SizedBox(width: 16),
                                _buildStat(
                                  context,
                                  "Followers",
                                  NumberFormat.compact()
                                      .format(followers)
                                      .toLowerCase(),
                                ),
                                const SizedBox(width: 16),
                                _buildStat(
                                  context,
                                  "Following",
                                  NumberFormat.compact()
                                      .format(following)
                                      .toLowerCase(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  FirebaseAuth.instance.currentUser!.uid == widget.uid
                      ? FollowButton(
                    text: 'Edit Profile',
                    backgroundColor:
                    const Color.fromRGBO(0, 0, 0, 1),
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
                        bool success = await FirestoreMethods()
                            .followUser(
                            FirebaseAuth
                                .instance.currentUser!.uid,
                            userData['uid']);
                        if (success) {
                          setState(() {
                            isFollowing = true;
                            followers--;
                          });
                        } else {
                          print("error in upload");
                        }
                      })
                      : FollowButton(
                    text: 'Follow',
                    backgroundColor: Colors.blue,
                    textColor: Colors.white,
                    borderColor: Colors.blue,
                    function: () async {
                      bool success = await FirestoreMethods()
                          .followUser(
                          FirebaseAuth
                              .instance.currentUser!.uid,
                          userData['uid']);
                      if (success) {
                        setState(() {
                          isFollowing = true;
                          followers++;
                        });
                      } else {
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
                    child: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      future: FirebaseFirestore.instance
                          .collection('Posts')
                          .where('uid', isEqualTo: widget.uid)
                          .orderBy('datePublished', descending: true)
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (!snapshot.hasData ||
                            snapshot.data == null ||
                            snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Text(
                              'No posts',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          );
                        }

                        return MasonryGridView.count(
                          shrinkWrap: true,
                          itemCount: snapshot.data!.docs.length,
                          physics: const ScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 0,
                          ),
                          crossAxisCount: 2,
                          mainAxisSpacing: 8,
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
            },
          ),
        ),
      ),
    );
  }

  Widget getImageWidget(String imageUrl) {
    if (imageUrl.startsWith("assets")) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Opacity(
          opacity: 0.5,
          child: Image.asset(
            imageUrl,
            fit: BoxFit.fill,
          ),
        ),
        errorWidget: (context, url, error) => Opacity(
          opacity: 0.5,
          child: Image.asset(
            imageUrl,
            fit: BoxFit.fill,
          ),
        ),
      );
    } else {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
      );
    }
  }

  Widget _buildStat(BuildContext context, String label, String value) {
    final fontSize = MediaQuery.of(context).size.width * 0.04;
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
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: fontSize),
          ),
        ],
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImage({Key? key, required this.imageUrl}) : super(key: key);

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
                child: getImageWidget(imageUrl),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getImageWidget(String imageUrl) {
    if (imageUrl.startsWith("assets")) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Opacity(
          opacity: 0.5,
          child: Image.asset(
            imageUrl,
            fit: BoxFit.fill,
          ),
        ),
        errorWidget: (context, url, error) => Opacity(
          opacity: 0.5,
          child: Image.asset(
            imageUrl,
            fit: BoxFit.fill,
          ),
        ),
      );
    } else {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
      );
    }
  }
}
