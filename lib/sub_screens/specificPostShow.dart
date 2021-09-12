import 'package:flutter/material.dart';
import 'package:pet_lover/provider/animalProvider.dart';
import 'package:pet_lover/provider/postProvider.dart';
import 'package:pet_lover/provider/userProvider.dart';
import 'package:pet_lover/sub_screens/specificPost.dart';
import 'package:provider/provider.dart';

class SpecificPostShow extends StatefulWidget {
  String postId;
  String title;
  SpecificPostShow({required this.postId, required this.title});

  @override
  _SpecificPostShowState createState() => _SpecificPostShowState();
}

class _SpecificPostShowState extends State<SpecificPostShow> {
  int count = 0;
  Future _customInit(PostProvider postProvider) async {
    setState(() {
      count++;
    });
    await postProvider.getSpecificPost(widget.postId);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final AnimalProvider animalProvider = Provider.of<AnimalProvider>(context);
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final PostProvider postProvider = Provider.of<PostProvider>(context);
    if (count == 0) _customInit(postProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0.0,
      ),
      body: ListView.builder(
          itemCount: postProvider.specificPost.length,
          itemBuilder: (context, index) {
            return SpecificPost(
                post: postProvider.specificPost[index], index: index);
          }),
    );
  }
}
