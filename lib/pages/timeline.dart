import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:photogram/models/user.dart';
import 'package:photogram/utils/dbUtil.dart';
import 'package:photogram/widgets/header.dart';
import 'package:photogram/widgets/post.dart';
import 'package:photogram/widgets/progress.dart';


class Timeline extends StatefulWidget {
  final User user;

  Timeline({this.user});

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  List<Post> post ;

  @override
  void initState() {
    super.initState();
    getUserTimeline();
  }

  getUserTimeline()async{
  QuerySnapshot snapshot =   await timelineRef
        .document(widget.user.id)
        .collection('timelinePosts')
        .orderBy('timestamp',descending: true)
        .getDocuments();
  
 List<Post> post =  snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();

 setState(() {
   this.post = post;
 });
  }

  buildTimeline() {
    if (post == null) {
      return circularProgress();
    }
    else if (post.isEmpty) {
      return Text(' No posts to show');
    }
    else {
      return ListView(children: post);
    }
  }

  @override
  Widget build(context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: header(true,false),
      body: RefreshIndicator(
        onRefresh: () => getUserTimeline(),
        child: buildTimeline(),
      ),
    );
  }
}
