import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photogram/pages/home.dart';
import 'package:photogram/utils/dbUtil.dart';
import 'package:photogram/widgets/header.dart';
import 'package:photogram/widgets/progress.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class ActivityFeed extends StatefulWidget {
  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  getActivityFeed() async {
    QuerySnapshot snapshot = await feedRef
        .document(currentUser.id)
        .collection('feedItems')
        .orderBy('timeStamp', descending: true)
        .limit(50)
        .getDocuments();
    List<ActivityFeedItem> feedItems = [];
    snapshot.documents.forEach((doc) {
      print(doc.data);
      feedItems.add(ActivityFeedItem.fromDocument(doc));
    });

    return feedItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: header(false, true, title: 'Activity Feed'),
      body: Container(
        child: FutureBuilder(
          future: getActivityFeed(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return circularProgress();
            }
            return ListView(
              children: snapshot.data,
            );
          },
        ),
      ),
    );
  }
}

Widget mediaPreview;
String activityItemText;

class ActivityFeedItem extends StatelessWidget {
  final String commentData;

  final String userName;

  final String userId;

  final String type;

  final String mediaUrl;

  final String postId;

  final String userProfileImage;

  final Timestamp timeStamp;

  ActivityFeedItem({
    this.commentData,
    this.userName,
    this.userId,
    this.type,
    this.mediaUrl,
    this.postId,
    this.userProfileImage,
    this.timeStamp,
  });

  factory ActivityFeedItem.fromDocument(DocumentSnapshot doc) {
    print(doc.data);
    print(doc['username']);
    print(doc['userId']);
    print(doc['commentData']);
    print(doc['mediaUrl']);
    print(doc['postId']);
    print(doc['timeStamp']);
    print(doc['userProfileImg']);
    print(doc['type']);
    return ActivityFeedItem(
        userName: doc['username'],
        userId: doc['userId'],
        commentData: doc['commentData'],
        mediaUrl: doc['mediaUrl'],
        postId: doc['postId'],
        timeStamp: doc['timeStamp'],
        userProfileImage: doc['userProfileImg'],
        type: doc['type']);
  }

  configureMediaPreview() {
    if (type == 'like' || type == 'comment') {
      mediaPreview = GestureDetector(
        onTap: () => print('showing post of $type'),
        child: Container(
          height: 50,
          width: 50,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                fit: BoxFit.cover,
                image: CachedNetworkImageProvider(mediaUrl),
              )),
            ),
          ),
        ),
      );
    } else {
      mediaPreview = Text('');
    }
    if (type == 'like') {
      activityItemText = 'Liked your post';
    } else if (type == 'follow') {
      activityItemText = 'Followed you ';
    } else if (type == 'comment') {
      activityItemText = 'replied: $commentData';
      print('hi');
    } else {
      activityItemText = 'unknown activity type $type';
    }
  }

  @override
  Widget build(BuildContext context) {
    configureMediaPreview();
    return Padding(
      padding: EdgeInsets.only(bottom: 2.0),
      child: Container(
        color: Colors.white10,
        child: ListTile(
          title: GestureDetector(
            onTap: () => print('show profile'),
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.white,
                  ),
                  children: [
                    TextSpan(
                      text: userName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: ' $activityItemText ',
                    )
                  ]),
            ),
          ),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(userProfileImage),
          ),
          subtitle: Text(
            timeAgo.format(timeStamp.toDate()),
            style: TextStyle(color: Colors.white54),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: mediaPreview,
        ),
      ),
    );
  }
}
