import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:photogram/models/user.dart';
import 'package:photogram/pages/profile.dart';
import 'package:photogram/utils/dbUtil.dart';
import 'package:photogram/widgets/progress.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  Future<QuerySnapshot> _searchedResultFuture;
  TextEditingController searchController = TextEditingController();
  List<UserResult> searchedList = [];

  handleSearch(String query) {
    Future<QuerySnapshot> searchedDoc = usersRef
        .where("displayName", isGreaterThanOrEqualTo: query)
        .getDocuments();
    setState(() {
      _searchedResultFuture = searchedDoc;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,//Theme.of(context).primaryColor.withOpacity(0.8),
      appBar: searchField(),
      body: _searchedResultFuture == null
          ? buildNoContent(context)
          : buildSearchResults(context),
    );
  }

  clearSearch() {
    searchController.clear();
    searchedList.clear();
  }

  buildSearchResults(context) {
    return FutureBuilder(
        future: _searchedResultFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          snapshot.data.documents.forEach((doc) {
            User user = User.fromDocument(doc);
            UserResult searchResult = UserResult(user: user);
            searchedList.add(searchResult);
          });
          return ListView(
            children: searchedList,
          );
        });
  }

  AppBar searchField() {
    return AppBar(
      backgroundColor: Colors.grey,
      title: (TextFormField(
        controller: searchController,
        decoration: InputDecoration(
            hintText: " Search For user",
            filled: true,
            prefix: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(
                Icons.account_box,
                color: Colors.black,
              ),
            ),
            suffix: IconButton(
              icon: Icon(
                Icons.clear,
                color: Colors.black,
              ),
              onPressed: () => clearSearch(),
            )),
        onFieldSubmitted: handleSearch,
      )),
    );
  }

  Container buildNoContent(context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            SvgPicture.asset(
              'assets/images/search.svg',
              height: orientation == Orientation.portrait ? 300.0 : 200.0,
            ),
            Text(
              'Find Users',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
                fontSize: 60.0,
              ),
            )
          ],
        ),
      ),
    );
  }
}
showProfile(context,{String profileId}){
  Navigator.push(context, MaterialPageRoute(builder: (context) => Profile(userId: profileId,)));
}

class UserResult extends StatelessWidget {
  final User user;

  UserResult({this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black26,
      // Theme.of(context).primaryColor.withOpacity(0.7),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => showProfile(context,profileId: user.id),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              ),
              title: Text(
                user.username,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(user.username,style: TextStyle(color: Colors.white),),
            ),
          ),
          Divider(
            height: 2.0,
            color: Colors.white54,
          )
        ],
      ),
    );
  }
}
