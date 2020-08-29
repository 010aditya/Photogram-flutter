import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:photogram/models/user.dart';

class EditProfile extends StatefulWidget {
  final User user;

  EditProfile({this.user});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  bool isAuth = false;
  TextEditingController inputController = TextEditingController();

  AppBar appBar() {
    return AppBar(
      backgroundColor: Colors.black,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text('Edit Profile'),
          Icon(
            Icons.check,
            color: Colors.green,
          )
        ],
      ),
    );
  }

  Container inputEditField(TextEditingController input, String label,
      String defaultValue) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              label,
              style: TextStyle(
                color: Colors.white60,
              ),
            ),
            SizedBox(
              height: 1.0,
            ),
            TextField(
              controller: input,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                  hintText: defaultValue,
                  hintStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0),
                  border: InputBorder.none),
            ),
            Divider(
              height: 2.0,
              color: Colors.white,
            )
          ],
        ),
      ),
    );
  }

  buildEditProfile() {
    return Container(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: CircleAvatar(
                radius: 50.0,
                backgroundColor: Colors.grey,
                backgroundImage:
                CachedNetworkImageProvider(widget.user.photoUrl),
              ),
            ),
          ),
          inputEditField(
              inputController, 'Display Name', widget.user.displayName),
          inputEditField(inputController, 'Bio', widget.user.bio),
          Expanded(
            child: RaisedButton(
              child: Container(
                decoration: const BoxDecoration(color: Colors.grey),
                padding: const EdgeInsets.all(8.0),
                child: const Text('Update Profile',
                    style: TextStyle(fontSize: 20)),
              ),
            ),
          ),
          Expanded(
            child: FlatButton.icon(
                icon:Icon(Icons.cancel,color: Colors.red,),
                label: Text(
                  'Logout',
                  style: TextStyle(color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0),
                ),
            ),
          )
        ],
      ),
    );
  }

//          );
  //}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: appBar(),
      body: buildEditProfile(),
    );
  }
}
