import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'package:pet_lover/custom_classes/TextFieldValidation.dart';

import 'package:pet_lover/custom_classes/progress_dialog.dart';
import 'package:pet_lover/fade_animation.dart';

import 'package:pet_lover/home.dart';
import 'package:pet_lover/provider/animalProvider.dart';
import 'package:pet_lover/provider/postProvider.dart';
import 'package:pet_lover/provider/userProvider.dart';
import 'package:pet_lover/video_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class AddAnimal extends StatefulWidget {
  String petId;
  AddAnimal({Key? key, required this.petId}) : super(key: key);
  @override
  _AddAnimalState createState() => _AddAnimalState();
}

class _AddAnimalState extends State<AddAnimal> {
  String animalToken = '';
  String postId = '';
  TextEditingController _petNameController = TextEditingController();
  TextEditingController _colorController = TextEditingController();
  TextEditingController _genusController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  Widget? videoStatusAnimation;
  File? fileMedia;
  File? _image;

  String? postImageLink;
  String? postVideoLink;
  String? imageLink;
  String? _currentMobileNo;
  String? _username;
  String? _userProfileImage;
  String dateData = '';
  String? petNameErrorText;
  String? colorErrorText;
  String? genusErrorText;
  String? genderErrorText;
  String? ageErrorText;
  bool profileImageUploadVisibility = false;
  VideoPlayerController? controller;
  String _choosenValue = 'Male';
  List<String> _groupGender = ['Male', 'Female'];
  int _count = 0;
  String _animalName = '';
  String _animalAge = '';
  String _animalColor = '';
  String _animalGender = '';
  String _animalGenus = '';
  String _photo = '';
  String _video = '';
  String _totalComments = '';
  String _totalFollowers = '';
  String _totalShares = '';
  int? videoSize;
  bool isVisible = true;
  MediaInfo? compressedVideoInfo;

  VideoPlayerController? _controller;

  Future<String?> getCurrentMobileNo() async {
    final prefs = await SharedPreferences.getInstance();
    _currentMobileNo = prefs.getString('mobileNo');
    print('Current Mobile no is $_currentMobileNo');
    return _currentMobileNo;
  }

  Future _customInit(
      AnimalProvider animalProvider, UserProvider userProvider) async {
    if (this.mounted) {
      setState(() {
        _count++;
      });
      userProvider.getCurrentUserInfo();
      if (widget.petId != '') {
        _getPostInfo(widget.petId);
      }
    }
  }

  _getPostInfo(String postId) async {
    await FirebaseFirestore.instance
        .collection('allPosts')
        .doc(postId)
        .get()
        .then((snapshot) {
      setState(() {
        _animalName = snapshot['animalName'];
        _animalAge = snapshot['animalAge'];
        _animalColor = snapshot['animalColor'];
        _animalGenus = snapshot['animalGenus'];
        _animalGender = snapshot['animalGender'];
        _photo = snapshot['photo'];
        _video = snapshot['video'];
        animalToken = snapshot['animalToken'];
        _petNameController.text = _animalName;
        _colorController.text = _animalColor;
        _ageController.text = _animalAge;
        _genusController.text = _animalGenus;
        _choosenValue = _animalGender;
        _totalComments = snapshot['totalComments'];
        _totalFollowers = snapshot['totalFollowers'];
        _totalShares = snapshot['totalShares'];
      });

      if (widget.petId != '' && _video != '') {
        _controller = VideoPlayerController.network(_video)
          ..addListener(() => mounted ? setState(() {}) : true)
          ..setLooping(true)
          ..initialize().then((_) {
            _controller!.pause();
            _controller!.setVolume(1);
          });
      }
    });
  }

  Widget buildIndicator() => VideoProgressIndicator(
        _controller!,
        allowScrubbing: true,
      );

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Add Animal",
            style: TextStyle(
              color: Colors.black,
              fontSize: size.width * .05,
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: bodyUI(context),
    );
  }

  //body demo design
  Widget bodyUI(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final AnimalProvider animalProvider = Provider.of<AnimalProvider>(context);
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final PostProvider postProvider = Provider.of<PostProvider>(context);
    if (_count == 0) _customInit(animalProvider, userProvider);
    return Container(
      width: size.width,
      height: size.height,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              //container for image or video loading
              width: size.width,
              height: size.width * .7,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300)),
              child: Center(
                child: _photo == '' && _video == ''
                    ? _image != null || fileMedia != null
                        ? Container(
                            width: size.width,
                            height: size.width * .7,
                            color: Colors.grey.shade300,
                            alignment: Alignment.topCenter,
                            child: _image != null
                                ? Image.file(_image!, fit: BoxFit.fill)
                                : VideoWidget(fileMedia!))
                        : Text(
                            'No image or video selected!',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: size.width * .05,
                            ),
                          )
                    : _video == ''
                        ? Image.network(_photo)
                        : Center(
                            child: _controller!.value.isInitialized
                                ? Stack(
                                    children: [
                                      AspectRatio(
                                        aspectRatio:
                                            _controller!.value.aspectRatio,
                                        child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                isVisible = !isVisible;
                                              });

                                              if (!_controller!
                                                  .value.isInitialized) {
                                                return;
                                              }
                                              if (_controller!
                                                  .value.isPlaying) {
                                                videoStatusAnimation =
                                                    FadeAnimation(
                                                        child: Container(
                                                  width: size.width * .2,
                                                  height: size.width * .2,
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color:
                                                          Colors.grey.shade800),
                                                  child: Icon(
                                                    Icons.play_arrow,
                                                    color: Colors.white,
                                                    size: size.width * .2,
                                                  ),
                                                ));
                                                _controller!.pause();
                                              } else {
                                                videoStatusAnimation =
                                                    FadeAnimation(
                                                        child: Container(
                                                            width:
                                                                size.width * .2,
                                                            height:
                                                                size.width * .2,
                                                            decoration: BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color: Colors
                                                                    .grey
                                                                    .shade800),
                                                            child: Icon(
                                                              Icons.pause,
                                                              color:
                                                                  Colors.white,
                                                              size: size.width *
                                                                  .2,
                                                            )));
                                                _controller!.play();
                                              }
                                            },
                                            child: VideoPlayer(_controller!)),
                                      ),
                                      Positioned.fill(
                                          child: Stack(
                                        children: <Widget>[
                                          Center(child: videoStatusAnimation),
                                          Positioned(
                                            bottom: 0,
                                            left: 0,
                                            right: 0,
                                            child: buildIndicator(),
                                          ),
                                        ],
                                      ))
                                    ],
                                  )
                                : Padding(
                                    padding: EdgeInsets.all(size.width * .3),
                                    child: CircularProgressIndicator(),
                                  ),
                          ),
              ),
            ),
            SizedBox(
              height: size.width * .02,
            ),
            Padding(
              padding: EdgeInsets.only(left: size.width * .04),
              child: Row(
                children: [
                  ElevatedButton(
                      //video pick button
                      onPressed: () async {
                        setState(() {
                          String source = 'Video';

                          _cameraGalleryBottomSheet(context, source);
                        });
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.video_camera_front,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: size.width * .03,
                          ),
                          Text(
                            'Video',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: size.width * .038),
                          )
                        ],
                      )),
                  SizedBox(
                    width: size.width * .04,
                  ),
                  ElevatedButton(
                      //image pick button
                      onPressed: () async {
                        setState(() {
                          String source = 'Photo';
                          _cameraGalleryBottomSheet(context, source);
                        });

                        //   print(_file);
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.photo_camera,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: size.width * .03,
                          ),
                          Text(
                            'Photo',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: size.width * .038),
                          )
                        ],
                      ))
                ],
              ),
            ),
            Container(
              width: size.width,
              padding: EdgeInsets.fromLTRB(size.width * .04, size.width * .06,
                  size.width * .04, size.width * .04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Animal Details',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: size.width * .05,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: size.width * .05),
                  Text(
                    'Pet name',
                    style: TextStyle(fontSize: size.width * .042),
                  ),
                  SizedBox(
                    height: size.width * .02,
                  ),
                  Container(
                    //textformfield for pet name input
                    width: size.width,
                    padding: EdgeInsets.only(
                        left: size.width * .04,
                        right: size.width * .04,
                        top: size.width * .02,
                        bottom: size.width * .02),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(size.width * .02),
                    ),
                    child: textFormFieldBuilder(TextInputType.text, 1,
                        _petNameController, petNameErrorText),
                  ),
                  SizedBox(
                    height: size.width * .04,
                  ),
                  Text(
                    'Color',
                    style: TextStyle(fontSize: size.width * .042),
                  ),
                  SizedBox(
                    height: size.width * .02,
                  ),
                  Container(
                    //textformfield for pet color input
                    width: size.width,
                    padding: EdgeInsets.only(
                        left: size.width * .04,
                        right: size.width * .04,
                        top: size.width * .02,
                        bottom: size.width * .02),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(size.width * .02),
                    ),
                    child: textFormFieldBuilder(TextInputType.text, 1,
                        _colorController, colorErrorText),
                  ),
                  SizedBox(
                    height: size.width * .04,
                  ),
                  Text(
                    'Genus',
                    style: TextStyle(fontSize: size.width * .042),
                  ),
                  SizedBox(
                    height: size.width * .02,
                  ),
                  Container(
                    //textformfield for genus input
                    width: size.width,
                    padding: EdgeInsets.only(
                        left: size.width * .04,
                        right: size.width * .04,
                        top: size.width * .02,
                        bottom: size.width * .02),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(size.width * .02),
                    ),
                    child: textFormFieldBuilder(TextInputType.text, 1,
                        _genusController, genusErrorText),
                  ),
                  SizedBox(
                    height: size.width * .04,
                  ),
                  Text(
                    'Gender',
                    style: TextStyle(fontSize: size.width * .042),
                  ),
                  SizedBox(
                    height: size.width * .02,
                  ),
                  Container(
                      width: size.width,
                      height: size.width * .095,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius:
                              BorderRadius.circular(size.width * .02)),
                      padding: EdgeInsets.only(
                          left: size.width * .04, right: size.width * .04),
                      child: Container(
                        child: DropdownButton<String>(
                          value: _choosenValue,
                          isExpanded: true,
                          underline: SizedBox(),
                          onChanged: (value) {
                            setState(() {
                              _choosenValue = value.toString();
                            });
                          },
                          items: _groupGender
                              .map((item) => DropdownMenuItem<String>(
                                    child: Text(item),
                                    value: item,
                                  ))
                              .toList(),
                        ),
                      )),
                  SizedBox(
                    height: size.width * .04,
                  ),
                  Text(
                    'Age',
                    style: TextStyle(fontSize: size.width * .042),
                  ),
                  SizedBox(
                    height: size.width * .02,
                  ),
                  Container(
                    //textformfield for pet age input
                    width: size.width,
                    padding: EdgeInsets.only(
                        left: size.width * .04,
                        right: size.width * .04,
                        top: size.width * .02,
                        bottom: size.width * .02),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(size.width * .02),
                    ),
                    child: textFormFieldBuilder(
                        TextInputType.text, 1, _ageController, ageErrorText),
                  ),
                  SizedBox(
                    height: size.width * .04,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                          //Cancel button
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: size.width * .038),
                          )),
                      SizedBox(
                        width: size.width * .04,
                      ),
                      ElevatedButton(
                          //save button
                          onPressed: () {
                            setState(() {
                              if (widget.petId == '') {
                                postId = Uuid().v4();
                              } else {
                                postId = widget.petId;
                              }

                              if (!TextFieldValidation()
                                  .petNameValidation(_petNameController.text)) {
                                petNameErrorText = 'What is your pet name?';
                                return;
                              } else {
                                petNameErrorText = null;
                              }

                              uploadData(postId, userProvider, postProvider);
                            });
                          },
                          child: Text(
                            'Save',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: size.width * .038),
                          ))
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> uploadData(String postId, UserProvider userProvider,
      PostProvider postProvider) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return ProgressDialog(message: 'Please wait. Saving animal data');
        });

    if (_image != null || fileMedia != null) {
      print('1 running');
      firebase_storage.Reference storageReference = firebase_storage
          .FirebaseStorage.instance
          .ref()
          .child('posts')
          .child(postId);

      if (_image != null) {
        firebase_storage.UploadTask storageUploadTask =
            storageReference.putFile(_image!);

        firebase_storage.TaskSnapshot taskSnapshot;
        storageUploadTask.then((value) {
          taskSnapshot = value;
          taskSnapshot.ref.getDownloadURL().then((newImageDownloadUrl) {
            final downloadUrl = newImageDownloadUrl;
            setState(() {
              postImageLink = downloadUrl;
            });
            if (widget.petId == '') {
              _createPost(userProvider, postId, postProvider);
            } else {
              _UpdatePost(userProvider, widget.petId, postProvider);
            }
          });
        });
      } else {
        firebase_storage.UploadTask storageUploadTask =
            storageReference.putFile(fileMedia!);

        firebase_storage.TaskSnapshot taskSnapshot;
        storageUploadTask.then((value) {
          taskSnapshot = value;
          taskSnapshot.ref.getDownloadURL().then((newImageDownloadUrl) {
            final downloadUrl = newImageDownloadUrl;
            setState(() {
              postVideoLink = downloadUrl;
            });
            if (widget.petId == '') {
              _createPost(userProvider, postId, postProvider);
            } else {
              _UpdatePost(userProvider, widget.petId, postProvider);
            }
          });
        });
      }
    } else if ((_image == null && fileMedia == null) &&
        (_photo != '' || _video != '')) {
      print('2 running');
      setState(() {
        postImageLink = _photo;
        postVideoLink = _video;
        _UpdatePost(userProvider, postId, postProvider);
      });
    }
  }

  void _UpdatePost(UserProvider userProvider, String postId,
      PostProvider postProvider) async {
    String date = DateTime.now().millisecondsSinceEpoch.toString();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userProvider.currentUserMobile)
        .collection('myPosts')
        .doc(postId)
        .update({
      'date': date,
    });

    await FirebaseFirestore.instance.collection('allPosts').doc(postId).update({
      'postId': postId,
      'postOwnerId': userProvider.currentUserMap['mobileNo'],
      'postOwnerMobileNo': userProvider.currentUserMap['mobileNo'],
      'postOwnerName': userProvider.currentUserMap['username'],
      'postOwnerImage': userProvider.currentUserMap['profileImageLink'],
      'date': date,
      'status': '',
      'photo': _image != null ? postImageLink : _photo,
      'video': fileMedia != null ? postVideoLink : _video,
      'animalToken': animalToken,
      'animalName': _petNameController.text,
      'animalColor': _colorController.text,
      'animalAge': _ageController.text,
      'animalGender': _choosenValue,
      'animalGenus': _genusController.text,
    }).then((value) async {
      _emptyFieldCreator();
      await postProvider.getAllPosts();
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
    });
  }

  void _createPost(UserProvider userProvider, String postId,
      PostProvider postProvider) async {
    if (animalToken == '') {
      String newAnimalToken = Uuid().v4();
      animalToken = newAnimalToken.substring(30);
    }

    String date = DateTime.now().millisecondsSinceEpoch.toString();
    Map<String, String> postMap = {
      'postId': postId,
      'postOwnerId': userProvider.currentUserMap['mobileNo'],
      'postOwnerMobileNo': userProvider.currentUserMap['mobileNo'],
      'postOwnerName': userProvider.currentUserMap['username'],
      'postOwnerImage': userProvider.currentUserMap['profileImageLink'],
      'date': date,
      'status': '',
      'photo': _image != null ? postImageLink! : '',
      'video': fileMedia != null ? postVideoLink! : '',
      'animalToken': animalToken,
      'animalName': _petNameController.text,
      'animalColor': _colorController.text,
      'animalAge': _ageController.text,
      'animalGender': _choosenValue,
      'animalGenus': _genusController.text,
      'totalFollowers': '0',
      'totalComments': '0',
      'totalShares': '0',
      'groupId': '',
      'shareId': ''
    };

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userProvider.currentUserMap['mobileNo'])
        .collection('myPosts')
        .doc(postId)
        .set({'postId': postId, 'date': date});

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userProvider.currentUserMap['mobileNo'])
        .collection('myAnimals')
        .doc(animalToken)
        .set({'animalToken': animalToken});

    await FirebaseFirestore.instance
        .collection('Animals')
        .doc(animalToken)
        .set({
      'postId': postId,
      'animalToken': animalToken,
      'postOwnerId': userProvider.currentUserMap['mobileNo'],
    });

    await FirebaseFirestore.instance
        .collection('allPosts')
        .doc(postId)
        .set(postMap)
        .then((value) async {
      _emptyFieldCreator();
      await postProvider.getAllPosts();
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
    });
  }

  _emptyFieldCreator() {
    _image = null;
    fileMedia = null;
    _photo = '';
    _video = '';
    _choosenValue = 'Male';
    _petNameController.clear();
    _colorController.clear();
    _genusController.clear();
    _ageController.clear();
  }

  Future<File> pickVideoFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    return File(result!.files.single.path.toString());
  }

  void _cameraGalleryBottomSheet(BuildContext context, String source) {
    Size size = MediaQuery.of(context).size;
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            height: size.height * .2,
            color: Color(0xff737373),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(size.width * .03),
                      topRight: Radius.circular(size.width * .03))),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(source == 'Photo'
                        ? FontAwesomeIcons.camera
                        : FontAwesomeIcons.video),
                    title: Text('Camera'),
                    onTap: () {
                      source == 'Photo' ? _getCameraImage() : _getCameraVideo();

                      Navigator.pop(context);
                      controller != null ? controller!.dispose() : true;
                    },
                  ),
                  ListTile(
                    leading: Icon(source == 'Photo'
                        ? FontAwesomeIcons.images
                        : FontAwesomeIcons.fileVideo),
                    title: Text('Gallery'),
                    onTap: () {
                      source == 'Photo'
                          ? _getGalleryImage()
                          : _getGalleryVideo();
                      Navigator.pop(context);
                      controller != null ? controller!.dispose() : true;
                    },
                  )
                ],
              ),
            ),
          );
        }).then((value) {
      profileImageUploadVisibility = true;
    });
  }

  Future _getGalleryImage() async {
    setState(() {
      this.fileMedia = null;

      this._image = null;
      _photo = '';
      _video = '';
    });
    final _originalImage = await ImagePicker()
        .getImage(source: ImageSource.gallery, imageQuality: 25);

    if (_originalImage != null) {
      await ImageCropper.cropImage(
          sourcePath: _originalImage.path,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: .7),
          androidUiSettings: AndroidUiSettings(
            lockAspectRatio: false,
          )).then((value) {
        setState(() {
          _image = value;
        });
      });
    }
  }

  Future _getGalleryVideo() async {
    setState(() {
      this.fileMedia = null;
      _image = null;
    });
    final file = await pickVideoFile();
    _photo = '';
    _video = '';
    controller = VideoPlayerController.file(file)
      ..addListener(() => setState(() {}))
      ..setLooping(true)
      ..initialize().then((_) {
        controller!.play();
        setState(() {
          fileMedia = file;
          getVideoSize(fileMedia!);
        });
      });
  }

  Future getVideoSize(File file) async {
    final size = await file.length();
    setState(() {
      videoSize = size;
    });
    if (videoSize != null) {
      final size = videoSize! / 1000;
      print('original video size = $size KB');
    }
  }

  Future _getCameraImage() async {
    setState(() {
      //  controller!.dispose();
      this._image = null;
    });
    final _originalImage = await ImagePicker()
        .getImage(source: ImageSource.camera, imageQuality: 25);
    _photo = '';
    _video = '';

    if (_originalImage != null) {
      await ImageCropper.cropImage(
          sourcePath: _originalImage.path,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: .7),
          androidUiSettings: AndroidUiSettings(
            lockAspectRatio: false,
          )).then((value) {
        setState(() {
          _image = value;
        });
      });
    }
  }

  Future _getCameraVideo() async {
    setState(() {
      this.fileMedia = null;
      //   controller!.dispose();
      _image = null;
    });
    final getMedia = ImagePicker().getVideo;
    final media = await getMedia(source: ImageSource.camera);
    final file = File(media!.path);
    _photo = '';
    _video = '';
    if (file == null) {
      return;
    } else {
      setState(() {
        fileMedia = file;
        getVideoSize(fileMedia!);
      });
    }

    // getVideoSize(fileMedia!);
  }

  //textformfile demo design
  Widget textFormFieldBuilder(TextInputType keyboardType, int maxLine,
      TextEditingController textEditingController, String? errorText) {
    return TextFormField(
        controller: textEditingController,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.zero,
          hintStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorText: errorText,
        ),
        keyboardType: keyboardType,
        cursorColor: Colors.black,
        maxLines: maxLine);
  }

  @override
  void dispose() {
    super.dispose();
    if (_controller != null) {
      _controller!.dispose();
    }
  }
}
