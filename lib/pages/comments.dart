import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:photogram/pages/home.dart';
import 'package:photogram/utils/dbUtil.dart';
import 'package:photogram/widgets/header.dart';
import 'package:photogram/widgets/progress.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class Comments extends StatefulWidget {
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;

  Comments({this.postId, this.postMediaUrl, this.postOwnerId});

  @override
  CommentsState createState() => CommentsState(
      postId: this.postId,
      postMediaUrl: this.postMediaUrl,
      postOwnerId: this.postOwnerId);
}

class CommentsState extends State<Comments> {
  TextEditingController commentsController = TextEditingController();
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;

  CommentsState({this.postId, this.postMediaUrl, this.postOwnerId});

  buildComment() {
    return StreamBuilder(
      stream: commentsRef
          .document(postId)
          .collection('comments')
          .orderBy('timestamp', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<Comment> comment = [];
        snapshot.data.documents.forEach((doc) {
          comment.add(Comment.fromDocument(doc));
        });
        return ListView(children: comment);
      },
    );
  }

  addComment() {
    commentsRef.document(postId).collection('comments').add({
      'username': currentUser.username,
      'comment': commentsController.text,
      'timestamp': timestamp,
      'avatarUrl': currentUser.photoUrl,
      'userId': currentUser.id,
    });

    bool isNotPostOwner = postOwnerId != currentUser.id;
    if(isNotPostOwner){
    feedRef.document(postOwnerId).collection('feedItems').add({
      'type': 'comment',
      'commentData': commentsController.text,
      'username': currentUser.username,
      'userId': currentUser.id,
      'userProfileImg': currentUser.photoUrl,
      'postId': postId,
      'mediaUrl': postMediaUrl,
      'timeStamp': timestamp,
    });}
    commentsController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: header(false, true, title: 'Comments'),
      body: Column(
        children: <Widget>[
          Expanded(child: buildComment()),
          Divider(
          ),
          ListTile(
            trailing: OutlineButton(
              color: Colors.white,
              onPressed: () => addComment(),
              borderSide: BorderSide.none,
              child: Text('Post',
              style: TextStyle(
                color: Colors.white
              ),),
            ),
            title: TextFormField(
              controller: commentsController,
              decoration: InputDecoration(
                labelText: 'Write a comment',
              ),
            ),
          )
        ],
      ),
    );
  }
}

class Comment extends StatelessWidget {
  final String userName;
  final String userId;
  final String avatarUrl;
  final String comment;
  final Timestamp timestamp;

  Comment(
      {this.userName,
      this.userId,
      this.avatarUrl,
      this.comment,
      this.timestamp});

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      userName: doc['username'],
      userId: doc['userId'],
      comment: doc['comment'],
      avatarUrl: doc['avatarUrl'],
      timestamp: doc['timestamp'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(
            comment,
            style: TextStyle(color: Colors.white),
          ),
          trailing: Text(
            userName,
            style: TextStyle(color: Colors.white),
          ),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(avatarUrl),
          ),
          subtitle: Text(timeAgo.format(timestamp.toDate()),
              style: TextStyle(color: Colors.white)),
        )
      ],
    );
  }
}
