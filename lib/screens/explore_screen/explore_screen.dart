import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:concord/widgets/image_card.dart';
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
      body: SingleChildScrollView(
        child: Column(
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
                      onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) =>
                                  const UploadImages()),
                                (Route<dynamic> route) => route.isFirst,);

                      },
                      icon: const Icon(
                        Icons.add_box_outlined,
                        size: 35,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(user.uid)
                  .snapshots(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (!userSnapshot.hasData) {
                  return const Center(
                    child: Text("No data available"),
                  );
                }
                final List<dynamic> following = userSnapshot.data!['following'];
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Posts')
                      .orderBy('datePublished', descending: true)
                      .snapshots(),
                  builder: (context, postSnapshot) {
                    if (postSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (!postSnapshot.hasData) {
                      return const Center(
                        child: Text("No posts available"),
                      );
                    }
                    final List<QueryDocumentSnapshot> docs =
                        postSnapshot.data!.docs;
                    final filteredDocs = docs
                        .where((doc) =>
                            following.contains(doc['uid']) ||
                            doc['uid'] == user.uid)
                        .toList();
                    return MasonryGridView.count(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(), // Disable GridView's own scrolling
                      itemCount: filteredDocs.length,
                      padding: const EdgeInsets.symmetric(
                          vertical: 30, horizontal: 10),
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      itemBuilder: (context, index) => ImageCard(
                        snap:
                            filteredDocs[index].data() as Map<String, dynamic>,
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
