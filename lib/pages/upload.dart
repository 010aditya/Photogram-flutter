import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photogram/models/user.dart';
import 'package:photogram/pages/home.dart';
import 'package:photogram/utils/dbUtil.dart';
import 'package:photogram/widgets/progress.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';
import 'package:geolocator/geolocator.dart';

class Upload extends StatefulWidget {
  final User currentUser;

  Upload({this.currentUser});

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  PickedFile pickedFile;
  File image;
  var uuid = Uuid();
  bool isUploading = false;
  String randomId;

  String address = '';
  TextEditingController locationController = TextEditingController();
  TextEditingController captionController = TextEditingController();

  handleTakePhoto() async {
    Navigator.pop(context);
    final pickedFile = await ImagePicker()
        .getImage(source: ImageSource.camera, maxHeight: 675, maxWidth: 960);
    setState(() {
      this.image = File(pickedFile.path);
    });
  }

  handlePhotoFromGallery() async {
    Navigator.pop(context);
    PickedFile pickedFile = await ImagePicker()
        .getImage(source: ImageSource.gallery, maxWidth: 960, maxHeight: 675);
    setState(() {
      this.image = File(pickedFile.path);
    });
  }

  selectImage(parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: Text("Create Post"),
            children: <Widget>[
              SimpleDialogOption(
                child: Text("Photo with Camera"),
                onPressed: handleTakePhoto,
              ),
              SimpleDialogOption(
                child: Text("Image from Gallery"),
                onPressed: handlePhotoFromGallery,
              ),
              SimpleDialogOption(
                child: Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        });
  }

  buildSplashScreen() {
    return Container(
      color: Theme.of(context).accentColor.withOpacity(0.6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset(
            'assets/images/upload.svg',
            height: 260.0,
          ),
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                "Upload Image",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                ),
              ),
              color: Colors.black26,
              onPressed: () => selectImage(context),
            ),
          )
        ],
      ),
    );
  }

  compressImage() async {
    randomId = uuid.v4();
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(image.readAsBytesSync());
    final compressedImageFile = File('$path/img_$randomId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
    setState(() {
      image = compressedImageFile;
    });
  }

  clearImage() {
    setState(() {
      image = null;
    });
  }

  Future<String> uploadFile(imageFile) async {
    StorageUploadTask uploadTask =
        storageRef.child('post_$randomId.jpg').putFile(imageFile);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  createPostInFireStore(
      {String mediaUrl, String location, String description}) {
    postRef
        .document(widget.currentUser.id)
        .collection('userPosts')
        .document(randomId)
        .setData({
      'postId': randomId,
      'ownerId': widget.currentUser.id,
      'userName': widget.currentUser.username,
      'mediaUrl': mediaUrl,
      'description': description,
      'location': location,
      'timestamp': timestamp,
      'likes': {}
    });
  }

  uploading() async {
    setState(() {
      isUploading = true;
    });
    await compressImage();
    String downloadedImage = await uploadFile(image);
    createPostInFireStore(
        mediaUrl: downloadedImage,
        location: locationController.text,
        description: captionController.text);
    captionController.clear();
    locationController.clear();
    setState(() {
      image = null;
      isUploading = false;
    });
  }

  getLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemark = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placemark[0];
    address = '${place.name}, ${place.subLocality} ${place.locality}, ${place.country}';
    locationController.text = address;
  }

  buildUploadForm() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: clearImage,
        ),
        title: Text(
          'Caption Post',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          FlatButton(
            onPressed: isUploading ? null : () => uploading(),
            child: Text(
              'Post',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                  fontSize: 20.0),
            ),
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          isUploading == true ? linearProgress() : Text(''),
          Container(
            height: 220,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    fit: BoxFit.cover,
                    image: FileImage(image),
                  )),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  CachedNetworkImageProvider(widget.currentUser.photoUrl),
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: captionController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    hintText: 'Write a caption..',
                    hintStyle: TextStyle(color: Colors.white),
                    border: InputBorder.none),
              ),
            ),
          ),
          Divider(color: Colors.white24),
          ListTile(
            leading: Icon(Icons.pin_drop, color: Colors.red, size: 35),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: locationController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    hintText: 'Where was this photo taken?',
                    hintStyle: TextStyle(color: Colors.white),
                    border: InputBorder.none),
              ),
            ),
          ),
          Container(
            width: 200,
            height: 100,
            alignment: Alignment.center,
            child: RaisedButton.icon(
              onPressed: () => getLocation(),
              icon: Icon(
                Icons.my_location,
                color: Colors.white,
              ),
              label: Text(
                'Use Current Location',
                style: TextStyle(color: Colors.white),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              color: Colors.blueAccent,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return image == null ? buildSplashScreen() : buildUploadForm();
  }
}
