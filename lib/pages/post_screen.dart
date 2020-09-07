import 'package:flutter/material.dart';
import 'package:photogram/utils/dbUtil.dart';
import 'package:photogram/widgets/header.dart';
import 'package:photogram/widgets/post.dart';
import 'package:photogram/widgets/progress.dart';

class PostScreen extends StatelessWidget {

  final String postId ;
  final String userId;

  PostScreen({this.postId,this.userId});



  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: postRef.document(userId)
          .collection('userPosts')
          .document(postId).get(),
      builder: (context,snapshot){
        if(!snapshot.hasData) {
          return circularProgress();
        }
      Post post = Post.fromDocument(snapshot.data);
        return Center(
          child: Scaffold(
            backgroundColor: Colors.black,
            appBar: header(false, true,title: post.description),
            body: ListView(
              children: <Widget>[
                Container(
                  child: post ,
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
