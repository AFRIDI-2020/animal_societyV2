import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pet_lover/custom_classes/toast.dart';
import 'package:pet_lover/fade_animation.dart';
import 'package:video_player/video_player.dart';

class VideoView extends StatefulWidget {
  String videoLink;
  VideoView({required this.videoLink});

  @override
  _VideoViewState createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  VideoPlayerController? controller;
  Widget? videoStatusAnimation;
  bool isVisible = true;
  bool _loading = false;

  Widget buildIndicator() => VideoProgressIndicator(
        controller!,
        allowScrubbing: true,
      );

  @override
  void initState() {
    super.initState();

    controller = VideoPlayerController.network(widget.videoLink)
      ..addListener(() => mounted ? setState(() {}) : true)
      ..setLooping(true)
      ..initialize().then((_) => controller!.play());
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
              onPressed: () {
                _downloadVideo(widget.videoLink);
              },
              icon: Icon(
                Icons.download,
                color: Colors.white,
              ))
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: size.width * .05),
          Container(
            width: size.width,
            height: size.height * .7,
            child: Center(
                child: controller != null
                    ? controller!.value.isInitialized
                        ? Stack(
                            children: [
                              AspectRatio(
                                aspectRatio: controller!.value.aspectRatio,
                                child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isVisible = !isVisible;
                                      });

                                      if (!controller!.value.isInitialized) {
                                        return;
                                      }
                                      if (controller!.value.isPlaying) {
                                        videoStatusAnimation = FadeAnimation(
                                            child: const Icon(Icons.pause,
                                                size: 100.0));
                                        controller!.pause();
                                      } else {
                                        videoStatusAnimation = FadeAnimation(
                                            child: const Icon(Icons.play_arrow,
                                                size: 100.0));
                                        controller!.play();
                                      }
                                    },
                                    child: VideoPlayer(controller!)),
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
                        : CircularProgressIndicator()
                    : Container()),
          ),
          SizedBox(
            height: size.width * .1,
          ),
          _loading == false
              ? Container()
              : Text(
                  'downloading...',
                  style: TextStyle(
                      color: Colors.white, fontSize: size.width * .04),
                )
        ],
      ),
    );
  }

  Future<void> _downloadVideo(String videoLink) async {
    await Permission.storage.request().then((value) async {
      if (value.isGranted) {
        setState(() => _loading = true);
        var appDocDir = await getTemporaryDirectory();
        String savePath = appDocDir.path +
            "/${DateTime.now().millisecondsSinceEpoch.toString()}.mp4";
        await Dio().download(videoLink, savePath);
        final result = await ImageGallerySaver.saveFile(savePath);
        setState(() => _loading = false);
        Toast().showToast(context, 'Video downloaded successfully');
        print(result);
      }
    });
  }
}
