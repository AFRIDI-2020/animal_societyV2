import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_lover/custom_classes/DatabaseManager.dart';
import 'package:pet_lover/custom_classes/TextFieldValidation.dart';
import 'package:pet_lover/custom_classes/progress_dialog.dart';
import 'package:pet_lover/custom_classes/toast.dart';
import 'package:pet_lover/fade_animation.dart';
import 'package:pet_lover/provider/animalProvider.dart';
import 'package:pet_lover/provider/groupProvider.dart';
import 'package:pet_lover/provider/postProvider.dart';
import 'package:pet_lover/provider/userProvider.dart';
import 'package:pet_lover/sub_screens/groupDetail.dart';
import 'package:pet_lover/sub_screens/groups.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';
import 'package:pet_lover/video_widget.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class GroupPostAdd extends StatefulWidget {
  String groupId;
  String postId;

  GroupPostAdd({required this.groupId, required this.postId});

  @override
  _GroupPostAddState createState() => _GroupPostAddState();
}

class _GroupPostAddState extends State<GroupPostAdd> {
  TextEditingController _statusController = TextEditingController();
  TextEditingController _petNameController = TextEditingController();
  TextEditingController _colorController = TextEditingController();
  TextEditingController _genusController = TextEditingController();
  TextEditingController _genderController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  File? fileMedia;
  File? _image;
  String? postImageLink;
  String? postVideoLink;
  String? imageLink;
  String? _currentMobileNo;
  String? _username;
  String? _userProfileImage;
  String dateData = '';
  String _photo = '';
  String _video = '';
  String? petNameErrorText;
  String? colorErrorText;
  String? genusErrorText;
  String? genderErrorText;
  String? ageErrorText;
  bool profileImageUploadVisibility = false;
  VideoPlayerController? controller;
  int _count = 0;
  bool _imageVideoContainerVisibility = false;
  String _totalComments = '';
  String _totalFollowers = '';
  String _totalShares = '';
  String _groupName = '';
  VideoPlayerController? _controller;
  Widget? videoStatusAnimation;
  bool isVisible = true;

  Future _customInit(
      UserProvider userProvider, GroupProvider groupProvider) async {
    setState(() {
      _count++;
    });

    await groupProvider.getGroupInfo(widget.groupId).then((value) {
      setState(() {
        _groupName = groupProvider.groupInfo['groupName']!;
      });
    });

    if (widget.postId != '') {
      _getPostInfo(widget.postId);
    }
  }

  _getPostInfo(String postId) async {
    await FirebaseFirestore.instance
        .collection('allPosts')
        .doc(postId)
        .get()
        .then((snapshot) {
      setState(() {
        _photo = snapshot['photo'];
        _video = snapshot['video'];
        _statusController.text = snapshot['status'];
        _totalComments = snapshot['totalComments'];
        _totalFollowers = snapshot['totalFollowers'];
        _totalShares = snapshot['totalShares'];
        _imageVideoContainerVisibility = true;
      });

      if (widget.postId != '' && _video != '') {
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

  Widget buildAIndicator() => VideoProgressIndicator(
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
            "Create group post",
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
      body: _bodyUI(context),
    );
  }

  Widget _bodyUI(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final PostProvider postProvider = Provider.of<PostProvider>(context);
    final GroupProvider groupProvider = Provider.of<GroupProvider>(context);
    if (_count == 0) _customInit(userProvider, groupProvider);
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: size.width * .04,
              right: size.width * .04,
              top: size.width * .04,
            ),
            child: Container(
              width: size.width,
              height: size.width * .4,
              padding: EdgeInsets.all(size.width * .03),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(size.width * .04),
              ),
              child: TextFormField(
                controller: _statusController,
                decoration: InputDecoration(
                  hintText: 'Write someting...',
                  hintStyle: TextStyle(fontSize: size.width * .04),
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                ),
                maxLines: 10,
              ),
            ),
          ),
          Padding(
            padding:
                EdgeInsets.only(left: size.width * .04, top: size.width * .02),
            child: Row(
              children: [
                TextButton(
                    style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ))),
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
                          color: Colors.deepOrange,
                        ),
                        SizedBox(
                          width: size.width * .03,
                        ),
                        Text(
                          'Video',
                          style: TextStyle(
                              color: Colors.deepOrange,
                              fontSize: size.width * .038),
                        )
                      ],
                    )),
                SizedBox(
                  width: size.width * .02,
                ),
                Container(
                  height: size.width * .06,
                  child: VerticalDivider(
                    thickness: size.width * .002,
                    color: Colors.black,
                  ),
                ),
                SizedBox(
                  width: size.width * .02,
                ),
                TextButton(
                    style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ))),
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
                          color: Colors.deepOrange,
                        ),
                        SizedBox(
                          width: size.width * .03,
                        ),
                        Text(
                          'Photo',
                          style: TextStyle(
                              color: Colors.deepOrange,
                              fontSize: size.width * .038),
                        )
                      ],
                    ))
              ],
            ),
          ),
          Visibility(
            visible: _imageVideoContainerVisibility,
            child: Container(
              //container for image or video loading
              width: size.width,
              height: size.width * .7,
              decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  border: Border.all(color: Colors.grey.shade200)),
              child: Center(
                child: _photo == '' && _video == ''
                    ? _image != null || fileMedia != null
                        ? Container(
                            width: size.width,
                            height: size.width * .7,
                            color: Colors.grey.shade100,
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
                                            child: buildAIndicator(),
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
          ),
          Container(
            width: size.width,
            height: size.width * .18,
            padding: EdgeInsets.fromLTRB(
                size.width * .04, 20.0, size.width * .04, 0.0),
            child: ElevatedButton(
              onPressed: () {
                String postId = Uuid().v4();
                uploadData(postId, userProvider, postProvider, groupProvider);
              },
              child: Text(
                'POST',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size.width * .04,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ))),
            ),
          ),
          SizedBox(width: size.width * .04),
        ],
      ),
    );
  }

  Future<void> uploadData(String postId, UserProvider userProvider,
      PostProvider postProvider, GroupProvider groupProvider) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return ProgressDialog(message: 'Please wait...');
        });

    if (_image != null || fileMedia != null) {
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
            if (widget.postId == '') {
              _createPost(userProvider, postId, postProvider, groupProvider);
            } else {
              _UpdatePost(userProvider, widget.postId, postProvider);
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
            if (widget.postId == '') {
              _createPost(userProvider, postId, postProvider, groupProvider);
            } else {
              _UpdatePost(userProvider, widget.postId, postProvider);
            }
          });
        });
      }
    } else if (_image == null && fileMedia == null) {
      setState(() {
        postImageLink = _photo;
        postVideoLink = _video;
        if (widget.postId == '') {
          _createPost(userProvider, postId, postProvider, groupProvider);
        } else {
          _UpdatePost(userProvider, widget.postId, postProvider);
        }
      });
    }
  }

  void _UpdatePost(UserProvider userProvider, String postId,
      PostProvider postProvider) async {
    String date = DateTime.now().millisecondsSinceEpoch.toString();

    await FirebaseFirestore.instance
        .collection('Groups')
        .doc(widget.groupId)
        .collection('groupPosts')
        .doc(postId)
        .update({
      'date': date,
    });

    await FirebaseFirestore.instance.collection('allPosts').doc(postId).update({
      'date': date,
      'status': _statusController.text,
      'photo': _image != null ? postImageLink : _photo,
      'video': fileMedia != null ? postVideoLink : _video,
    }).then((value) async {
      await postProvider.getAllPosts();
      await postProvider.getAllGroupPosts(widget.groupId);
      await postProvider.getUserPosts(userProvider.currentUserMobile);
      _emptyFieldCreator();
      Navigator.pop(context);
      Toast().showToast(context, 'Post updated successfully.');
    });
  }

  void _createPost(UserProvider userProvider, String postId,
      PostProvider postProvider, GroupProvider groupProvider) async {
    String date = DateTime.now().millisecondsSinceEpoch.toString();
    Map<String, String> postMap = {
      'postId': postId,
      'postOwnerId': userProvider.currentUserMap['mobileNo'],
      'postOwnerMobileNo': userProvider.currentUserMap['mobileNo'],
      'postOwnerName': userProvider.currentUserMap['username'],
      'postOwnerImage': userProvider.currentUserMap['profileImageLink'],
      'date': date,
      'status': _statusController.text,
      'photo': _image != null ? postImageLink! : '',
      'video': fileMedia != null ? postVideoLink! : '',
      'animalToken': '',
      'animalName': '',
      'animalColor': '',
      'animalAge': '',
      'animalGender': '',
      'animalGenus': '',
      'totalFollowers': '0',
      'totalComments': '0',
      'totalShares': '0',
      'groupId': widget.groupId,
      'shareId': ''
    };

    await FirebaseFirestore.instance
        .collection('Groups')
        .doc(widget.groupId)
        .collection('groupPosts')
        .doc(postId)
        .set({'date': date, 'postId': postId});

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userProvider.currentUserMap['mobileNo'])
        .collection('myPosts')
        .doc(postId)
        .set({'postId': postId, 'date': date});

    await FirebaseFirestore.instance
        .collection('allPosts')
        .doc(postId)
        .set(postMap)
        .then((value) async {
      await groupProvider.getAllMembers(widget.groupId).then((value) async {
        for (int i = 0; i < groupProvider.members.length; i++) {
          String receiverId = groupProvider.members[i].mobileNo;
          String receiverName = groupProvider.members[i].username;
          final String notificationId = Uuid().v4();
          await FirebaseFirestore.instance
              .collection('Notifications')
              .doc(notificationId)
              .set({
            'notificationId': notificationId,
            'date': DateTime.now().millisecondsSinceEpoch.toString(),
            'senderId': userProvider.currentUserMap['mobileNo'],
            'receiverId': receiverId,
            'title': 'Animal Society',
            'body':
                '$_groupName has new post from ${userProvider.currentUserMap['username']}',
            'senderName': userProvider.currentUserMap['username'],
            'receiverName': receiverName,
            'status': 'unclicked',
            'postId': postId
          });
        }
      }).then((value) async {
        _emptyFieldCreator();
        await postProvider.getAllGroupPosts(widget.groupId);
        await postProvider.getAllPosts();
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => GroupDetail(groupId: widget.groupId)));
      });
    });
  }

  _emptyFieldCreator() {
    setState(() {
      _petNameController.clear();
      _colorController.clear();
      _genusController.clear();
      _genderController.clear();
      _ageController.clear();
      _image = null;
      _statusController.clear();
      fileMedia = null;
    });
  }

  Widget buildVideo() => Stack(
        children: <Widget>[
          buildVideoPlayer(),
          Positioned.fill(
              child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => controller!.value.isPlaying
                ? controller!.pause()
                : controller!.play(),
            child: Stack(
              children: <Widget>[
                buildPlay(),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: buildIndicator(),
                ),
              ],
            ),
          )),
        ],
      );
  Widget buildPlay() => controller!.value.isPlaying
      ? Container()
      : Container(
          alignment: Alignment.center,
          color: Colors.black26,
          child: Icon(Icons.play_arrow, color: Colors.white, size: 80),
        );

  Widget buildVideoPlayer() => AspectRatio(
        aspectRatio: controller!.value.aspectRatio,
        child: VideoPlayer(controller!),
      );

  Widget buildIndicator() => VideoProgressIndicator(
        controller!,
        allowScrubbing: true,
      );

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
                      setState(() {
                        _imageVideoContainerVisibility = true;
                      });
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
                      setState(() {
                        _imageVideoContainerVisibility = true;
                      });
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
    final _originalImage =
        await ImagePicker().getImage(source: ImageSource.gallery);

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
      //   controller!.dispose();
      _image = null;
      _photo = '';
      _video = '';
    });
    final file = await pickVideoFile();
    controller = VideoPlayerController.file(file)
      ..addListener(() => setState(() {}))
      ..setLooping(true)
      ..initialize().then((_) {
        controller!.play();
        setState(() {
          fileMedia = file;
        });
      });

    //controller!.dispose();
  }

  Future _getCameraImage() async {
    setState(() {
      //  controller!.dispose();
      this._image = null;
      _photo = '';
      _video = '';
    });
    final _originalImage =
        await ImagePicker().getImage(source: ImageSource.camera);

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

      _image = null;
      _photo = '';
      _video = '';
    });
    final getMedia = ImagePicker().getVideo;
    final media = await getMedia(source: ImageSource.camera);
    final file = File(media!.path);
    if (file == null) {
      return;
    } else {
      setState(() {
        fileMedia = file;
      });
    }
  }

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
    controller!.dispose();
    if (_controller != null) {
      _controller!.dispose();
    }
  }
}
