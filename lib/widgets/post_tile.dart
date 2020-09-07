import 'package:flutter/material.dart';
import 'package:photogram/pages/post_screen.dart';
import 'package:photogram/widgets/custom_image.dart';
import 'package:photogram/widgets/post.dart';

class PostTile extends StatelessWidget {
  final Post post;
  PostTile(this.post);


  navigateToPost(context){
    Navigator.push(context, MaterialPageRoute(builder:(context) => PostScreen(
      userId: post.ownerId,postId: post.postId,)));
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=> navigateToPost(context),
      child: cachedNetworkImage(post.mediaUrl),
    );
  }
}
