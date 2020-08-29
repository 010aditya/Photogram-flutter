import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photogram/models/user.dart';
import 'package:photogram/utils/dbUtil.dart';
import 'package:photogram/widgets/header.dart';
import 'package:photogram/widgets/progress.dart';

import 'edit_profile.dart';

class Profile extends StatefulWidget {
  final userId;

  Profile({this.userId});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
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
                            connectionBuilder('Posts', 0),
                            connectionBuilder('Followers', 0),
                            connectionBuilder('Following', 0),
                          ],
                        ),
                        ButtonTheme(
                          minWidth: 200,
                          height: 25.0,
                          child: OutlineButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditProfile(
                                      user: user,
                                    ),
                                  ));
                            },
                            child: Text(
                              'Edit Profile',
                              style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
                            ),
                            borderSide:
                                BorderSide(color: Colors.white, width: 1.8),
                            padding: EdgeInsets.symmetric(horizontal: 80.0),
                            highlightedBorderColor: Colors.white,
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(user.displayName,style: TextStyle(color: Colors.white),),
                        Text('Reading,Wiritng,\nCoffee is favorite',style: TextStyle(color: Colors.white),),
                        Text('Hellow world!!',style: TextStyle(color: Colors.white),),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(
                height: 2.0,
                color: Colors.white,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: FlatButton(
                      child: Icon(Icons.grid_on,color: Colors.white),
                    ),
                  ),
                  Expanded(
                    child: FlatButton(
                      child: Icon(Icons.list,color: Colors.white),
                    ),
                  )
                ],
              ),
              Divider(
                height: 1.0,
                  color: Colors.white
              )
            ],
          ),
        );
      },
    );
  }

  Column connectionBuilder(String label, int count) {
    return Column(
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 25.0,color: Colors.white),
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
        ],
      ),
    );
  }
}
