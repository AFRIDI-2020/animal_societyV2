import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pet_lover/custom_classes/toast.dart';

class ImageView extends StatefulWidget {
  String imageLink;
  ImageView({required this.imageLink});

  @override
  _ImageViewState createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.cancel,
              color: Colors.white,
            )),
        actions: [
          IconButton(
              onPressed: () {
                _downloadImage(widget.imageLink);
              },
              icon: Icon(
                Icons.download,
                color: Colors.white,
              ))
        ],
      ),
      body: Container(
        width: size.width,
        height: size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              widget.imageLink,
              fit: BoxFit.contain,
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
      ),
    );
  }

  Future<void> _downloadImage(String imageLink) async {
    await Permission.storage.request().then((value) async {
      if (value.isGranted) {
        setState(() => _loading = true);
        var response = await Dio()
            .get(imageLink, options: Options(responseType: ResponseType.bytes));
        final result = await ImageGallerySaver.saveImage(
          Uint8List.fromList(response.data),
          quality: 60,
          name: DateTime.now().millisecondsSinceEpoch.toString(),
        );
        setState(() => _loading = false);
        Toast().showToast(context, 'Image downloaded successfully');
        print(result);
      }
    });
  }
}
