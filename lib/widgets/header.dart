import 'package:flutter/material.dart';

header(bool isTimeline, bool removeBackButton, {String title}) {
  return AppBar(
    automaticallyImplyLeading:false,
    title: Text(
      isTimeline ? 'PostGram' : title,
      style: TextStyle(
        fontSize: isTimeline ? 35.0 : 25.0,
        fontFamily: isTimeline ? "Signatra" : null,
        color: Colors.white,
      ),
    ),
    centerTitle: isTimeline ? true : false,
    backgroundColor: Colors.black,
  );
}