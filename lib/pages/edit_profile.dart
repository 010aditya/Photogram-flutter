import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:photogram/models/user.dart';
import 'package:photogram/utils/dbUtil.dart';

import 'home.dart';

class EditProfile extends StatefulWidget {
  final User user;

  EditProfile({this.user});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  bool isAuth = false;
  TextEditingController inputDisplayController = TextEditingController();
  TextEditingController inputBioController = TextEditingController();
  bool _isDisplayNameValid = false;
  bool _isBioValid = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  AppBar appBar() {
    return AppBar(
      backgroundColor: Colors.black,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text('Edit Profile'),
          IconButton(
            icon: Icon(CupertinoIcons.clear),
           color: Colors.red,
           iconSize: 40,
           onPressed: (){
             Navigator.pop(context, widget.user.id);
           },
          )
        ],
      ),
    );
  }

  displayNameValidation(bool validDisplayName) {
    String displayNameError =
        validDisplayName ? null : " Display Name too Short";
    return displayNameError;
  }

  bioValidation(bool validBio) {
    String bioErrorMessage = validBio ? null : " Bio  should be less than 100";
    return bioErrorMessage;
  }

  Container inputEditField(TextEditingController input, String label,
      String defaultValue, String hintText) {
    input.text = defaultValue;
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
                  hintText: hintText,
                  hintStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0),
                  /*     errorText: label == 'Display Name'
                      ? displayNameValidation(_isDisplayNameValid)
                      : label == 'Bio' ? bioValidation(_isBioValid) : null,*/
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

  logout() {
    googleSignIn.signOut();
  }

  updateProfileInDb(String displayName, String bio) async {
    setState(() {
      displayName.trim().length < 3 || displayName.trim().isEmpty
          ? _isDisplayNameValid = false
          : _isDisplayNameValid = true;
      bio.trim().length > 100 ? _isBioValid = false : _isBioValid = true;
    });
    if (_isDisplayNameValid && _isBioValid) {
      usersRef.document(widget.user.id).updateData({
        "bio": bio,
        "displayName": displayName,
      });

      SnackBar snackBar = SnackBar(content: Text('Your Profile is Updated'));
      _scaffoldKey.currentState.showSnackBar(snackBar);
      await Future.delayed(const Duration(seconds: 2), (){});
      Navigator.pop(context, widget.user.id);
    }

  }

  buildEditProfile() {
    return Container(
      child: ListView(
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
          inputEditField(inputDisplayController, 'Display Name',
              widget.user.displayName, "Enter your Display Name"),
          inputEditField(
              inputBioController, 'Bio', widget.user.bio, "Enter your bio"),
          FlatButton(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.all(8.0),
              child: const Text(
                'Update Profile',
                style: TextStyle(fontSize: 20, color: Colors.white60),
              ),
            ),
            onPressed: () => updateProfileInDb(
                inputDisplayController.text, inputBioController.text),
          ),
          FlatButton.icon(
            onPressed: () {
              logout();
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Home()));
            },
            icon: Icon(
              Icons.cancel,
              color: Colors.red,
            ),
            label: Text(
              'Logout',
              style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0),
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
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      appBar: appBar(),
      body: buildEditProfile(),
    );
  }
}
