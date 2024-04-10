import 'package:concord/model/like_animation.dart';
import 'package:concord/resources/firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CommentCard extends StatefulWidget {
  final dynamic snap;
  const CommentCard({Key? key, required this.snap}) : super(key: key);

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  final User user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(
                  widget.snap.data()['profImage'],
                ),
                radius: 18,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                        text: TextSpan(children: [
                          TextSpan(
                            text: widget.snap.data()['displayName'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          TextSpan(
                            text: '  ${widget.snap.data()['text']}',
                          ),
                        ]),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          DateFormat.yMMMd().format(
                            widget.snap.data()['datePublished'].toDate(),
                          ),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  const SizedBox(
                    width: 5,
                  ),
                  LikeAnimation(
                    isAnimating: widget.snap['likes'].contains(user.uid),
                    child: GestureDetector(
                      child: widget.snap['likes'].contains(user.uid)
                          ? const Icon(
                              Icons.favorite,
                              size: 20,
                              color: Colors.red,
                            )
                          : const Icon(
                              Icons.favorite_border,
                              size: 20,
                            ),
                      onTap: () => FirestoreMethods().likeComment(
                        widget.snap['commentId'].toString(),
                        widget.snap['postId'].toString(),
                        user.uid,
                        widget.snap['likes'],
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    NumberFormat.compact()
                        .format(widget.snap['likes'].length)
                        .toLowerCase(),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        )
      ],
    );
  }
}
