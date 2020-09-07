import 'package:flutter/material.dart';

header(bool isTimeline, bool removeBackButton, {String title}) {
  return AppBar(
    automaticallyImplyLeading:false,
    title: Text(
      isTimeline ? 'PostGram' : title,
      style: TextStyle(
        fontSize: isTimeline ? 30.0 : 20.0,
        fontFamily: isTimeline ? "Signatra" : null,
        color: Colors.white,
      ),
      overflow: TextOverflow.ellipsis,
    ),
    centerTitle: isTimeline ? true : false,
    backgroundColor: Colors.black,
  );
}
