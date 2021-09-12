import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pet_lover/model/follower.dart';
import 'package:pet_lover/model/user.dart';
import 'package:pet_lover/sub_screens/myFollowers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  Map<String, String> _currentUserMap = {};
  int _mFollowing = 0;
  int _myFollowers = 0;
  Map<String, String> _specificUserMap = {};
  bool _isUserExists = false;
  String _currentUserMobile = '';
  List<Follower> _followerList = [];
  List<Follower> _followingList = [];
  int _otherUserFollower = 0;
  int _otherUserFollowing = 0;
  List<User> _searchedUsers = [];

  get currentUserMap => _currentUserMap;
  get followerList => _followerList;
  get followingList => _followingList;
  get mFollowing => _mFollowing;
  get specificUserMap => _specificUserMap;
  get isUserExists => _isUserExists;
  get currentUserMobile => _currentUserMobile;
  get myFollowers => _myFollowers;
  get otherUserFollowing => _otherUserFollowing;
  get otherUserFollower => _otherUserFollower;
  get searchedUsers => _searchedUsers;

  Future<void> getCurrentUserInfo() async {
    String? _currentMobileNo = await getCurrentMobileNo();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentMobileNo)
        .get()
        .then((snapshot) {
      _currentUserMap = {
        'about': snapshot['about'],
        'address': snapshot['address'],
        'mobileNo': snapshot['mobileNo'],
        'passowrd': snapshot['password'],
        'profileImageLink': snapshot['profileImageLink'],
        'registrationDate': snapshot['registrationDate'],
        'username': snapshot['username']
      };
    });
  }

  Future<String> getCurrentMobileNo() async {
    final _prefs = await SharedPreferences.getInstance();
    final _currentMobileNo = _prefs.getString('mobileNo') ?? null;
    _currentUserMobile = _currentMobileNo!;
    print('Current Mobile no given by userProvider is $_currentMobileNo');
    return _currentMobileNo;
  }

  Future<String?> getSharedPref() async {
    final _prefs = await SharedPreferences.getInstance();
    final _currentMobileNo = _prefs.getString('mobileNo') ?? null;
    return _currentMobileNo;
  }

  Future<void> getMyFollowingsNumber() async {
    _mFollowing = 0;
    CollectionReference _myFollowingRef = FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUserMobile)
        .collection('myFollowings');

    _myFollowingRef.get().then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        _mFollowing = snapshot.docs.length;
        notifyListeners();
      }
      print('$_currentUserMobile is following $_mFollowing persons');
    });
  }

  Future<void> getOtherUserFollowingsNumber(String userId) async {
    _otherUserFollowing = 0;
    CollectionReference _myFollowingRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('myFollowings');

    _myFollowingRef.get().then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        _otherUserFollowing = snapshot.docs.length;
        notifyListeners();
      }
      print('$_currentUserMobile is following $_mFollowing persons');
    });
  }

  Future<void> getMyFollowersNumber() async {
    _myFollowers = 0;
    CollectionReference _myFollowerRef = FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUserMobile)
        .collection('followers');
    _myFollowerRef.get().then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        _myFollowers = snapshot.docs.length;
        notifyListeners();
      }
      print('$_currentUserMobile total followers $_myFollowers persons');
    });
  }

  Future<void> getOtherUserFollowersNumber(String userId) async {
    _otherUserFollower = 0;
    CollectionReference _myFollowerRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('followers');
    _myFollowerRef.get().then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        _otherUserFollower = snapshot.docs.length;
        notifyListeners();
      }
      print('$userId total followers $_otherUserFollower persons');
    });
  }

  Future<void> getSpecificUserInfo(String mobileNo) async {
    try {
      _specificUserMap = {};
      await FirebaseFirestore.instance
          .collection('users')
          .doc(mobileNo)
          .get()
          .then((snapshot) {
        if (snapshot.exists) {
          _specificUserMap = {
            'about': snapshot['about'],
            'address': snapshot['address'],
            'mobileNo': snapshot['mobileNo'],
            'passowrd': snapshot['password'],
            'profileImageLink': snapshot['profileImageLink'],
            'registrationDate': snapshot['registrationDate'],
            'username': snapshot['username']
          };
          _isUserExists = true;
        } else {
          _isUserExists = false;
        }
      });
    } catch (error) {
      print('searching people failed - $error');
      _isUserExists = false;
    }
  }

  Future<bool> getAllFollowers(String userMobileNo) async {
    try {
      _followerList.clear();
      print('getting all followers...');
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userMobileNo)
          .collection('followers')
          .get()
          .then((value) {
        value.docChanges.forEach((element) async {
          String id = element.doc['id'];

          await getSpecificUserInfo(id).then((value) {
            Follower follower = Follower(
                mobileNo: _specificUserMap['mobileNo']!,
                name: _specificUserMap['username']!,
                photo: _specificUserMap['profileImageLink']!);

            _followerList.add(follower);
            notifyListeners();
          });
        });
      });
      return Future.value(true);
    } catch (error) {
      print('getting all followers failed - $error');
      return Future.value(false);
    }
  }

  Future<void> getAllFollowingPeople(String userMobileNo) async {
    try {
      _followingList.clear();
      print('getting folloings');
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userMobileNo)
          .collection('myFollowings')
          .get()
          .then((snapshot) {
        snapshot.docChanges.forEach((element) async {
          String id = element.doc['id'];
          await getSpecificUserInfo(id).then((value) {
            Follower following = Follower(
                mobileNo: _specificUserMap['mobileNo']!,
                name: _specificUserMap['username']!,
                photo: _specificUserMap['profileImageLink']!);

            _followingList.add(following);
            notifyListeners();
          });
        });
      });
    } catch (error) {
      print('Fetching all following people failed - $error');
    }
  }

  Future<void> resetPassword(String mobileNo, String newPassword) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(mobileNo)
          .update({'password': newPassword});
    } catch (error) {
      print('Password changed failed, error: $error');
    }
  }

  Future<void> searchUser(String searchItem) async {
    try {
      await FirebaseFirestore.instance.collection('users').get().then((value) {
        _searchedUsers.clear();
        value.docChanges.forEach((element) {
          if (element.doc['username'].toLowerCase() ==
              searchItem.toLowerCase()) {
            User user = User(
                mobileNo: element.doc['mobileNo'],
                username: element.doc['username'],
                profileImageLink: element.doc['profileImageLink']);
            _searchedUsers.add(user);
          }
        });
      });
      notifyListeners();
    } catch (error) {
      print('searching user error: $error');
    }
  }

  void makeSearchedUsersClear() {
    _searchedUsers.clear();
  }
}
