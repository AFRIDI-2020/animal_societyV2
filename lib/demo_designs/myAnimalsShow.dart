import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pet_lover/custom_classes/toast.dart';
import 'package:pet_lover/fade_animation.dart';
import 'package:pet_lover/model/post.dart';
import 'package:pet_lover/provider/animalProvider.dart';
import 'package:pet_lover/provider/postProvider.dart';
import 'package:pet_lover/provider/userProvider.dart';
import 'package:pet_lover/sub_screens/commentSection.dart';
import 'package:pet_lover/sub_screens/groupDetail.dart';
import 'package:pet_lover/sub_screens/other_user_profile.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
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

    return Container(
        width: size.width,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            height: size.width * .04,
          ),
          SizedBox(
            height: size.width * .01,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(size.width * .02, size.width * .01,
                size.width * .02, size.width * .01),
            child: Text(
                widget.post.status == '' && widget.post.animalToken != ''
                    ? 'Token: ${widget.post.animalToken}'
                    : widget.post.status,
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: size.width * .045)),
          ),
          SizedBox(
            height: size.width * .02,
          ),
          Visibility(
            visible: widget.post.photo == '' && widget.post.video == ''
                ? false
                : true,
            child: InkWell(
                onDoubleTap: () {},
                child: Container(
                    width: size.width,
                    child: widget.post.photo == '' && widget.post.video == ''
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
                                  if (visibility.visibleFraction == 0 &&
                                      this.mounted) {
                                    _controller!.pause();

                                    print(
                                        'visibility gone'); //pausing  functionality
                                  } else {
                                    _controller!.play();
                                  }
                                },
                                child: Center(
                                  child: _controller!.value.isInitialized
                                      ? Stack(
                                          children: [
                                            AspectRatio(
                                              aspectRatio: _controller!
                                                  .value.aspectRatio,
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
                                                        decoration:
                                                            BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color: Colors
                                                                    .grey
                                                                    .shade800),
                                                        child: Icon(
                                                          Icons.play_arrow,
                                                          color: Colors
                                                              .amberAccent
                                                              .shade400,
                                                          size: size.width * .2,
                                                        ),
                                                      ));
                                                      _controller!.pause();
                                                    } else {
                                                      videoStatusAnimation =
                                                          FadeAnimation(
                                                              child: Container(
                                                                  width:
                                                                      size.width *
                                                                          .2,
                                                                  height:
                                                                      size.width *
                                                                          .2,
                                                                  decoration: BoxDecoration(
                                                                      shape: BoxShape
                                                                          .circle,
                                                                      color: Colors
                                                                          .grey
                                                                          .shade800),
                                                                  child: Icon(
                                                                    Icons.pause,
                                                                    color: Colors
                                                                        .amberAccent
                                                                        .shade400,
                                                                    size:
                                                                        size.width *
                                                                            .2,
                                                                  )));
                                                      _controller!.play();
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
                                                      _controller!.setVolume(1);
                                                      _isMute = false;
                                                    } else {
                                                      _controller!.setVolume(0);
                                                      _isMute = true;
                                                    }
                                                  });
                                                },
                                                child: Container(
                                                    padding: EdgeInsets.all(
                                                        size.width * .02),
                                                    decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Colors
                                                            .grey.shade800),
                                                    child: _isMute
                                                        ? Icon(
                                                            Icons.volume_off,
                                                            color: Colors
                                                                .amberAccent
                                                                .shade400,
                                                            size: size.width *
                                                                .05,
                                                          )
                                                        : Icon(
                                                            Icons.volume_up,
                                                            color: Colors
                                                                .amberAccent
                                                                .shade400,
                                                            size: size.width *
                                                                .05,
                                                          )),
                                              ),
                                            ),
                                            Positioned.fill(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  GestureDetector(
                                                    onDoubleTap: () {
                                                      print('rewind');
                                                      rewind5seconds();
                                                    },
                                                    child: Container(
                                                      width: size.width * .3,
                                                      height: size.width * .3,
                                                      color: Colors.transparent,
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Visibility(
                                                            visible: _rewind
                                                                ? true
                                                                : false,
                                                            child: Container(
                                                                padding: EdgeInsets
                                                                    .all(size
                                                                            .width *
                                                                        .02),
                                                                decoration: BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    color: Colors
                                                                        .grey
                                                                        .shade800),
                                                                child: Icon(
                                                                  Icons
                                                                      .fast_rewind,
                                                                  color: Colors
                                                                      .white,
                                                                  size:
                                                                      size.width *
                                                                          .1,
                                                                )),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  InkWell(
                                                    onDoubleTap: () {
                                                      setState(() {
                                                        forward5second();
                                                      });
                                                    },
                                                    child: Container(
                                                      width: size.width * .3,
                                                      height: size.width * .3,
                                                      color: Colors.transparent,
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Visibility(
                                                            visible: _forword
                                                                ? true
                                                                : false,
                                                            child: Container(
                                                                padding: EdgeInsets
                                                                    .all(size
                                                                            .width *
                                                                        .02),
                                                                decoration: BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    color: Colors
                                                                        .grey
                                                                        .shade800),
                                                                child: Icon(
                                                                  Icons
                                                                      .fast_forward,
                                                                  color: Colors
                                                                      .white,
                                                                  size:
                                                                      size.width *
                                                                          .1,
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
                                              children: <Widget>[
                                                Center(
                                                    child:
                                                        videoStatusAnimation),
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
                                          padding:
                                              EdgeInsets.all(size.width * .3),
                                          child: CircularProgressIndicator(),
                                        ),
                                ),
                              ))),
          ),
          Container(
              width: size.width,
              padding: EdgeInsets.fromLTRB(size.width * .02, size.width * .01,
                  size.width * .02, size.width * .01),
              child: Column(children: [
                Visibility(
                  visible: widget.post.animalName == '' ? false : true,
                  child: Row(
                    children: [
                      Text('Animal name: ',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: size.width * .038)),
                      Text(widget.post.animalName,
                          style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: size.width * .038)),
                    ],
                  ),
                ),
                Visibility(
                  visible: widget.post.animalColor == '' ? false : true,
                  child: Row(
                    children: [
                      Text('Color: ',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: size.width * .038)),
                      Text(widget.post.animalColor,
                          style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: size.width * .038)),
                    ],
                  ),
                ),
                Visibility(
                  visible: widget.post.animalGenus == '' ? false : true,
                  child: Row(
                    children: [
                      Text('Genus: ',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: size.width * .038)),
                      Text(widget.post.animalGenus,
                          style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: size.width * .038)),
                    ],
                  ),
                ),
                Visibility(
                  visible: widget.post.animalGender == '' ? false : true,
                  child: Row(
                    children: [
                      Text('Gender: ',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: size.width * .038)),
                      Text(widget.post.animalGender,
                          style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: size.width * .038)),
                    ],
                  ),
                ),
                Visibility(
                  visible: widget.post.animalAge == '' ? false : true,
                  child: Row(
                    children: [
                      Text('Age: ',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: size.width * .038)),
                      Text(widget.post.animalAge,
                          style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: size.width * .038)),
                    ],
                  ),
                )
              ])),
          Container(
            padding:
                EdgeInsets.fromLTRB(size.width * .02, 0, size.width * .02, 0),
            child: Divider(
              color: Colors.grey.shade300,
              height: size.width * .002,
            ),
          ),
        ]));
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
}
