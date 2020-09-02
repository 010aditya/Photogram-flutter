import 'package:flutter/material.dart';
import 'package:photogram/widgets/custom_image.dart';
import 'package:photogram/widgets/post.dart';

class PostTile extends StatelessWidget {
  final Post post;
  PostTile(this.post);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=> print('showPost'),
      child: cachedNetworkImage(post.mediaUrl),
    );
  }
}
