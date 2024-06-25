import 'package:cached_network_image/cached_network_image.dart';
import 'package:concord/resources/firestore.dart';
import 'package:concord/screens/explore_screen/post_box.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'like_animation.dart';

class ImageCard extends StatefulWidget {
  final dynamic snap;

  const ImageCard({Key? key, required this.snap}) : super(key: key);

  @override
  State<ImageCard> createState() => _ImageCardState();
}

class _ImageCardState extends State<ImageCard> {
  bool isLikeAnimating = false;

  @override
  Widget build(BuildContext context) {
    final User user = FirebaseAuth.instance.currentUser!;
    bool isPostOwner = widget.snap['uid'] == user.uid; // Check if the current user is the owner of the post

    return GestureDetector(
      onLongPress: () {
        showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            builder: (BuildContext context) {
              return SizedBox(
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      isPostOwner
                          ? ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          minimumSize: const Size.fromHeight(50), // NEW
                        ),
                        child: const Text(
                          'Delete Post',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () async {
                          await FirestoreMethods().deletePost(widget.snap['postId']);
                          Navigator.of(context).pop();
                        },
                      )
                          : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          minimumSize: const Size.fromHeight(50), // NEW
                        ),
                        child: const Text(
                          'Cannot delete this post',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
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
        if (context.mounted) {
          await FirestoreMethods()
              .viewPost(widget.snap['postId'], user.uid, widget.snap['views']);
          if (context.mounted) {
            Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
                builder: (context) => PostBox(snap: widget.snap)));
          }
        }
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
                    isAnimating: isLikeAnimating,
                    duration: const Duration(
                      milliseconds: 400,
                    ),
                    onEnd: () {
                      setState(() {
                        isLikeAnimating = false;
                      });
                    },
                    child: const Icon(Icons.favorite,
                        color: Colors.white, size: 100),
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
          const SizedBox(
            height: 5,
          ),
          Column(
            children: [
              Row(
                children: [
                  const SizedBox(
                    width: 5,
                  ),
                  CachedNetworkImage(
                    imageUrl: widget.snap['profImage'],
                    imageBuilder: (context, imageProvider) => CircleAvatar(
                      radius: 9,
                      backgroundImage: imageProvider,
                    ),
                    placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                    const Icon(Icons.error),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: ClipRRect(
                        child: Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: Text(
                            widget.snap['displayName'],
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15.0,
                              fontFamily: 'Josefin',
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  LikeAnimation(
                    isAnimating: widget.snap['likes'].contains(user.uid),
                    smallLike: true,
                    child: GestureDetector(
                      onTap: () async => await FirestoreMethods().tLikePost(
                        widget.snap['postId'].toString(),
                        user.uid,
                        widget.snap['likes'],
                      ),
                      child: widget.snap['likes'].contains(user.uid)
                          ? const Icon(
                        Icons.favorite,
                        size: 16,
                        color: Colors.red,
                      )
                          : const Icon(
                        Icons.favorite_border,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    NumberFormat.compact()
                        .format(widget.snap['likes'].length)
                        .toLowerCase(),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
