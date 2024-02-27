import 'package:cached_network_image/cached_network_image.dart';
import 'package:concord/model/post_box.dart';
import 'package:concord/resources/firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'like_animation.dart';

class ImageCard extends StatefulWidget {
  final snap;

  const ImageCard({required this.snap});

  @override
  State<ImageCard> createState() => _ImageCardState();
}

class _ImageCardState extends State<ImageCard> {
  bool isLikeAnimating = false;

  @override
  Widget build(BuildContext context) {
    final User user = FirebaseAuth.instance.currentUser!;
    return GestureDetector(
      onLongPress: () {
        showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Container(
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red,
                          minimumSize: const Size.fromHeight(50), // NEW
                        ),
                        child: const Text(
                          'Delete Post',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () async {
                          FirestoreMethods().deletePost(widget.snap['postId']);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
              );
            });
      },
      onTap: () async {
        await FirestoreMethods()
            .viewPost(widget.snap['postId'], user.uid, widget.snap['views']);
        Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
            builder: (context) => PostBox(snap: widget.snap)));
      },
      child: Column(
        children: [
          GestureDetector(
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: Hero(
                      tag: widget.snap['postUrl'],
                      child: CachedNetworkImage(
                          imageUrl: widget.snap['postUrl'], fit: BoxFit.cover)),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isLikeAnimating ? 1 : 0,
                  child: LikeAnimation(
                    child: const Icon(Icons.favorite,
                        color: Colors.white, size: 100),
                    isAnimating: isLikeAnimating,
                    duration: const Duration(
                      milliseconds: 400,
                    ),
                    onEnd: () {
                      setState(() {
                        isLikeAnimating = false;
                      });
                    },
                  ),
                ),
              ],
            ),
            onDoubleTap: () {
              FirestoreMethods().dLikePost(widget.snap['postId'].toString(),
                  user.uid, widget.snap['likes']);
              setState(() {
                isLikeAnimating = true;
              });
            },
          ),
          SizedBox(
            height: 5,
          ),
          Column(
            children: [
              Container(
                  child: Row(
                children: [
                  SizedBox(
                    width: 5,
                  ),
                  Container(
                    //color: Colors.green,
                    child: CachedNetworkImage(
                      imageUrl: widget.snap['profImage'],
                      imageBuilder: (context, imageProvider) => CircleAvatar(
                        radius: 9,
                        backgroundImage: imageProvider,
                      ),
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
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
                              fontSize: 15.0,
                              fontFamily: 'Josefin',
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        )),
                      ),
                    ),
                  ),
                  Container(
                    child: LikeAnimation(
                      isAnimating: widget.snap['likes'].contains(user.uid),
                      smallLike: true,
                      child: GestureDetector(
                        onTap: () async => await FirestoreMethods().tLikePost(
                          widget.snap['postId'].toString(),
                          user.uid,
                          widget.snap['likes'],
                        ),
                        child: widget.snap['likes'].contains(user.uid)
                            ? Icon(
                                Icons.favorite,
                                size: 16,
                                color: Colors.red,
                              )
                            : Icon(
                                Icons.favorite_border,
                                size: 16,
                              ),
                      ),
                    ),
                  ),
                  SizedBox(width: 3),
                  Container(
                    child: Text(
                      NumberFormat.compact()
                          .format(widget.snap['likes'].length)
                          .toLowerCase(),
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                ],
              )),
            ],
          ),
        ],
      ),
    );
  }
}
