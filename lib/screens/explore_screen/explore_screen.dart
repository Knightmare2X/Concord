import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:concord/widgets/image_card.dart';
import 'package:concord/screens/upload_screen/upload_song.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../upload_screen/upload_images.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final User user = FirebaseAuth.instance.currentUser!;


  @override
  Widget build(BuildContext context) {
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
                  const Text(
                    'Explore',
                    style: TextStyle(
                      fontSize: 52,
                      fontFamily: 'Josefin',
                    ),
                  ),
                  IconButton(
                    onPressed: () => showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 90, // Adjust the width of the SizedBox to control spacing
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const UploadImages()));
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey, // Outline color
                                    ),
                                    borderRadius: BorderRadius.circular(10.0), // Rounded corners
                                  ),
                                  padding: const EdgeInsets.all(5.0), // Padding inside the container
                                  height: 90, // Adjust the height to make it square
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image, // Icon
                                        size: 36.0, // Icon size
                                      ),
                                      SizedBox(height: 8.0), // Space between icon and text
                                      Text(
                                        'Images', // Text
                                        style: TextStyle(
                                          fontSize: 14.0, // Text size
                                          fontWeight: FontWeight.bold, // Text bold
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16), // Space between the two containers
                            SizedBox(
                              width: 90, // Adjust the width of the SizedBox to control spacing
                              child: GestureDetector(
                                onTap: (){
                                  Navigator.of(context).pop();
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const UploadSong()));
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey, // Outline color
                                    ),
                                    borderRadius: BorderRadius.circular(10.0), // Rounded corners
                                  ),
                                  padding: const EdgeInsets.all(5.0), // Padding inside the container
                                  height: 90, // Adjust the height to make it square
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.music_note, // Icon
                                        size: 36.0, // Icon size
                                      ),
                                      SizedBox(height: 8.0), // Space between icon and text
                                      Text(
                                        'Music', // Text
                                        style: TextStyle(
                                          fontSize: 14.0, // Text size
                                          fontWeight: FontWeight.bold, // Text bold
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );

                      },
                    ),
                    icon: const Icon(
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
              return Expanded(
                child: StreamBuilder<QuerySnapshot>(
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
                    final List<QueryDocumentSnapshot> docs =
                        snapshot.data!.docs;
                    return Expanded(
                      child: StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('Users')
                            .doc(user
                                .uid) // Assuming currentUserUid is the UID of the current user
                            .snapshots(),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final List<dynamic> following =
                              userSnapshot.data!['following'];
                          final filteredDocs = docs
                              .where((doc) =>
                                  following.contains(doc['uid']) ||
                                  doc['uid'] == user.uid)
                              .toList();
                          return MasonryGridView.count(
                            shrinkWrap: true,
                            itemCount: filteredDocs.length,
                            physics: const ScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                                vertical: 30, horizontal: 10),
                            crossAxisCount: 2,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            itemBuilder: (context, index) => ImageCard(
                              snap: filteredDocs[index].data(),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }


}
