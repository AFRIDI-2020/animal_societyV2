import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pet_lover/custom_classes/toast.dart';
import 'package:pet_lover/fade_animation.dart';
import 'package:pet_lover/model/post.dart';
import 'package:pet_lover/provider/animalProvider.dart';
import 'package:pet_lover/provider/postProvider.dart';
import 'package:pet_lover/provider/userProvider.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class MyAnimalsShow extends StatefulWidget {
  int index;
  Post post;
  final VideoPlayerController videoPlayerController;
  final bool looping;
  MyAnimalsShow(
      {required this.index,
      required this.post,
      required this.videoPlayerController,
      required this.looping});

  @override
  _MyAnimalsShowState createState() => _MyAnimalsShowState();
}

class _MyAnimalsShowState extends State<MyAnimalsShow> {
  String _groupName = '';
  String _previousOwnerOfPost = '';
  VideoPlayerController? _controller;
  Widget? videoStatusAnimation;
  bool isVisible = true;
  bool _isFollowed = false;
  int _count = 0;
  bool _isSharing = false;
  bool _rewind = false;
  bool _forword = false;
  bool _isMute = false;
  final key = GlobalKey();
  ScreenshotController? screenshotController = ScreenshotController();
  String _qrCodeData = '';

  @override
  void initState() {
    super.initState();

    if (widget.post.video != '') {
      _controller = VideoPlayerController.network(widget.post.video)
        ..addListener(() => mounted ? setState(() {}) : true)
        ..setLooping(true)
        ..initialize().then((_) {
          _controller!.pause();
          _controller!.setVolume(1);
        });
    }
  }

  Widget buildIndicator() => VideoProgressIndicator(
        _controller!,
        allowScrubbing: true,
      );

  @override
  Widget build(BuildContext context) {
    final AnimalProvider animalProvider = Provider.of<AnimalProvider>(context);
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final PostProvider postProvider = Provider.of<PostProvider>(context);
    Size size = MediaQuery.of(context).size;
    DateTime miliDate =
        new DateTime.fromMillisecondsSinceEpoch(int.parse(widget.post.date));
    var format = new DateFormat("yMMMd").add_jm();
    String finalDate = format.format(miliDate);
    // if (postProvider.isVideoPlaying == false) {
    //   setState(() {
    //     if (_controller != null) {
    //       _controller!.pause();
    //     }
    //   });
    // }

    return Padding(
      padding: EdgeInsets.only(
        top: size.width * .015,
      ),
      child: Card(
        child: Container(
            width: size.width,
            padding: EdgeInsets.only(bottom: size.width * .06),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Visibility(
                    visible: widget.post.photo == '' && widget.post.video == ''
                        ? false
                        : true,
                    child: InkWell(
                        onDoubleTap: () {},
                        child: Container(
                            width: size.width,
                            child:
                                widget.post.photo == '' &&
                                        widget.post.video == ''
                                    ? Container()
                                    : widget.post.photo != ''
                                        ? Center(
                                            child: Image.network(
                                            widget.post.photo,
                                            fit: BoxFit.fill,
                                          ))
                                        : VisibilityDetector(
                                            key: key,
                                            onVisibilityChanged: (visibility) {
                                              if (visibility.visibleFraction ==
                                                      0 &&
                                                  this.mounted) {
                                                _controller!.pause();

                                                print(
                                                    'visibility gone'); //pausing  functionality
                                              } else {
                                                _controller!.play();
                                              }
                                            },
                                            child: Center(
                                              child:
                                                  _controller!
                                                          .value.isInitialized
                                                      ? Stack(
                                                          children: [
                                                            AspectRatio(
                                                              aspectRatio:
                                                                  _controller!
                                                                      .value
                                                                      .aspectRatio,
                                                              child:
                                                                  GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          isVisible =
                                                                              !isVisible;
                                                                        });

                                                                        if (!_controller!
                                                                            .value
                                                                            .isInitialized) {
                                                                          return;
                                                                        }
                                                                        if (_controller!
                                                                            .value
                                                                            .isPlaying) {
                                                                          videoStatusAnimation = FadeAnimation(
                                                                              child: Container(
                                                                            width:
                                                                                size.width * .2,
                                                                            height:
                                                                                size.width * .2,
                                                                            decoration:
                                                                                BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade800),
                                                                            child:
                                                                                Icon(
                                                                              Icons.play_arrow,
                                                                              color: Colors.amberAccent.shade400,
                                                                              size: size.width * .2,
                                                                            ),
                                                                          ));
                                                                          _controller!
                                                                              .pause();
                                                                        } else {
                                                                          videoStatusAnimation = FadeAnimation(
                                                                              child: Container(
                                                                                  width: size.width * .2,
                                                                                  height: size.width * .2,
                                                                                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade800),
                                                                                  child: Icon(
                                                                                    Icons.pause,
                                                                                    color: Colors.amberAccent.shade400,
                                                                                    size: size.width * .2,
                                                                                  )));
                                                                          _controller!
                                                                              .play();
                                                                        }
                                                                      },
                                                                      child: VideoPlayer(
                                                                          _controller!)),
                                                            ),
                                                            Positioned(
                                                              bottom: 20,
                                                              right: 10,
                                                              child: InkWell(
                                                                onTap: () {
                                                                  setState(() {
                                                                    if (_isMute) {
                                                                      _controller!
                                                                          .setVolume(
                                                                              1);
                                                                      _isMute =
                                                                          false;
                                                                    } else {
                                                                      _controller!
                                                                          .setVolume(
                                                                              0);
                                                                      _isMute =
                                                                          true;
                                                                    }
                                                                  });
                                                                },
                                                                child: Container(
                                                                    padding: EdgeInsets.all(size.width * .02),
                                                                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade800),
                                                                    child: _isMute
                                                                        ? Icon(
                                                                            Icons.volume_off,
                                                                            color:
                                                                                Colors.amberAccent.shade400,
                                                                            size:
                                                                                size.width * .05,
                                                                          )
                                                                        : Icon(
                                                                            Icons.volume_up,
                                                                            color:
                                                                                Colors.amberAccent.shade400,
                                                                            size:
                                                                                size.width * .05,
                                                                          )),
                                                              ),
                                                            ),
                                                            Positioned.fill(
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  GestureDetector(
                                                                    onDoubleTap:
                                                                        () {
                                                                      print(
                                                                          'rewind');
                                                                      rewind5seconds();
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      width:
                                                                          size.width *
                                                                              .3,
                                                                      height:
                                                                          size.width *
                                                                              .3,
                                                                      color: Colors
                                                                          .transparent,
                                                                      child:
                                                                          Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          Visibility(
                                                                            visible: _rewind
                                                                                ? true
                                                                                : false,
                                                                            child: Container(
                                                                                padding: EdgeInsets.all(size.width * .02),
                                                                                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade800),
                                                                                child: Icon(
                                                                                  Icons.fast_rewind,
                                                                                  color: Colors.white,
                                                                                  size: size.width * .1,
                                                                                )),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  InkWell(
                                                                    onDoubleTap:
                                                                        () {
                                                                      setState(
                                                                          () {
                                                                        forward5second();
                                                                      });
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      width:
                                                                          size.width *
                                                                              .3,
                                                                      height:
                                                                          size.width *
                                                                              .3,
                                                                      color: Colors
                                                                          .transparent,
                                                                      child:
                                                                          Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          Visibility(
                                                                            visible: _forword
                                                                                ? true
                                                                                : false,
                                                                            child: Container(
                                                                                padding: EdgeInsets.all(size.width * .02),
                                                                                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade800),
                                                                                child: Icon(
                                                                                  Icons.fast_forward,
                                                                                  color: Colors.white,
                                                                                  size: size.width * .1,
                                                                                )),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Positioned.fill(
                                                                child: Stack(
                                                              children: <
                                                                  Widget>[
                                                                Center(
                                                                    child:
                                                                        videoStatusAnimation),
                                                                Positioned(
                                                                  bottom: 0,
                                                                  left: 0,
                                                                  right: 0,
                                                                  child:
                                                                      buildIndicator(),
                                                                ),
                                                              ],
                                                            ))
                                                          ],
                                                        )
                                                      : Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  size.width *
                                                                      .3),
                                                          child:
                                                              CircularProgressIndicator(),
                                                        ),
                                            ),
                                          ))),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(size.width * .04,
                        size.width * .04, size.width * .04, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Visibility(
                              visible:
                                  widget.post.animalName == '' ? false : true,
                              child: Row(
                                children: [
                                  Text('Animal name: ',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: size.width * .038,
                                          fontWeight: FontWeight.w500)),
                                  Text(widget.post.animalName,
                                      style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: size.width * .038)),
                                ],
                              ),
                            ),
                            Visibility(
                              visible:
                                  widget.post.animalColor == '' ? false : true,
                              child: Row(
                                children: [
                                  Text('Color: ',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: size.width * .038,
                                          fontWeight: FontWeight.w500)),
                                  Text(widget.post.animalColor,
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: size.width * .038,
                                      )),
                                ],
                              ),
                            ),
                            Visibility(
                              visible:
                                  widget.post.animalGenus == '' ? false : true,
                              child: Row(
                                children: [
                                  Text('Genus: ',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: size.width * .038,
                                          fontWeight: FontWeight.w500)),
                                  Text(widget.post.animalGenus,
                                      style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: size.width * .038,
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                            Visibility(
                              visible:
                                  widget.post.animalGender == '' ? false : true,
                              child: Row(
                                children: [
                                  Text('Gender: ',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: size.width * .038,
                                          fontWeight: FontWeight.w500)),
                                  Text(widget.post.animalGender,
                                      style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: size.width * .038)),
                                ],
                              ),
                            ),
                            Visibility(
                              visible:
                                  widget.post.animalAge == '' ? false : true,
                              child: Row(
                                children: [
                                  Text('Age: ',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: size.width * .038,
                                          fontWeight: FontWeight.w500)),
                                  Text(widget.post.animalAge,
                                      style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: size.width * .038)),
                                ],
                              ),
                            )
                          ],
                        ),
                        IconButton(
                            onPressed: () {
                              setState(() {
                                _qrCodeData =
                                    'Animal name: ${widget.post.animalName}\nToken: ${widget.post.animalToken}\nFollow the link below to find its owner\nhttps://play.google.com/store/apps/details?id=com.glamworlditltd.animal_society';
                              });
                              _qrCodeBottomSheet(context);
                            },
                            icon: Icon(
                              Icons.qr_code,
                              size: size.width * .1,
                            ))
                      ],
                    ),
                  )
                ])),
      ),
    );
  }

  Future goToRewindPosition(
      Duration Function(Duration currentPosition) builder) async {
    setState(() {
      _rewind = true;
    });
    final currentPosition = await _controller!.position;
    final newPosition = builder(currentPosition!);

    await _controller!.seekTo(newPosition);
    setState(() {
      _rewind = false;
    });
  }

  Future goToForwordPosition(
      Duration Function(Duration currentPosition) builder) async {
    setState(() {
      _forword = true;
    });
    final currentPosition = await _controller!.position;
    final newPosition = builder(currentPosition!);

    await _controller!.seekTo(newPosition);
    setState(() {
      _forword = false;
    });
  }

  Future rewind5seconds() async {
    goToRewindPosition(
        (currentPosition) => currentPosition - Duration(seconds: 3));
  }

  Future forward5second() async {
    goToForwordPosition(
        (currentPosition) => currentPosition + Duration(seconds: 3));
  }

  @override
  void dispose() {
    super.dispose();
    if (_controller != null) {
      _controller!.dispose();
    }
  }

  void _qrCodeBottomSheet(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            color: Color(0xff737373),
            child: Container(
              padding: EdgeInsets.all(size.width * .01),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(size.width * .05),
                      topRight: Radius.circular(size.width * .05))),
              child: Column(
                children: [
                  Container(
                    width: size.width,
                    alignment: Alignment.topRight,
                    child: IconButton(
                        onPressed: () {
                          downlaodQR();
                          //getVersion();
                        },
                        icon: Icon(Icons.download, size: size.width * .08)),
                  ),
                  SizedBox(
                    height: size.width * .05,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Screenshot(
                        controller: screenshotController!,
                        child: Container(
                          color: Colors.white,
                          child: QrImage(
                            data: _qrCodeData,
                            embeddedImage: NetworkImage(widget.post.photo),
                            version: QrVersions.auto,
                            size: 200.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: size.width * .1,
                  ),
                  Container(
                      width: size.width,
                      padding: EdgeInsets.only(
                        left: size.width * .05,
                        right: size.width * .05,
                      ),
                      child: Text(
                        _qrCodeData,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ))
                ],
              ),
            ),
          );
        });
  }

  Future getVersion() async {
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      String appName = packageInfo.appName;
      String packageName = packageInfo.packageName;
      String version = packageInfo.version;
      String buildNumber = packageInfo.buildNumber;
      print('your app version is : $version');
    });
  }

  Future downlaodQR() async {
    var status = await Permission.storage.status;
    print('permission : $status');
    if (status.isGranted) {
      screenshotController!.capture().then((Uint8List? image) async {
        // final directory = await getExternalStorageDirectory();
        // print(directory!.path.substring(0, 19));
        // final imagePath =
        //     await File('${directory.path.substring(0, 19)}/image.png').create();
        // print('imagepath = $imagePath');
        // await imagePath.writeAsBytes(image!).then((value) {
        //   Toast().showToast(context, 'Successfully downloaded.');
        // });
        await ImageGallerySaver.saveImage(
          image!,
          quality: 60,
          name: DateTime.now().millisecondsSinceEpoch.toString(),
        );
        Toast().showToast(context, 'Successfully downloaded.');
      });
    } else {
      await Permission.storage.request();
    }
  }
}
