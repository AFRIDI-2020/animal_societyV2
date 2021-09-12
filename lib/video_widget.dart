import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pet_lover/fade_animation.dart';

import 'package:video_player/video_player.dart';

class VideoWidget extends StatefulWidget {
  final File file;

  const VideoWidget(
    this.file,
  );

  @override
  VideoWidgetState createState() => VideoWidgetState();
}

class VideoWidgetState extends State<VideoWidget> {
  VideoPlayerController? _controller;
  bool _isPlaying = false;

  Widget? videoStatusAnimation;

  @override
  void initState() {
    super.initState();

    videoStatusAnimation = Container();

    _controller = VideoPlayerController.file(widget.file)
      ..addListener(() {
        final bool isPlaying = _controller!.value.isPlaying;
        if (isPlaying != _isPlaying) {
          setState(() {
            _isPlaying = isPlaying;
          });
        }
      })
      ..initialize().then((_) {
        if (this.mounted) {
          setState(() {
            _controller!.play();
          });
        }

        // if (!mounted) return;

        // setState(() {});
      });
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AspectRatio(
        aspectRatio: 4 / 3,
        child: _controller!.value.isInitialized ? videoPlayer() : Container(),
      );

  Widget videoPlayer() => Stack(
        children: <Widget>[
          Center(child: Container(width: 300, child: video())),
          Align(
            alignment: Alignment.bottomCenter,
            child: VideoProgressIndicator(
              _controller!,
              allowScrubbing: true,
              padding: EdgeInsets.all(16.0),
            ),
          ),
          Center(child: videoStatusAnimation),
        ],
      );

  Widget video() => GestureDetector(
        child: VideoPlayer(_controller!),
        onTap: () {
          if (!_controller!.value.isInitialized) {
            return;
          }
          if (_controller!.value.isPlaying) {
            videoStatusAnimation =
                FadeAnimation(child: const Icon(Icons.pause, size: 100.0));
            _controller!.pause();
          } else {
            videoStatusAnimation =
                FadeAnimation(child: const Icon(Icons.play_arrow, size: 100.0));
            _controller!.play();
          }
        },
      );
}
