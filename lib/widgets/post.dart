import 'dart:async';

import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:photogram/models/user.dart';
import 'package:photogram/pages/comments.dart';
import 'package:photogram/pages/home.dart';
import 'package:photogram/utils/dbUtil.dart';
import 'package:photogram/widgets/progress.dart';

import 'custom_image.dart';

class Post extends StatefulWidget {
  final String postId;
  final String description;
  final String location;
  final String ownerId;
  final String userName;
  final String mediaUrl;
  final dynamic likes;

  Post({
    this.postId,
    this.description,
    this.location,
    this.ownerId,
    this.mediaUrl,
    this.userName,
    this.likes,
  });

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      postId: doc['postId'],
      description: doc['description'],
      ownerId: doc['ownerId'],
      userName: doc['userName'],
      location: doc['location'],
      mediaUrl: doc['mediaUrl'],
      likes: doc['likes'],
    );
  }

  getLikeCount(likes) {
    if (likes == null) {
      return 0;
    }
    int count = 0;
    likes.values.forEach((val) {
      if (val == true) {
        count += 1;
      }
    });
    return count;
  }

  @override
  _PostState createState() => _PostState(
      postId: this.postId,
      description: this.description,
      location: this.location,
      userName: this.userName,
      ownerId: this.ownerId,
      mediaUrl: this.mediaUrl,
      likes: this.likes,
      likeCount: getLikeCount(this.likes));
}

class _PostState extends State<Post> {
  final String currentUserId = currentUser?.id;
  final String postId;
  final String description;
  final String location;
  final String ownerId;
  final String userName;
  final String mediaUrl;
  int likeCount;
  Map likes;
  bool isLiked = false;
  bool showHeart = false;

  _PostState(
      {this.postId,
      this.description,
      this.location,
      this.ownerId,
      this.userName,
      this.mediaUrl,
      this.likes,
      this.likeCount});

  buildPostHeader() {
    return FutureBuilder(
      future: usersRef.document(ownerId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        User user = User.fromDocument(snapshot.data);
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(user.photoUrl),
            backgroundColor: Colors.grey,
          ),
          title: GestureDetector(
            child: Text(
              user.username,
              style: (TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              )),
            ),
          ),
          subtitle: Text(
            location,
            style: TextStyle(color: Colors.white),
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  buildPostImage() {
    return GestureDetector(
      onDoubleTap: () => handleLikePost(),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          cachedNetworkImage(mediaUrl),
          showHeart
              ? Animator(
                  duration: Duration(milliseconds: 400),
                  tween: Tween(begin: 0.8, end: 1.4),
                  curve: Curves.easeOut,
                  cycles: 0,
                  builder: (context, animatorState, child) => Transform.scale(
                    scale: animatorState.value,
                    child: Icon(
                      Icons.favorite,
                      size: 80.0,
                      color: Colors.pink,
                    ),
                  ),
                )
              : Text('')
        ],
      ),
    );
  }

  removeLikeFromActivityFeed() {
    bool isNotPostOwner = currentUserId != ownerId;
    if (isNotPostOwner) {
      feedRef
          .document(ownerId)
          .collection('feedItems')
          .document(postId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    }
  }

  addLikeToActivityFeed() {
    bool isNotPostOwner = currentUserId != ownerId;
    if (isNotPostOwner) {
      feedRef
          .document(ownerId)
          .collection('feedItems')
          .document(postId)
          .setData({
        'type': 'like',
        'username': currentUser.username,
        'userId': currentUser.id,
        'userProfileImg': currentUser.photoUrl,
        'postId': postId,
        'mediaUrl': mediaUrl,
        'timeStamp': timestamp,
      });
    }
  }

  handleLikePost() {
    bool _isLiked = likes[currentUserId] == true;
    if (_isLiked) {
      postRef
          .document(ownerId)
          .collection('userPosts')
          .document(postId)
          .updateData({'likes.$currentUserId': false});
      removeLikeFromActivityFeed();
      setState(() {
        likeCount -= 1;
        isLiked = false;
        likes[currentUserId] = false;
      });
    } else if (!_isLiked) {
      postRef
          .document(ownerId)
          .collection('userPosts')
          .document(postId)
          .updateData({'likes.$currentUserId': true});
      addLikeToActivityFeed();
      setState(() {
        likeCount += 1;
        isLiked = true;
        likes[currentUserId] = true;
        showHeart = true;
      });
      Timer(Duration(milliseconds: 500), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }

  buildPostFooter() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 40.0, left: 20.0),
            ),
            GestureDetector(
              onTap: () => handleLikePost(),
              child: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: Colors.pink,
                size: 28.0,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 20.0),
            ),
            GestureDetector(
              onTap: () => showComments(context,
                  postId: postId, ownerId: ownerId, medialUrl: mediaUrl),
              child: Icon(
                Icons.comment,
                color: Colors.blue[900],
                size: 28.0,
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                "$likeCount likes",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                "$userName ",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Text(
                description,
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      ],
    );
  }

  showComments(BuildContext context,
      {String postId, String ownerId, String medialUrl}) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Comments(
          postId: postId, postOwnerId: ownerId, postMediaUrl: medialUrl);
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildPostHeader(),
        buildPostImage(),
        buildPostFooter(),
      ],
    );
  }
}
