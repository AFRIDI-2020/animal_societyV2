import 'package:flutter/material.dart';
import 'package:pet_lover/provider/postProvider.dart';
import 'package:pet_lover/provider/userProvider.dart';
import 'package:pet_lover/sub_screens/favouritePostShow.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:video_player/video_player.dart';

class FollowingNav extends StatefulWidget {
  @override
  _FollowingNavState createState() => _FollowingNavState();
}

class _FollowingNavState extends State<FollowingNav> {
  int count = 0;
  String? finalDate;

  bool _loading = false;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  Future _customInit(
      UserProvider userProvider, PostProvider postProvider) async {
    setState(() {
      count++;
    });
    if (postProvider.favouriteList.isEmpty) {
      setState(() {
        _loading = true;
      });
      await userProvider.getCurrentUserInfo();
      await postProvider.getFavourites(userProvider);
      setState(() {
        _loading = false;
      });
    }
  }

  void _onRefresh(PostProvider postProvider, UserProvider userProvider) async {
    await Future.delayed(Duration(milliseconds: 1000));
    await userProvider.getCurrentUserInfo();
    await postProvider.getFavourites(userProvider);
    _refreshController.refreshCompleted();
  }

  void _onLoading(PostProvider postProvider, UserProvider userProvider) async {
    await Future.delayed(Duration(milliseconds: 1000));

    if (postProvider.hasFovouriteNext) {
      await postProvider.getMoreFavourites(userProvider);
    }
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _bodyUI(context),
    );
  }

  Widget _bodyUI(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final PostProvider postProvider = Provider.of<PostProvider>(context);
    if (count == 0) _customInit(userProvider, postProvider);

    return _loading
        ? Center(child: CircularProgressIndicator())
        : postProvider.favouriteList.isEmpty
            ? Center(
                child: Text(
                'Noting to show',
                style: TextStyle(fontSize: 16),
              ))
            : SmartRefresher(
                controller: _refreshController,
                enablePullDown: true,
                enablePullUp: true,
                header: WaterDropHeader(),
                onRefresh: () => _onRefresh(postProvider, userProvider),
                onLoading: () => _onLoading(postProvider, userProvider),
                child: ListView.builder(
                    physics: ClampingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: postProvider.favouriteList.length,
                    itemBuilder: (context, index) {
                      return FavouritePostShow(
                        index: index,
                        post: postProvider.favouriteList[index],
                      );
                    }),
              );
  }
}
