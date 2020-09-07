import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photogram/models/user.dart';
import 'package:photogram/pages/home.dart';
import 'package:photogram/utils/dbUtil.dart';
import 'package:photogram/widgets/header.dart';
import 'package:photogram/widgets/post.dart';
import 'package:photogram/widgets/post_tile.dart';
import 'package:photogram/widgets/progress.dart';

import 'edit_profile.dart';

class Profile extends StatefulWidget {
  final userId;

  Profile({this.userId});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool isFollowing = false;
  String currentUserId = currentUser?.id;
  bool isLoading = false;
  String postOrientation = '';
  int postCount = 0;
  int followerCount = 0;
  int followingCount = 0;
  List<Post> posts = [];

  @override
  void initState() {
    super.initState();
    getProfilePosts();
    getFollowers();
    getFollowing();
    checkIfFollowing();
  }
  checkIfFollowing()async{
    DocumentSnapshot snapshot = await followersRef.document(widget.userId)
        .collection('userFollowers')
        .document(currentUserId)
        .get();
    setState(() {
      isFollowing = snapshot.exists;
    });
  }

  getFollowers()async{
    QuerySnapshot snapshot = await followersRef.document(widget.userId)
        .collection('userFollowers')
        .getDocuments();
    setState(() {
      followerCount = snapshot.documents.length;
    });
  }

  getFollowing()async{
   QuerySnapshot snapshot=  await followingsRef.document(currentUserId)
        .collection('userFollowing')
        .getDocuments();

   setState(() {
     followingCount = snapshot.documents.length;
   });
  }

  getProfilePosts() async {
    setState(() {
      isLoading = true;

    });
    QuerySnapshot snapshot = await postRef
        .document(widget.userId)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .getDocuments();

    setState(() {
      isLoading = false;
      postCount = snapshot.documents.length;
      posts = snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
    });
  }

  buildProfilePosts() {
    if (isLoading) {
      return circularProgress();
    }
    if (postOrientation == 'List') {
      return Column(
        children: posts,
      );
    }
    List<GridTile> gridTiles = [];
    posts.forEach((post) {
      gridTiles.add(GridTile(child: PostTile(post)));
    });
    return GridView.count(
      crossAxisCount: 3,
      childAspectRatio: 1.0,
      mainAxisSpacing: 1.5,
      crossAxisSpacing: 1.5,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: gridTiles,
    );
  }

  buildProfileHeader() {
    return FutureBuilder(
      future: usersRef.document(widget.userId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        User user = User.fromDocument(snapshot.data);
        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 40.0,
                    backgroundColor: Colors.grey,
                    backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            connectionBuilder('Posts', postCount),
                            connectionBuilder('Followers', followerCount),
                            connectionBuilder('Following', 0),
                          ],
                        ),
                        buildProfileButton(),
                      ],
                    ),
                  )
                ],
              ),
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: 150,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            user.displayName,
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            user.bio,
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Divider(
                height: 1.0,
                color: Colors.white,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: FlatButton(
                      onPressed: () {
                        setState(() {
                          postOrientation = 'Grid';
                        });
                      },
                      child: Icon(Icons.grid_on, color: Colors.white),
                    ),
                  ),
                  Expanded(
                    child: FlatButton(
                      onPressed: () {
                        setState(() {
                          postOrientation = 'List';
                        });
                      },
                      child: Icon(Icons.list, color: Colors.white),
                    ),
                  )
                ],
              ),
              Divider(height: 0.5, color: Colors.white)
            ],
          ),
        );
      },
    );
  }

  editProfile() async {
    final userId = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditProfile(
            user: currentUser,
          ),
        ));
    setState(() {
      Profile(userId: userId);
    });
  }

  buildButton(String text, Function function) {
    return ButtonTheme(
      minWidth: 200,
      height: 25.0,
      child: OutlineButton(
        onPressed: () => editProfile(),
        child: Text(
          text,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        borderSide: BorderSide(color: Colors.white, width: 1.8),
        padding: EdgeInsets.symmetric(horizontal: 80.0),
        highlightedBorderColor: Colors.white,
      ),
    );
  }

  handleUnFollow() {
    setState(() {
      isFollowing = false;
    });
//remove follower
    followersRef
        .document(widget.userId)
        .collection('userFollowers')
        .document(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    //remove following

    followingsRef
        .document(currentUserId)
        .collection('userFollowing')
        .document(widget.userId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    //delete activityFeed item to the other user

    feedRef
        .document(widget.userId)
        .collection('feedItems')
        .document(currentUserId)
        .get().then((doc) {
      if(doc.exists){
        doc.reference.delete();
      }

    });
  }

  handleFollow() {
    setState(() {
      isFollowing = true;
    });
//Make auth user follower of another user and update their followers collection
    followersRef
        .document(widget.userId)
        .collection('userFollowers')
        .document(currentUserId)
        .setData({});
    //put the other user in our collection

    followingsRef
        .document(currentUserId)
        .collection('userFollowing')
        .document(widget.userId)
        .setData({});

    //add activityFeed item to the other user

    feedRef
        .document(widget.userId)
        .collection('feedItems')
        .document(currentUserId)
        .setData({
      'type': 'follow',
      'username': currentUser.username,
      'userId': widget.userId,
      'userProfileImg': currentUser.photoUrl,
      'timeStamp': timestamp,
    });
  }

  buildProfileButton() {
    bool isProfileOwner = currentUserId == widget.userId;
    if (isProfileOwner) {
      return buildButton('Edit Profile', editProfile);
    } else if (isFollowing) {
      return buildButton('Unfollow', handleUnFollow);
    } else if (!isFollowing) {
      return buildButton('Follow', handleFollow);
    }
  }

  Column connectionBuilder(String label, int count) {
    return Column(
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(
              fontWeight: FontWeight.w900, fontSize: 25.0, color: Colors.white),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: header(false, false, title: 'Profile'),
      body: ListView(
        children: <Widget>[
          buildProfileHeader(),
          buildProfilePosts(),
        ],
      ),
    );
  }
}
