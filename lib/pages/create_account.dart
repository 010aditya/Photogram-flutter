import 'dart:async';

import 'package:flutter/material.dart';
import 'package:photogram/widgets/header.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String username = '';
  bool error = false;

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(false, true, title: "Set up your profile"),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Column(
            children: <Widget>[
              Center(
                child: Text(
                  'Create a Username',
                  style: TextStyle(
                    fontSize: 25.0,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 30.0),
                child: TextField(
                  onChanged: (value) {
                    if (value.trim().length < 3 ||
                        value.isEmpty ||
                        value.trim().length > 12) {
                      setState(() {
                        error = true;
                      });
                    } else {
                      setState(() {
                        error = false;
                      });
                    }
                    username = value;
                  },
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelStyle: TextStyle(fontSize: 15.0),
                      fillColor: Colors.black,
                      labelText: 'Username',
                      hintText: "Enter username",
                      errorText: error
                          ? 'Username is not between 3 to 12 characters'
                          : null),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (username.trim().length > 3 &&
                      username.trim().length < 12) {
                    SnackBar snackBar = SnackBar(
                      content: Text('Welcome $username'),
                    );
                    _scaffoldKey.currentState.showSnackBar(snackBar);
                    Timer(Duration(seconds: 2), () {
                      Navigator.pop(context);
                      Navigator.pop(context, username);
                    });
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 50.0),
                    child: Text(
                      'Submit',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 25.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
