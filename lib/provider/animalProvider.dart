import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pet_lover/model/Comment.dart';
import 'package:pet_lover/model/chat_user_model.dart';
import 'package:pet_lover/provider/userProvider.dart';

class AnimalProvider extends ChangeNotifier {
  bool _isFollower = false;
  int _numberOfFollowers = 0;
  int _numberOfComments = 0;
  int _numberOfShares = 0;
  List<Comment> _commentList = [];
  int documentLimit = 4;
  int _userFollowersNumber = 0;
  List<ChatUserModel> _chatUserList = <ChatUserModel>[];
  List<ChatUserModel> _followingChatUserList = [];
  List<ChatUserModel> _allChatUserList = [];

  get numberOfFollowers => _numberOfFollowers;
  get isFollower => _isFollower;
  get commentList => _commentList;
  get numberOfComments => _numberOfComments;
  get numberOfShares => _numberOfShares;
  get userFollowersNumber => _userFollowersNumber;
  get chatUserList => _chatUserList;
  get followingChatUserList => _followingChatUserList;
  get allChatUserList => _allChatUserList;

  Future<void> myFollowings(
      String _currentMobileNo,
      String mobileNo,
      String followingName,
      String followerName,
      String followingImage,
      String followerImage,
      UserProvider userProvider) async {
    try {
      if (mobileNo != _currentMobileNo) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_currentMobileNo)
            .collection('myFollowings')
            .doc(mobileNo)
            .set({'username': followingName, 'mobile': mobileNo});

        await FirebaseFirestore.instance
            .collection('users')
            .doc(mobileNo)
            .collection('followers')
            .doc(_currentMobileNo)
            .set({
          'follower': _currentMobileNo,
        }).then((value) async {
          await FirebaseFirestore.instance
              .collection('chatUsers')
              .doc(_currentMobileNo + mobileNo)
              .set({
            'id': _currentMobileNo,
            'followingName': followingName,
            'followerName': followerName,
            'followingImageLink': followingImage,
            'followerImageLink': followerImage,
            'followerNumber': _currentMobileNo,
            'followingNumber': mobileNo,
            'lastMessage': 'You can now chat with this animal owner',
            'lastMessageTime': Timestamp.now(),
            'isSeen': false
          }).then((value) async {
            await getAllChatUser(userProvider);
          });
        });
      }
    } catch (error) {
      print('Cannot add in followings ... error = $error');
    }
  }

  Future<void> updateSeen(
      String followerMobileNo, String followingMobileNo) async {
    final refUsers3 = FirebaseFirestore.instance.collection('chatUsers');
    await refUsers3
        .doc(followerMobileNo + followingMobileNo)
        .update({'isSeen': true});
  }

  Future<void> uploadMessage(
      String message,
      String senderName,
      String senderMobile,
      String followerNumber,
      String followingNumber,
      String followingName,
      String followerName) async {
    final refMessages1 = FirebaseFirestore.instance
        .collection('Chats/$followerNumber $followingNumber/messages');
    final refUsers = FirebaseFirestore.instance.collection('chatUsers');

    await refMessages1.add({
      'text': message,
      'sender': senderMobile,
      'senderName': senderName,
      'follower': followerName,
      'following': followingName,
      "timestamp": Timestamp.now(),
    }).then((value) async {
      await refUsers.doc(followerNumber + followingNumber).update({
        'id': followerNumber,
        'followingName': followingName,
        'followerName': followerName,
        'followerNumber': followerNumber,
        'followingNumber': followingNumber,
        'lastMessage': message,
        'lastMessageTime': Timestamp.now(),
        'isSeen': false
      });
    });
    notifyListeners();
  }

  Future<void> getAllChatUser(UserProvider userProvider) async {
    try {
      await userProvider.getCurrentMobileNo().then((value) async {
        await FirebaseFirestore.instance
            .collection('chatUsers')
            .orderBy('lastMessageTime', descending: true)
            .get()
            .then((snapShot) {
          _chatUserList.clear();
          snapShot.docChanges.forEach((element) {
            if (element.doc['followerNumber'] ==
                    userProvider.currentUserMobile ||
                element.doc['followingNumber'] ==
                    userProvider.currentUserMobile) {
              ChatUserModel chatUsers = ChatUserModel(
                  id: element.doc['id'],
                  followingName: element.doc['followingName'],
                  followerName: element.doc['followerName'],
                  followingImageLink: element.doc['followingImageLink'],
                  followerImageLink: element.doc['followerImageLink'],
                  followerNumber: element.doc['followerNumber'],
                  followingNumber: element.doc['followingNumber'],
                  lastMessage: element.doc['lastMessage'],
                  lastMessageTime: element.doc['lastMessageTime'],
                  isSeen: element.doc['isSeen']);
              _chatUserList.add(chatUsers);
            }
          });

          return _chatUserList;
        });
      });
      notifyListeners();
    } catch (error) {
      print(error.toString());
    }
  }

  Future<void> getFollowingChatUser(UserProvider userProvider) async {
    try {
      await userProvider.getCurrentMobileNo().then((value) async {
        await FirebaseFirestore.instance
            .collection('chatUsers')
            .where('followingNumber', isEqualTo: userProvider.currentUserMobile)
            .orderBy('lastMessageTime', descending: true)
            .get()
            .then((snapShot) {
          _chatUserList.clear();
          snapShot.docChanges.forEach((element) {
            ChatUserModel chatUsers = ChatUserModel(
                id: element.doc['id'],
                followingName: element.doc['followingName'],
                followerName: element.doc['followerName'],
                followingImageLink: element.doc['followingImageLink'],
                followerImageLink: element.doc['followerImageLink'],
                followerNumber: element.doc['followerNumber'],
                followingNumber: element.doc['followingNumber'],
                lastMessage: element.doc['lastMessage'],
                lastMessageTime: element.doc['lastMessageTime'],
                isSeen: element.doc['isSeen']);
            _followingChatUserList.add(chatUsers);
            _allChatUserList.add(chatUsers);
          });
          return _chatUserList;
        });
      });
      notifyListeners();
    } catch (error) {
      print(error.toString());
    }
  }

  Future<void> unfollow(String followerNumber, String followingNumber,
      UserProvider userProvider, int index) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(followerNumber)
        .collection('myFollowings')
        .doc(followingNumber)
        .get()
        .then((snapshot) async {
      if (snapshot.exists) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(followerNumber)
            .collection('myFollowings')
            .doc(followingNumber)
            .delete()
            .then((value) async {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(followingNumber)
              .collection('followers')
              .doc(followerNumber)
              .get()
              .then((value) async {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(followingNumber)
                .collection('follower')
                .doc(followerNumber)
                .delete()
                .then((value) async {
              await deleteChat(
                  followingNumber, followerNumber, userProvider, index);
              notifyListeners();
            });
          });
        });
      }
    });
  }

  Future<void> deleteChat(String followingNumber, String followerNumber,
      UserProvider userProvider, int index) async {
    await FirebaseFirestore.instance
        .collection('chatUsers')
        .doc(followerNumber + followingNumber)
        .delete()
        .then((value) async {
      _chatUserList.removeAt(index);
      await getAllChatUser(userProvider);
      notifyListeners();
    });
  }

  Future<void> removeMyFollowings(String currentMobileNo, String mobile) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentMobileNo)
          .collection('myFollowings')
          .doc(mobile)
          .delete();
      print('deleted object: $mobile');
    } catch (error) {
      print(
          'Cannot delete $mobile from myFollowings of $currentMobileNo = $error');
    }
  }

  Future<void> getUserFollowersNumber(String mobileNo) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(mobileNo)
        .collection('followers')
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      _userFollowersNumber = querySnapshot.docs.length;
    }
  }
}
