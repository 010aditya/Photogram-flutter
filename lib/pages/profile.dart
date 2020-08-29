import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photogram/models/user.dart';
import 'package:photogram/utils/dbUtil.dart';
import 'package:photogram/widgets/header.dart';
import 'package:photogram/widgets/progress.dart';

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
                            Column(
                              children: <Widget>[
                                Text(
                                  '1',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 25.0),
                                ),
                                Text(
                                  'posts',
                                  textAlign: TextAlign.center,
                                )
                              ],
                            ),
                            Column(
                              children: <Widget>[
                                Text('1',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 25.0)),
                                Text('Followers', textAlign: TextAlign.center),
                              ],
                            ),
                            Column(
                              children: <Widget>[
                                Text('1',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 25.0)),
                                Text('Following', textAlign: TextAlign.center),
                              ],
                            ),
                          ],
                        ),
                        ButtonTheme(
                          minWidth: 200,
                          height: 25.0,
                          child: OutlineButton(
                            child: Text(
                              'Edit Profile',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            borderSide:
                                BorderSide(color: Colors.black, width: 1.8),
                            padding: EdgeInsets.symmetric(horizontal: 80.0),
                            highlightedBorderColor: Colors.black,
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
              Row(
                children: <Widget>[
                  Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Aditya'),
                      Text('Reading,Wiritng,\nCoffee is favorite'),
                      Text('Hellow world!!'),
                    ],
                  ),
                ],
              ),
              Divider(
                height: 1.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  FlatButton(
                    child: Icon(Icons.grid_on),
                  ),
                  FlatButton(
                    child: Icon(Icons.list),
                  )
                ],
              ),
              Divider(
                height: 1.0,
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(false, false, title: "Profile"),
      body: ListView(
        children: <Widget>[
          buildProfileHeader(),
        ],
      ),
    );
  }
}
