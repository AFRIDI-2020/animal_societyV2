import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pet_lover/custom_classes/toast.dart';
import 'package:pet_lover/fade_animation.dart';
import 'package:pet_lover/model/post.dart';
import 'package:pet_lover/provider/postProvider.dart';
import 'package:pet_lover/provider/userProvider.dart';
import 'package:pet_lover/sub_screens/imageView.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class TokenSearchPost extends StatefulWidget {
  Post post;
  TokenSearchPost({required this.post});

  @override
  _TokenSearchPostState createState() => _TokenSearchPostState();
}

class _TokenSearchPostState extends State<TokenSearchPost> {
  bool _isMute = false;
  VideoPlayerController? _controller;
  Widget? videoStatusAnimation;
  final key = GlobalKey();
  bool isVisible = true;
  int _count = 0;
  String _userName = '';
  String _address = '';
  String _mobileNo = '';
  String _profileImage = '';
  bool _rewind = false;
  bool _forword = false;

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

  Future _customInit(UserProvider userProvider) async {
    setState(() {
      _count++;
    });
    await userProvider
        .getSpecificUserInfo(widget.post.postOwnerId)
        .then((value) {
      setState(() {
        _userName = userProvider.specificUserMap['username'];
        _address = userProvider.specificUserMap['address'];
        _mobileNo = userProvider.specificUserMap['mobileNo'];
        _profileImage = userProvider.specificUserMap['profileImageLink'];
      });
    });
  }

  Widget buildIndicator() => VideoProgressIndicator(
        _controller!,
        allowScrubbing: true,
      );

  Future<void> _downloadVideo(String videoLink) async {
    await Permission.storage.request().then((value) async {
      if (value.isGranted) {
        Toast().showToast(context, 'Downloaded started...');
        var appDocDir = await getTemporaryDirectory();
        String savePath = appDocDir.path +
            "/${DateTime.now().millisecondsSinceEpoch.toString()}.mp4";
        await Dio().download(videoLink, savePath);
        final result = await ImageGallerySaver.saveFile(savePath);
        Toast().showToast(context, 'Video downloaded successfully');
        print(result);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    if (_count == 0) _customInit(userProvider);
    return Container(
      width: size.width,
      child: Column(
        children: [
          Container(
              width: size.width,
              child: widget.post.photo != ''
                  ? Center(
                      child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ImageView(imageLink: widget.post.photo)));
                      },
                      child: Image.network(
                        widget.post.photo,
                        fit: BoxFit.fill,
                      ),
                    ))
                  : VisibilityDetector(
                      key: key,
                      onVisibilityChanged: (visibility) {
                        if (visibility.visibleFraction == 0 && this.mounted) {
                          _controller!.pause();

                          print('visibility gone'); //pausing  functionality
                        } else {
                          _controller!.play();
                        }
                      },
                      child: Center(
                        child: _controller!.value.isInitialized
                            ? Stack(
                                children: [
                                  AspectRatio(
                                    aspectRatio: _controller!.value.aspectRatio,
                                    child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            isVisible = !isVisible;
                                          });

                                          if (!_controller!
                                              .value.isInitialized) {
                                            return;
                                          }
                                          if (_controller!.value.isPlaying) {
                                            videoStatusAnimation =
                                                FadeAnimation(
                                                    child: Container(
                                              width: size.width * .2,
                                              height: size.width * .2,
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.grey.shade800),
                                              child: Icon(
                                                Icons.play_arrow,
                                                color:
                                                    Colors.amberAccent.shade400,
                                                size: size.width * .2,
                                              ),
                                            ));
                                            _controller!.pause();
                                          } else {
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
                                                          Icons.pause,
                                                          color: Colors
                                                              .amberAccent
                                                              .shade400,
                                                          size: size.width * .2,
                                                        )));
                                            _controller!.play();
                                          }
                                        },
                                        child: VideoPlayer(_controller!)),
                                  ),
                                  Positioned(
                                    top: 20,
                                    right: 10,
                                    child: PopupMenuButton(
                                        itemBuilder: (context) => [
                                              PopupMenuItem(
                                                  child: ListTile(
                                                onTap: () {
                                                  _downloadVideo(
                                                      widget.post.video);
                                                },
                                                leading: Icon(Icons.download),
                                                title: Text('Download'),
                                              ))
                                            ]),
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
                                          padding:
                                              EdgeInsets.all(size.width * .02),
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.grey.shade800),
                                          child: _isMute
                                              ? Icon(
                                                  Icons.volume_off,
                                                  color: Colors
                                                      .amberAccent.shade400,
                                                  size: size.width * .05,
                                                )
                                              : Icon(
                                                  Icons.volume_up,
                                                  color: Colors
                                                      .amberAccent.shade400,
                                                  size: size.width * .05,
                                                )),
                                    ),
                                  ),
                                  Positioned.fill(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
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
                                            height: size.width * .4,
                                            color: Colors.transparent,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Visibility(
                                                  visible:
                                                      _rewind ? true : false,
                                                  child: Container(
                                                      padding: EdgeInsets.all(
                                                          size.width * .02),
                                                      decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: Colors
                                                              .grey.shade800),
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
                                                  MainAxisAlignment.center,
                                              children: [
                                                Visibility(
                                                  visible:
                                                      _forword ? true : false,
                                                  child: Container(
                                                      padding: EdgeInsets.all(
                                                          size.width * .02),
                                                      decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: Colors
                                                              .grey.shade800),
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
                    )),
          Container(
            width: size.width,
            padding: EdgeInsets.all(size.width * .04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Visibility(
                  visible: widget.post.animalName == '' ? false : true,
                  child: Row(
                    children: [
                      Text('Animal name: ',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
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
                              fontWeight: FontWeight.w600,
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
                              fontWeight: FontWeight.w600,
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
                              fontWeight: FontWeight.w600,
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
                              fontWeight: FontWeight.w600,
                              fontSize: size.width * .038)),
                      Text(widget.post.animalAge,
                          style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: size.width * .038)),
                    ],
                  ),
                ),
                SizedBox(
                  height: size.width * .04,
                ),
                Text('Owner information',
                    style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: size.width * .05)),
                SizedBox(
                  height: size.width * .02,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('Name: ',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                        fontSize: size.width * .038)),
                                Text(_userName,
                                    style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: size.width * .038)),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Address: ',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                        fontSize: size.width * .038)),
                                Container(
                                  width: size.width * .5,
                                  child: Text(_address,
                                      style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: size.width * .038)),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text('Mobile: ',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                        fontSize: size.width * .04)),
                                Text(_mobileNo,
                                    style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: size.width * .04)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    CircleAvatar(
                      radius: size.width * .08,
                      backgroundImage: _profileImage == ''
                          ? AssetImage('assets/profile_image_demo.png')
                          : NetworkImage(_profileImage) as ImageProvider,
                    )
                  ],
                )
              ],
            ),
          )
        ],
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
}
