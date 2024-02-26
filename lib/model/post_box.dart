import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:concord/model/comment_card.dart';
import 'package:concord/resources/firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'like_animation.dart';

class PostBox extends StatefulWidget {
  final snap;

  const PostBox({Key? key, required this.snap}) : super(key: key);

  @override
  State<PostBox> createState() => _PostBoxState();
}

class _PostBoxState extends State<PostBox> {

  bool isLikeAnimating = false;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _commentController.dispose();
  }



  @override
  Widget build(BuildContext context) {
    final User user = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              //post
              GestureDetector(
                onDoubleTap: () {
                    FirestoreMethods().dLikePost(widget.snap['postId'].toString(), user.uid, widget.snap['likes']);
                  setState((){
                    isLikeAnimating = true;
                  });

                },
                child: Stack(
                  alignment: Alignment.center,
                  children:[
                    ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Hero(
                      tag: widget.snap['postUrl'],
                      child: CachedNetworkImage(
                        imageUrl:widget.snap['postUrl'],
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: isLikeAnimating? 1:0,
                      child: LikeAnimation(
                        isAnimating: isLikeAnimating,
                        child: const Icon(Icons.favorite,
                            color: Colors.white,size: 100),
                        duration: const Duration(
                          milliseconds: 400,
                        ),
                        onEnd: () {
                          setState((){
                            isLikeAnimating = false;
                          });
                        },
                      ),
                    ),
                  ]
                ),
              ),//check whether like is animating
              // post info
              SizedBox(
                height: 8,
              ),
              Column(
                children: [
                  Container(
                    //color: Colors.blue,
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 6)
                            .copyWith(right: 0),
                    child: Row(
                      children: [
                        Container(
                          //color: Colors.green,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundImage:
                                NetworkImage(widget.snap['profImage']),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: ClipRRect(
                              child: Container(
                                //color: Colors.blue,
                                  child: Padding(
                                padding: const EdgeInsets.all(0.0),
                                child: Text(
                                  widget.snap['displayName'],
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontFamily: 'Josefin',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Container(
                         // color: Colors.red,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16.0),
                            child: Container(
                              child: Padding(
                                padding: const EdgeInsets.all(0.0),
                                child: Text(
                                  DateFormat('dd MMM yy').format(
                                      widget.snap['datePublished'].toDate()),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: 5,)
                      ],
                    ),
                  ),

                  // description
                  ClipRRect(
                    child: Container(

                      //color: Colors.brown,
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(60.0, 0, 8.0, 0.0),
                          child: Container(
                            //color: Colors.amber,
                            child: Text(
                              widget.snap['description'],
                              style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        )),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  //cords here :>
                ],
              ),
              SizedBox(
                height: 10,
              ),
              //COMMENT BOXES
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('Posts')
                    .doc(widget.snap['postId'])
                    .collection('comments')
                    .orderBy('datePublished', descending: true)
                    .snapshots(),
                builder: (context,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                        snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    physics: NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    shrinkWrap: true,
                    itemBuilder: (ctx, index) => CommentCard(
                        snap: snapshot.data!.docs[index],
                    )
                  );
                },
              ),
            ],
          ),
        ),
      ),
      //COMMENT TEXT BAR
      bottomNavigationBar: SafeArea(
        child: Container(
          height: kToolbarHeight,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          padding: EdgeInsets.only(left: 18, right: 18),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(
                  user.photoURL!,
                ),
                radius: 18,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 8.0),
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'comment as ${user.displayName}',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                  await FirestoreMethods().uploadComment(
                    widget.snap['postId'],
                    _commentController.text,
                    user.uid,
                    user.displayName,
                    user.photoURL,
                  );
                  setState(() {
                    _commentController.text = "";
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 8,
                  ), // EdgeInsets.symmetric
                  child: const Text(
                    ' Post ',
                    style: TextStyle(
                      color: Colors.blue,
                    ), // TextStyle
                  ), // Text
                ), // Container
              ) // Inkwell
            ],
          ),
        ),
      ),
    );
  }
}
