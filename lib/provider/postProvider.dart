import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:pet_lover/model/Notification.dart';
import 'package:pet_lover/model/chat_user_model.dart';
import 'package:pet_lover/model/follower.dart';
import 'package:pet_lover/model/followerDemo.dart';
import 'package:pet_lover/model/post.dart';
import 'package:pet_lover/provider/groupProvider.dart';
import 'package:pet_lover/provider/userProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class PostProvider extends ChangeNotifier {
  List<Post> _allPosts = [];
  List<ChatUserModel> _chatUserList = <ChatUserModel>[];
  List<Post> _userPosts = [];
  List<FollowerDemo> _followerList = [];
  List<FollowerDemo> _followingList = [];
  List<FollowerDemo> _peopleDemoList = [];
  List<Follower> _peopleList = [];
  List<Post> _allGroupPost = [];
  int documentLimit = 50;
  bool _hasNext = true;
  bool _isFetchingPost = false;
  DocumentSnapshot? _startAfter;
  List<Post> _searchedTokenList = [];
  List<Post> _animalList = [];
  List<Post> _favouriteList = [];
  int _numberOfMyAnimals = 0;
  int _otherUserAnimalNumber = 0;
  List<Post> _otherUserPosts = [];
  bool _hasFavouriteNext = true;
  bool _isFetchingFavourite = false;
  DocumentSnapshot? _favouriteStartAfter;
  bool _hasOtherUserPostNext = true;
  bool _isFetchingOtherUserPost = false;
  DocumentSnapshot? _otherUserPostStartAfter;
  List<Post> _myAnimals = [];
  bool _hasgroupPostNext = true;
  bool _isFetchingGroupPost = false;
  DocumentSnapshot? _groupPostStartAfter;
  List<MyNotification> _notificationList = [];
  List<Post> _specificPost = [];
  List<Post> _animalNameSearchList = [];
  int _totalNotifications = 0;
  bool _isVideoPlaying = true;
  bool _otherUserVideoPlaying = true;

  get allPosts => _allPosts;
  get chatUserList => _chatUserList;
  get userPosts => _userPosts;
  get followerList => _followerList;
  get followingList => _followingList;
  get peopleList => _peopleList;
  get allGroupPost => _allGroupPost;
  get hasNext => _hasNext;
  get searchedTokenList => _searchedTokenList;
  get animalList => _animalList;
  get favouriteList => _favouriteList;
  get numberOfMyAnimals => _numberOfMyAnimals;
  get otherUserAnimalNumber => _otherUserAnimalNumber;
  get otherUserPosts => _otherUserPosts;
  get hasFovouriteNext => _hasFavouriteNext;
  get myAnimals => _myAnimals;
  get notificationList => _notificationList;
  get specificPost => _specificPost;
  get animalNameSearchList => _animalNameSearchList;
  get totalNotifications => _totalNotifications;
  get isVideoPlaying => _isVideoPlaying;
  get otherUserVideoPlaying => _otherUserVideoPlaying;

  setVideoPlaying() {
    this._isVideoPlaying = false;
    notifyListeners();
  }

  setOtherUserVideoPlaying() {
    this._otherUserVideoPlaying = false;
    notifyListeners();
  }

  setSearchTokenListEmpty() {
    _searchedTokenList.clear();
  }

  Future<void> getAllPosts() async {
    _hasNext = true;
    if (_isFetchingPost) return;
    _isFetchingPost = true;
    try {
      _allPosts.clear();
      await FirebaseFirestore.instance
          .collection('allPosts')
          .orderBy('date', descending: true)
          .limit(documentLimit)
          .get()
          .then((snapshot) {
        _startAfter = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
        if (snapshot.docs.length < documentLimit) _hasNext = false;
        snapshot.docChanges.forEach((element) {
          Post post = Post(
              postId: element.doc['postId'],
              postOwnerId: element.doc['postOwnerId'],
              postOwnerMobileNo: element.doc['postOwnerMobileNo'],
              postOwnerName: element.doc['postOwnerName'],
              postOwnerImage: element.doc['postOwnerImage'],
              date: element.doc['date'],
              status: element.doc['status'],
              photo: element.doc['photo'],
              video: element.doc['video'],
              animalToken: element.doc['animalToken'],
              animalName: element.doc['animalName'],
              animalColor: element.doc['animalColor'],
              animalAge: element.doc['animalAge'],
              animalGender: element.doc['animalGender'],
              animalGenus: element.doc['animalGenus'],
              totalFollowers: element.doc['totalFollowers'],
              totalComments: element.doc['totalComments'],
              totalShares: element.doc['totalShares'],
              groupId: element.doc['groupId'],
              shareId: element.doc['shareId']);
          _allPosts.add(post);
          notifyListeners();
        });
      });
    } catch (error) {
      print('Fetching all posts from allPosts collection, failed: $error');
    }
    _isFetchingPost = false;
  }

  Future<void> getMorePosts() async {
    if (_isFetchingPost) return;
    _isFetchingPost = true;
    try {
      await FirebaseFirestore.instance
          .collection('allPosts')
          .orderBy('date', descending: true)
          .limit(documentLimit)
          .startAfterDocument(_startAfter!)
          .get()
          .then((snapshot) {
        _startAfter = snapshot.docs.last;
        if (snapshot.docs.length < documentLimit) _hasNext = false;
        snapshot.docChanges.forEach((element) {
          Post post = Post(
              postId: element.doc['postId'],
              postOwnerId: element.doc['postOwnerId'],
              postOwnerMobileNo: element.doc['postOwnerMobileNo'],
              postOwnerName: element.doc['postOwnerName'],
              postOwnerImage: element.doc['postOwnerImage'],
              date: element.doc['date'],
              status: element.doc['status'],
              photo: element.doc['photo'],
              video: element.doc['video'],
              animalToken: element.doc['animalToken'],
              animalName: element.doc['animalName'],
              animalColor: element.doc['animalColor'],
              animalAge: element.doc['animalAge'],
              animalGender: element.doc['animalGender'],
              animalGenus: element.doc['animalGenus'],
              totalFollowers: element.doc['totalFollowers'],
              totalComments: element.doc['totalComments'],
              totalShares: element.doc['totalShares'],
              groupId: element.doc['groupId'],
              shareId: element.doc['shareId']);
          _allPosts.add(post);
          notifyListeners();
        });
      });
    } catch (error) {
      print('Fetching more posts from allPosts collection, failed: $error');
    }
    _isFetchingPost = false;
  }

  Future<void> getAllChatUser(UserProvider userProvider) async {
    try {
      await FirebaseFirestore.instance
          .collection('chatUsers')
          .where('id', isEqualTo: userProvider.currentUserMobile)
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
          _chatUserList.add(chatUsers);
        });
        return _chatUserList;
      });
      notifyListeners();
    } catch (error) {
      print(error.toString());
    }
  }

  Future<void> setFollowingAndFollower(
    String currentMobileNo,
    String postOwnerId,
    String followingName,
    String followerName,
    String followingImage,
    String followerImage,
    String postId,
    UserProvider userProvider,
  ) async {
    try {
      final String notificationId = Uuid().v4();

      if (postOwnerId != currentMobileNo) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentMobileNo)
            .collection('myFollowings')
            .doc(postOwnerId)
            .set({'id': postOwnerId}).then((value) async {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentMobileNo)
              .collection('followers')
              .doc(postOwnerId)
              .get()
              .then((snapshot) async {
            if (!snapshot.exists) {
              await FirebaseFirestore.instance
                  .collection('chatUsers')
                  .doc(currentMobileNo + postOwnerId)
                  .set({
                'id': currentMobileNo,
                'followingName': followingName,
                'followerName': followerName,
                'followingImageLink': followingImage,
                'followerImageLink': followerImage,
                'followerNumber': currentMobileNo,
                'followingNumber': postOwnerId,
                'lastMessage': 'You can now chat with this animal owner',
                'lastMessageTime': Timestamp.now(),
                'isSeen': false
              }).then((value) async {
                await getAllChatUser(userProvider);
              });
            }
          });
        });
        await FirebaseFirestore.instance
            .collection('users')
            .doc(postOwnerId)
            .collection('followers')
            .doc(currentMobileNo)
            .set({'id': currentMobileNo});
      }
    } catch (error) {
      print('Cannot add in followings ... error = $error');
    }
  }

  Future<void> addFollowers(
    String postId,
    String _currentMobileNo,
    String postOwnerId,
    String followingName,
    String followerName,
    int? allPostIndex,
    int? groupIndex,
    int? favouriteIndex,
    int? myPostIndex,
    int? otherUserPostIndex,
    int? specificPostIndex,
  ) async {
    Map<String, String> followers = {'id': _currentMobileNo};

    try {
      final String notificationId = Uuid().v4();
      await FirebaseFirestore.instance
          .collection('allPosts')
          .doc(postId)
          .collection('followers')
          .doc(_currentMobileNo)
          .set(followers)
          .then((value) async {
        if (postOwnerId != _currentMobileNo) {
          await FirebaseFirestore.instance
              .collection('Notifications')
              .doc(notificationId)
              .set({
            'notificationId': notificationId,
            'date': DateTime.now().millisecondsSinceEpoch.toString(),
            'senderId': _currentMobileNo,
            'receiverId': postOwnerId,
            'title': 'Animal Society',
            'body': '$followerName react on your post',
            'senderName': followerName,
            'receiverName': followingName,
            'status': 'unclicked',
            'postId': postId,
            'groupId': ''
          });
        }
      });

      int totalFollowers = 0;
      await FirebaseFirestore.instance
          .collection('allPosts')
          .doc(postId)
          .collection('followers')
          .get()
          .then((snapshot) async {
        if (snapshot.docs.length != 0) {
          totalFollowers = snapshot.docs.length;
          await FirebaseFirestore.instance
              .collection('allPosts')
              .doc(postId)
              .update({'totalFollowers': totalFollowers.toString()}).then(
                  (value) async {
            await FirebaseFirestore.instance
                .collection('allPosts')
                .doc(postId)
                .get()
                .then((snapshot) {
              if (allPostIndex != null) {
                _allPosts[allPostIndex].totalFollowers =
                    snapshot['totalFollowers'];
                notifyListeners();
              }
              if (groupIndex != null) {
                _allGroupPost[groupIndex].totalFollowers =
                    snapshot['totalFollowers'];
                notifyListeners();
              }
              if (favouriteIndex != null) {
                print('favourite list index = $favouriteIndex');
                _favouriteList[favouriteIndex].totalFollowers =
                    snapshot['totalFollowers'];
                notifyListeners();
              }
              if (myPostIndex != null) {
                _userPosts[myPostIndex].totalFollowers =
                    snapshot['totalFollowers'];
                notifyListeners();
              }

              if (otherUserPostIndex != null) {
                _otherUserPosts[otherUserPostIndex].totalFollowers =
                    snapshot['totalFollowers'];
                notifyListeners();
              }

              if (specificPostIndex != null) {
                _specificPost[specificPostIndex].totalFollowers =
                    snapshot['totalFollowers'];
              }
            });
          });
        }
      });
    } catch (error) {
      print('Adding followers error = $error');
    }
  }

  Future<void> removeFollower(String postId, String _currentMobileNo,
      int? allPostIndex, int? groupIndex, int? favouriteIndex) async {
    try {
      await FirebaseFirestore.instance
          .collection('allPosts')
          .doc(postId)
          .collection('followers')
          .doc(_currentMobileNo)
          .delete()
          .then((value) async {
        int totalFollowers = 0;
        await FirebaseFirestore.instance
            .collection('allPosts')
            .doc(postId)
            .collection('followers')
            .get()
            .then((snapshot) async {
          totalFollowers = snapshot.docs.length;
          await FirebaseFirestore.instance
              .collection('allPosts')
              .doc(postId)
              .update({'totalFollowers': totalFollowers.toString()}).then(
                  (value) async {
            await FirebaseFirestore.instance
                .collection('allPosts')
                .doc(postId)
                .get()
                .then((snapshot) {
              if (allPostIndex != null) {
                _allPosts[allPostIndex].totalFollowers =
                    snapshot['totalFollowers'];
              }
              if (groupIndex != null) {
                _allGroupPost[groupIndex].totalFollowers =
                    snapshot['totalFollowers'];
              }
              if (favouriteIndex != null) {
                _favouriteList[favouriteIndex].totalFollowers =
                    snapshot['totalFollowers'];
              }

              print('${snapshot['totalFollowers']}');
              notifyListeners();
            });
          });
        });
      });
    } catch (error) {
      print('Cannot delete follower - $error');
    }
  }

  Future<void> addComment(
      String postOwnerName,
      String currentUsername,
      String postId,
      String commentId,
      String comment,
      String postOwnerId,
      String currentUserMobileNo,
      String date,
      int? allPostIndex,
      int? groupIndex,
      int? favouriteIndex,
      int? myPostIndex,
      int? otherUserPostIndex,
      int? specificPostIndex) async {
    try {
      final String notificationId = Uuid().v4();
      await FirebaseFirestore.instance
          .collection('allPosts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .set({
        'commentId': commentId,
        'comment': comment,
        'date': date,
        'postOwnerId': postOwnerId,
        'commenter': currentUserMobileNo,
        'postId': postId
      }).then((value) async {
        if (postOwnerId != currentUserMobileNo) {
          await FirebaseFirestore.instance
              .collection('Notifications')
              .doc(notificationId)
              .set({
            'notificationId': notificationId,
            'date': DateTime.now().millisecondsSinceEpoch.toString(),
            'senderId': currentUserMobileNo,
            'receiverId': postOwnerId,
            'title': 'Animal Society',
            'body': '$currentUsername commented on your post',
            'senderName': currentUsername,
            'receiverName': postOwnerName,
            'status': 'unclicked',
            'postId': postId,
            'groupId': ''
          });
        }
      });

      int totalComments = 0;
      await FirebaseFirestore.instance
          .collection('allPosts')
          .doc(postId)
          .collection('comments')
          .get()
          .then((snapshot) async {
        if (snapshot.docs.length != 0) {
          totalComments = snapshot.docs.length;
          await FirebaseFirestore.instance
              .collection('allPosts')
              .doc(postId)
              .update({'totalComments': totalComments.toString()}).then(
                  (value) async {
            await FirebaseFirestore.instance
                .collection('allPosts')
                .doc(postId)
                .get()
                .then((snapshot) {
              if (allPostIndex != null) {
                _allPosts[allPostIndex].totalComments =
                    snapshot['totalComments'];
                notifyListeners();

                print(
                    'allPost comments now = ${_allPosts[allPostIndex].totalComments}');
              }

              if (groupIndex != null) {
                _allGroupPost[groupIndex].totalComments =
                    snapshot['totalComments'];
                notifyListeners();
                print(
                    'groupPost comments now = ${_allGroupPost[groupIndex].totalComments}');
              }

              if (favouriteIndex != null) {
                _favouriteList[favouriteIndex].totalComments =
                    snapshot['totalComments'];
                notifyListeners();
                print(
                    'favourite comments now = ${_favouriteList[favouriteIndex].totalComments}');
              }

              if (myPostIndex != null) {
                _userPosts[myPostIndex].totalComments =
                    snapshot['totalComments'];
                notifyListeners();
                print(
                    'userPost comments now = ${_userPosts[myPostIndex].totalComments}');
              }

              if (otherUserPostIndex != null) {
                _otherUserPosts[otherUserPostIndex].totalComments =
                    snapshot['totalComments'];
                notifyListeners();
              }

              if (specificPostIndex != null) {
                _specificPost[specificPostIndex].totalComments =
                    snapshot['totalComments'];
                notifyListeners();
              }
            });
          });
        }
      });
    } catch (error) {
      print('Add comment failed: $error');
    }
  }

  Future<void> editComment(
      String postId, String commentId, String newComment) async {
    await FirebaseFirestore.instance
        .collection('allPosts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .update({
      'comment': newComment,
    });
  }

  Future<void> deleteComment(
      String postId,
      String commentId,
      int? allPostIndex,
      int? groupIndex,
      int? favouriteIndex,
      int? myPostIndex,
      int? otherUserPostIndex) async {
    await FirebaseFirestore.instance
        .collection('allPosts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .delete()
        .then((value) async {
      int totalComments = 0;
      await FirebaseFirestore.instance
          .collection('allPosts')
          .doc(postId)
          .collection('comments')
          .get()
          .then((snapshot) async {
        totalComments = snapshot.docs.length;
        await FirebaseFirestore.instance
            .collection('allPosts')
            .doc(postId)
            .update({'totalComments': totalComments.toString()});
      }).then((value) async {
        await FirebaseFirestore.instance
            .collection('allPosts')
            .doc(postId)
            .get()
            .then((snapshot) {
          if (allPostIndex != null) {
            _allPosts[allPostIndex].totalComments = snapshot['totalComments'];
          }
          if (groupIndex != null) {
            _allGroupPost[groupIndex].totalComments = snapshot['totalComments'];
          }
          if (favouriteIndex != null) {
            _favouriteList[favouriteIndex].totalComments =
                snapshot['totalComments'];
          }
          if (myPostIndex != null) {
            _userPosts[myPostIndex].totalComments = snapshot['totalComments'];
          }
          if (otherUserPostIndex != null) {
            _otherUserPosts[otherUserPostIndex].totalComments =
                snapshot['totalComments'];
          }
        });
      });
    });

    notifyListeners();
  }

  Future<void> getMyAnimalsNumber(UserProvider userProvider) async {
    _numberOfMyAnimals = 0;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userProvider.currentUserMobile)
        .collection('myAnimals')
        .get()
        .then((snapshot) {
      if (snapshot.docs.length != 0) {
        _numberOfMyAnimals = snapshot.docs.length;
        notifyListeners();
      }
    });
  }

  Future<void> getOtherUserAnimalsNumber(String userId) async {
    _otherUserAnimalNumber = 0;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('myAnimals')
        .get()
        .then((snapshot) {
      if (snapshot.docs.length != 0) {
        _otherUserAnimalNumber = snapshot.docs.length;
        notifyListeners();
      }
    });
  }

  Future<void> setTotalShares(
      String postId,
      int? allPostIndex,
      int? groupPostIndex,
      int? favouriteIndex,
      int? myPostIndex,
      int? otherUserPostIndex,
      UserProvider userProvider) async {
    String totalShares = '';
    await FirebaseFirestore.instance
        .collection('allPosts')
        .doc(postId)
        .get()
        .then((snapshot) async {
      totalShares = snapshot['totalShares'];
      if (allPostIndex != null) {
        _allPosts[allPostIndex].totalShares = totalShares;
      }

      if (groupPostIndex != null) {
        _allGroupPost[groupPostIndex].totalShares = totalShares;
      }

      if (favouriteIndex != null) {
        _favouriteList[favouriteIndex].totalShares = totalShares;
      }

      if (myPostIndex != null) {
        _userPosts[myPostIndex].totalShares = totalShares;
      }

      if (otherUserPostIndex != null) {
        _otherUserPosts[otherUserPostIndex].totalShares = totalShares;
      }
      notifyListeners();
    });
  }

  Future<void> getUserPosts(String userId) async {
    try {
      _userPosts.clear();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('myPosts')
          .orderBy('date', descending: true)
          .get()
          .then((snapshot) {
        snapshot.docChanges.forEach((element) async {
          await FirebaseFirestore.instance
              .collection('allPosts')
              .doc(element.doc['postId'])
              .get()
              .then((snapshot) {
            Post post = Post(
                postId: snapshot['postId'],
                postOwnerId: snapshot['postOwnerId'],
                postOwnerMobileNo: snapshot['postOwnerMobileNo'],
                postOwnerName: snapshot['postOwnerName'],
                postOwnerImage: snapshot['postOwnerImage'],
                date: snapshot['date'],
                status: snapshot['status'],
                photo: snapshot['photo'],
                video: snapshot['video'],
                animalToken: snapshot['animalToken'],
                animalName: snapshot['animalName'],
                animalColor: snapshot['animalColor'],
                animalAge: snapshot['animalAge'],
                animalGender: snapshot['animalGender'],
                animalGenus: snapshot['animalGenus'],
                totalFollowers: snapshot['totalFollowers'],
                totalComments: snapshot['totalComments'],
                totalShares: snapshot['totalShares'],
                groupId: snapshot['groupId'],
                shareId: snapshot['shareId']);
            _userPosts.add(post);
            notifyListeners();
          });
        });
      });
    } catch (error) {
      print('Fetching user posts from myPosts collection, failed: $error');
    }
  }

  Future<void> getOtherUserPosts(String userId) async {
    _hasOtherUserPostNext = true;
    if (_isFetchingOtherUserPost) return;
    _isFetchingOtherUserPost = true;

    try {
      _otherUserPosts.clear();
      await FirebaseFirestore.instance
          .collection('allPosts')
          .where('postOwnerId', isEqualTo: userId)
          .limit(documentLimit)
          .get()
          .then((value) {
        _otherUserPostStartAfter =
            value.docs.isNotEmpty ? value.docs.last : null;
        if (value.docs.length < documentLimit) _hasOtherUserPostNext = false;
        value.docChanges.forEach((element) {
          Post post = Post(
              postId: element.doc['postId'],
              postOwnerId: element.doc['postOwnerId'],
              postOwnerMobileNo: element.doc['postOwnerMobileNo'],
              postOwnerName: element.doc['postOwnerName'],
              postOwnerImage: element.doc['postOwnerImage'],
              date: element.doc['date'],
              status: element.doc['status'],
              photo: element.doc['photo'],
              video: element.doc['video'],
              animalToken: element.doc['animalToken'],
              animalName: element.doc['animalName'],
              animalColor: element.doc['animalColor'],
              animalAge: element.doc['animalAge'],
              animalGender: element.doc['animalGender'],
              animalGenus: element.doc['animalGenus'],
              totalFollowers: element.doc['totalFollowers'],
              totalComments: element.doc['totalComments'],
              totalShares: element.doc['totalShares'],
              groupId: element.doc['groupId'],
              shareId: element.doc['shareId']);
          _otherUserPosts.add(post);
          notifyListeners();
        });
      });
    } catch (error) {
      print('Fetching user posts from myPosts collection, failed: $error');
    }
    _isFetchingOtherUserPost = false;
  }

  Future<void> getOtherUserMorePosts(String userId) async {
    if (_isFetchingOtherUserPost) return;
    _isFetchingOtherUserPost = true;

    try {
      await FirebaseFirestore.instance
          .collection('allPosts')
          .where('postOwnerId', isEqualTo: userId)
          .limit(documentLimit)
          .startAfterDocument(_otherUserPostStartAfter!)
          .get()
          .then((value) {
        _otherUserPostStartAfter =
            value.docs.isNotEmpty ? value.docs.last : null;
        if (value.docs.length < documentLimit) _hasOtherUserPostNext = false;
        value.docChanges.forEach((element) {
          Post post = Post(
              postId: element.doc['postId'],
              postOwnerId: element.doc['postOwnerId'],
              postOwnerMobileNo: element.doc['postOwnerMobileNo'],
              postOwnerName: element.doc['postOwnerName'],
              postOwnerImage: element.doc['postOwnerImage'],
              date: element.doc['date'],
              status: element.doc['status'],
              photo: element.doc['photo'],
              video: element.doc['video'],
              animalToken: element.doc['animalToken'],
              animalName: element.doc['animalName'],
              animalColor: element.doc['animalColor'],
              animalAge: element.doc['animalAge'],
              animalGender: element.doc['animalGender'],
              animalGenus: element.doc['animalGenus'],
              totalFollowers: element.doc['totalFollowers'],
              totalComments: element.doc['totalComments'],
              totalShares: element.doc['totalShares'],
              groupId: element.doc['groupId'],
              shareId: element.doc['shareId']);
          _otherUserPosts.add(post);
          notifyListeners();
        });
      });
    } catch (error) {
      print('Fetching user posts from myPosts collection, failed: $error');
    }
    _isFetchingOtherUserPost = false;
  }

  Future<void> makeOtherUserPostListEmpty() async {
    _otherUserPosts.clear();
  }

  Future<void> getAllFollowers(String userId) async {
    _followerList.clear();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('followers')
        .get()
        .then((value) {
      value.docChanges.forEach((element) {
        FollowerDemo follower = FollowerDemo(id: element.doc['id']);
        _followerList.add(follower);
      });
    });
  }

  Future<void> getAllFollowings(String userId) async {
    _followingList.clear();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('myFollowings')
        .get()
        .then((value) {
      value.docChanges.forEach((element) {
        FollowerDemo following = FollowerDemo(id: element.doc['id']);
        _followingList.add(following);
      });
    });
  }

  Future<void> getPeopleList(
    String userId,
    UserProvider userProvider,
    GroupProvider groupProvider,
    String groupId,
  ) async {
    _peopleList.clear();
    _peopleDemoList.clear();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('myFollowings')
        .get()
        .then((value) {
      value.docChanges.forEach((element) async {
        String id = element.doc['id'];
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('followers')
            .doc(id)
            .get()
            .then((value) {
          if (!value.exists) {
            FollowerDemo followerDemo = FollowerDemo(id: id);
            _peopleDemoList.add(followerDemo);
            notifyListeners();
          }
        });
      });
    }).then((value) async {
      await getAllFollowers(userId).then((value) {
        _peopleDemoList.addAll(_followerList);
      });
    }).then((value) async {
      for (int i = 0; i < _peopleDemoList.length; i++) {
        String id = _peopleDemoList[i].id;

        await FirebaseFirestore.instance
            .collection('Groups')
            .doc(groupId)
            .collection('members')
            .doc(id)
            .get()
            .then((snapshot) async {
          if (!snapshot.exists) {
            await userProvider.getSpecificUserInfo(id).then((value) {
              Follower people = Follower(
                  mobileNo: userProvider.specificUserMap['mobileNo'],
                  name: userProvider.specificUserMap['username'],
                  photo: userProvider.specificUserMap['profileImageLink']);
              _peopleList.add(people);
              notifyListeners();
            });
          }
        });
      }
    });

    print(' people list length = ${_peopleList.length}');
  }

  Future<void> addMember(
      String groupId,
      String mobileNo,
      String date,
      UserProvider userProvider,
      int index,
      PostProvider postProvider,
      GroupProvider groupProvider) async {
    try {
      await userProvider.getSpecificUserInfo(mobileNo).then((value) async {
        String receiverName = userProvider.specificUserMap['username'];
        groupProvider.getGroupInfo(groupId);
        Map<String, String> userInfo = {};
        DocumentReference groupMembersRef = FirebaseFirestore.instance
            .collection('Groups')
            .doc(groupId)
            .collection('members')
            .doc(mobileNo);

        DocumentReference myGroups = FirebaseFirestore.instance
            .collection('users')
            .doc(mobileNo)
            .collection('myGroups')
            .doc(groupId);

        await myGroups.set({
          'groupName': groupProvider.groupInfo['groupName'],
          'groupImage': groupProvider.groupInfo['groupImage'],
          'date': date,
          'admin': groupProvider.groupInfo['admin'],
          'id': groupId,
          'privacy': groupProvider.groupInfo['privacy'],
          'description': groupProvider.groupInfo['description'],
          'myRole': 'member'
        }).then((value) async {
          final String notificationId = Uuid().v4();
          await FirebaseFirestore.instance
              .collection('Notifications')
              .doc(notificationId)
              .set({
            'notificationId': notificationId,
            'date': DateTime.now().millisecondsSinceEpoch.toString(),
            'senderId': userProvider.currentUserMap['mobileNo'],
            'receiverId': mobileNo,
            'title': 'Notification from Animal Society',
            'body':
                '${userProvider.currentUserMap['username']} added you in ${groupProvider.groupInfo['groupName']}',
            'senderName': userProvider.currentUserMap['username'],
            'receiverName': receiverName,
            'status': 'unclicked',
            'postId': '',
            'groupId': groupId
          });
        });

        await userProvider.getSpecificUserInfo(mobileNo).then((value) {
          userInfo = userProvider.specificUserMap;
        });

        await groupMembersRef.set({
          'date': date,
          'mobileNo': mobileNo,
          'profileImageLink': userInfo['profileImageLink'],
          'username': userInfo['username'],
          'memberRole': 'member'
        }).then((value) async {
          await groupProvider.getAllMembers(groupId).then((value) {
            print(
                'After adding total groupMembers = ${groupProvider.members.length}');
            _peopleList.removeAt(index);
            notifyListeners();
          });
        });
      });
    } catch (error) {
      print('Adding member in group failed - $error');
    }
  }

  Future<void> getAllGroupPosts(String groupId) async {
    _hasgroupPostNext = true;
    if (_isFetchingGroupPost) return;
    _isFetchingGroupPost = true;
    try {
      _allGroupPost.clear();
      await FirebaseFirestore.instance
          .collection('Groups')
          .doc(groupId)
          .collection('groupPosts')
          .orderBy('date', descending: true)
          .limit(documentLimit)
          .get()
          .then((snapshot) {
        _groupPostStartAfter =
            snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
        if (snapshot.docs.length < documentLimit) _hasgroupPostNext = false;
        snapshot.docChanges.forEach((element) async {
          String postId = element.doc['postId'];
          await FirebaseFirestore.instance
              .collection('allPosts')
              .doc(postId)
              .get()
              .then((snapshot) {
            Post post = Post(
                postId: snapshot['postId'],
                postOwnerId: snapshot['postOwnerId'],
                postOwnerMobileNo: snapshot['postOwnerMobileNo'],
                postOwnerName: snapshot['postOwnerName'],
                postOwnerImage: snapshot['postOwnerImage'],
                date: snapshot['date'],
                status: snapshot['status'],
                photo: snapshot['photo'],
                video: snapshot['video'],
                animalToken: snapshot['animalToken'],
                animalName: snapshot['animalName'],
                animalColor: snapshot['animalColor'],
                animalAge: snapshot['animalAge'],
                animalGender: snapshot['animalGender'],
                animalGenus: snapshot['animalGenus'],
                totalFollowers: snapshot['totalFollowers'],
                totalComments: snapshot['totalComments'],
                totalShares: snapshot['totalShares'],
                groupId: snapshot['groupId'],
                shareId: snapshot['shareId']);
            _allGroupPost.add(post);
            notifyListeners();
          });
        });
      });
    } catch (error) {
      print(
          'Fetching all group posts from groupPosts collection, failed: $error');
    }
    _isFetchingGroupPost = false;
  }

  Future<void> getMoreGroupPosts(String groupId) async {
    if (_isFetchingGroupPost) return;
    _isFetchingGroupPost = true;
    try {
      await FirebaseFirestore.instance
          .collection('Groups')
          .doc(groupId)
          .collection('groupPosts')
          .orderBy('date', descending: true)
          .limit(documentLimit)
          .startAfterDocument(_groupPostStartAfter!)
          .get()
          .then((snapshot) {
        _groupPostStartAfter =
            snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
        if (snapshot.docs.length < documentLimit) _hasgroupPostNext = false;
        snapshot.docChanges.forEach((element) async {
          String postId = element.doc['postId'];
          await FirebaseFirestore.instance
              .collection('allPosts')
              .doc(postId)
              .get()
              .then((snapshot) {
            Post post = Post(
                postId: snapshot['postId'],
                postOwnerId: snapshot['postOwnerId'],
                postOwnerMobileNo: snapshot['postOwnerMobileNo'],
                postOwnerName: snapshot['postOwnerName'],
                postOwnerImage: snapshot['postOwnerImage'],
                date: snapshot['date'],
                status: snapshot['status'],
                photo: snapshot['photo'],
                video: snapshot['video'],
                animalToken: snapshot['animalToken'],
                animalName: snapshot['animalName'],
                animalColor: snapshot['animalColor'],
                animalAge: snapshot['animalAge'],
                animalGender: snapshot['animalGender'],
                animalGenus: snapshot['animalGenus'],
                totalFollowers: snapshot['totalFollowers'],
                totalComments: snapshot['totalComments'],
                totalShares: snapshot['totalShares'],
                groupId: snapshot['groupId'],
                shareId: snapshot['shareId']);
            _allGroupPost.add(post);
            notifyListeners();
          });
        });
      });
    } catch (error) {
      print(
          'Fetching all group posts from groupPosts collection, failed: $error');
    }
    _isFetchingGroupPost = false;
  }

  Future<void> deletePost(String photo, String postId, String animalToken,
      String userId, int index) async {
    print('index = $index');
    print('userlist = ${_userPosts.length}');

    print('userlist = ${_userPosts.length}');
    if (photo != '') {
      Reference storageRef = FirebaseStorage.instance.refFromURL(photo);
      await storageRef.delete();
    }
    await FirebaseFirestore.instance
        .collection('allPosts')
        .doc(postId)
        .delete();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('myPosts')
        .doc(postId)
        .delete();

    if (animalToken != '') {
      await FirebaseFirestore.instance
          .collection('Animals')
          .doc(animalToken)
          .delete();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('myAnimals')
          .doc(animalToken)
          .delete()
          .then((value) {
        _userPosts.removeAt(index);
      });
    }
    // getUserPosts(userId);
    // getAllPosts();
    notifyListeners();
  }

  Future<void> deleteHomePost(String photo, String postId, String animalToken,
      String userId, int index) async {
    print('index = $index');
    print('userlist = ${_userPosts.length}');

    print('userlist = ${_userPosts.length}');
    if (photo != '') {
      Reference storageRef = FirebaseStorage.instance.refFromURL(photo);
      await storageRef.delete();
    }
    await FirebaseFirestore.instance
        .collection('allPosts')
        .doc(postId)
        .delete();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('myPosts')
        .doc(postId)
        .delete();

    if (animalToken != '') {
      await FirebaseFirestore.instance
          .collection('Animals')
          .doc(animalToken)
          .delete();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('myAnimals')
          .doc(animalToken)
          .delete()
          .then((value) {
        _allPosts.removeAt(index);
      });
    }
    // getUserPosts(userId);
    // getAllPosts();
    notifyListeners();
  }

  Future<void> deleteGroupPost(
      String photo, String postId, String groupId, int index) async {
    if (photo != '') {
      Reference storageRef = FirebaseStorage.instance.refFromURL(photo);
      await storageRef.delete();
    }
    await FirebaseFirestore.instance
        .collection('allPosts')
        .doc(postId)
        .delete()
        .then((value) async {
      await FirebaseFirestore.instance
          .collection('Groups')
          .doc(groupId)
          .collection('groupPosts')
          .doc(postId)
          .delete()
          .then((value) async {
        _allGroupPost.removeAt(index);
      });
    });

    notifyListeners();
  }

  Future<bool> searchToken(String token, UserProvider userProvider) async {
    try {
      _searchedTokenList.clear();
      await FirebaseFirestore.instance
          .collection('allPosts')
          .where('animalToken', isEqualTo: token)
          .get()
          .then((snapshot) {
        snapshot.docChanges.forEach((element) async {
          if (element.doc['shareId'] == '') {
            Post post = Post(
                postId: element.doc['postId'],
                postOwnerId: element.doc['postOwnerId'],
                postOwnerMobileNo: element.doc['postOwnerMobileNo'],
                postOwnerName: element.doc['postOwnerName'],
                postOwnerImage: element.doc['postOwnerImage'],
                date: element.doc['date'],
                status: element.doc['status'],
                photo: element.doc['photo'],
                video: element.doc['video'],
                animalToken: element.doc['animalToken'],
                animalName: element.doc['animalName'],
                animalColor: element.doc['animalColor'],
                animalAge: element.doc['animalAge'],
                animalGender: element.doc['animalGender'],
                animalGenus: element.doc['animalGenus'],
                totalFollowers: element.doc['totalFollowers'],
                totalComments: element.doc['totalComments'],
                totalShares: element.doc['totalShares'],
                groupId: element.doc['groupId'],
                shareId: element.doc['shareId']);
            _searchedTokenList.add(post);
          }
        });
      });
      // await FirebaseFirestore.instance
      //     .collection('Animals')
      //     .doc(token)
      //     .get()
      //     .then((snapshot) async {
      //   if (snapshot.exists) {
      //     String postId = snapshot['postId'];
      //     await userProvider
      //         .getSpecificUserInfo(snapshot['postOwnerId'])
      //         .then((value) async {
      //       await FirebaseFirestore.instance
      //           .collection('allPosts')
      //           .doc(postId)
      //           .get()
      //           .then((snapshot2) {
      //         Post post = Post(
      //             postId: snapshot2['postId'],
      //             postOwnerId: snapshot2['postOwnerId'],
      //             postOwnerMobileNo: snapshot2['postOwnerMobileNo'],
      //             postOwnerName: snapshot2['postOwnerName'],
      //             postOwnerImage: snapshot2['postOwnerImage'],
      //             date: snapshot2['date'],
      //             status: snapshot2['status'],
      //             photo: snapshot2['photo'],
      //             video: snapshot2['video'],
      //             animalToken: snapshot2['animalToken'],
      //             animalName: snapshot2['animalName'],
      //             animalColor: snapshot2['animalColor'],
      //             animalAge: snapshot2['animalAge'],
      //             animalGender: snapshot2['animalGender'],
      //             animalGenus: snapshot2['animalGenus'],
      //             totalFollowers: snapshot2['totalFollowers'],
      //             totalComments: snapshot2['totalComments'],
      //             totalShares: snapshot2['totalShares'],
      //             groupId: snapshot2['groupId'],
      //             shareId: snapshot2['shareId']);
      //         _searchedTokenList.add(post);
      //         notifyListeners();
      //       });
      //     });
      //   }
      // });
      notifyListeners();
      return true;
    } catch (error) {
      print('No such token');
      return false;
    }
  }

  Future<bool> getAllAnimals() async {
    try {
      _animalList.clear();
      await FirebaseFirestore.instance
          .collection('allPosts')
          .orderBy('date', descending: true)
          .get()
          .then((snapshot) {
        snapshot.docChanges.forEach((element) async {
          Post post = Post(
              postId: element.doc['postId'],
              postOwnerId: element.doc['postOwnerId'],
              postOwnerMobileNo: element.doc['postOwnerMobileNo'],
              postOwnerName: element.doc['postOwnerName'],
              postOwnerImage: element.doc['postOwnerImage'],
              date: element.doc['date'],
              status: element.doc['status'],
              photo: element.doc['photo'],
              video: element.doc['video'],
              animalToken: element.doc['animalToken'],
              animalName: element.doc['animalName'],
              animalColor: element.doc['animalColor'],
              animalAge: element.doc['animalAge'],
              animalGender: element.doc['animalGender'],
              animalGenus: element.doc['animalGenus'],
              totalFollowers: element.doc['totalFollowers'],
              totalComments: element.doc['totalComments'],
              totalShares: element.doc['totalShares'],
              groupId: element.doc['groupId'],
              shareId: element.doc['shareId']);
          _animalList.add(post);
        });
      });
      return true;
    } catch (error) {
      print('Fetching animals error - $error');
      return false;
    }
  }

  Future<void> getFavourites(UserProvider userProvider) async {
    _hasFavouriteNext = true;
    if (_isFetchingFavourite) return;
    _isFetchingFavourite = true;
    try {
      print('getFavourite running');
      _favouriteList.clear();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userProvider.currentUserMobile)
          .collection('myFollowings')
          .get()
          .then((snapshot) async {
        snapshot.docChanges.forEach((element) async {
          String id = element.doc['id'];

          await FirebaseFirestore.instance
              .collection('allPosts')
              .where('postOwnerMobileNo', isEqualTo: id)
              .limit(documentLimit)
              .get()
              .then((value) {
            _favouriteStartAfter =
                value.docs.isNotEmpty ? value.docs.last : null;
            if (value.docs.length < documentLimit) _hasFavouriteNext = false;
            value.docChanges.forEach((element) {
              if (element.doc['animalToken'] != '') {
                Post post = Post(
                    postId: element.doc['postId'],
                    postOwnerId: element.doc['postOwnerId'],
                    postOwnerMobileNo: element.doc['postOwnerMobileNo'],
                    postOwnerName: element.doc['postOwnerName'],
                    postOwnerImage: element.doc['postOwnerImage'],
                    date: element.doc['date'],
                    status: element.doc['status'],
                    photo: element.doc['photo'],
                    video: element.doc['video'],
                    animalToken: element.doc['animalToken'],
                    animalName: element.doc['animalName'],
                    animalColor: element.doc['animalColor'],
                    animalAge: element.doc['animalAge'],
                    animalGender: element.doc['animalGender'],
                    animalGenus: element.doc['animalGenus'],
                    totalFollowers: element.doc['totalFollowers'],
                    totalComments: element.doc['totalComments'],
                    totalShares: element.doc['totalShares'],
                    groupId: element.doc['groupId'],
                    shareId: element.doc['shareId']);
                _favouriteList.add(post);
                notifyListeners();
              }
            });
          });
        });
      });
    } catch (error) {
      print('Getting favourites error - $error');
    }
    _isFetchingFavourite = false;
  }

  Future<void> getMoreFavourites(UserProvider userProvider) async {
    if (_isFetchingFavourite) return;
    _isFetchingFavourite = true;
    try {
      print('getFavourite running');
      _favouriteList.clear();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userProvider.currentUserMobile)
          .collection('myFollowings')
          .get()
          .then((snapshot) async {
        snapshot.docChanges.forEach((element) async {
          String id = element.doc['id'];

          await FirebaseFirestore.instance
              .collection('allPosts')
              .where('postOwnerMobileNo', isEqualTo: id)
              .limit(documentLimit)
              .startAfterDocument(_favouriteStartAfter!)
              .get()
              .then((value) {
            _favouriteStartAfter =
                value.docs.isNotEmpty ? value.docs.last : null;
            if (value.docs.length < documentLimit) _hasFavouriteNext = false;
            value.docChanges.forEach((element) {
              if (element.doc['animalToken'] != '') {
                Post post = Post(
                    postId: element.doc['postId'],
                    postOwnerId: element.doc['postOwnerId'],
                    postOwnerMobileNo: element.doc['postOwnerMobileNo'],
                    postOwnerName: element.doc['postOwnerName'],
                    postOwnerImage: element.doc['postOwnerImage'],
                    date: element.doc['date'],
                    status: element.doc['status'],
                    photo: element.doc['photo'],
                    video: element.doc['video'],
                    animalToken: element.doc['animalToken'],
                    animalName: element.doc['animalName'],
                    animalColor: element.doc['animalColor'],
                    animalAge: element.doc['animalAge'],
                    animalGender: element.doc['animalGender'],
                    animalGenus: element.doc['animalGenus'],
                    totalFollowers: element.doc['totalFollowers'],
                    totalComments: element.doc['totalComments'],
                    totalShares: element.doc['totalShares'],
                    groupId: element.doc['groupId'],
                    shareId: element.doc['shareId']);
                _favouriteList.add(post);
                notifyListeners();
              }
            });
          });
        });
      });
    } catch (error) {
      print('Getting favourites error - $error');
    }
    _isFetchingFavourite = false;
  }

  Future<void> getAllMyAnimals(UserProvider userProvider) async {
    _myAnimals.clear();
    await FirebaseFirestore.instance
        .collection('Animals')
        .where('postOwnerId', isEqualTo: userProvider.currentUserMobile)
        .get()
        .then((value) async {
      value.docChanges.forEach((element) async {
        String postId = element.doc['postId'];
        print('the post id = $postId');
        await FirebaseFirestore.instance
            .collection('allPosts')
            .doc(postId)
            .get()
            .then((snapshot) {
          Post post = Post(
              postId: snapshot['postId'],
              postOwnerId: snapshot['postOwnerId'],
              postOwnerMobileNo: snapshot['postOwnerMobileNo'],
              postOwnerName: snapshot['postOwnerName'],
              postOwnerImage: snapshot['postOwnerImage'],
              date: snapshot['date'],
              status: snapshot['status'],
              photo: snapshot['photo'],
              video: snapshot['video'],
              animalToken: snapshot['animalToken'],
              animalName: snapshot['animalName'],
              animalColor: snapshot['animalColor'],
              animalAge: snapshot['animalAge'],
              animalGender: snapshot['animalGender'],
              animalGenus: snapshot['animalGenus'],
              totalFollowers: snapshot['totalFollowers'],
              totalComments: snapshot['totalComments'],
              totalShares: snapshot['totalShares'],
              groupId: snapshot['groupId'],
              shareId: snapshot['shareId']);
          _myAnimals.add(post);
          notifyListeners();
        });
      });
    });
  }

  Future<void> makeAllListsEmpty() async {
    _allPosts.clear();
    _allGroupPost.clear();
    _animalList.clear();
    _favouriteList.clear();
    _chatUserList.clear();
    _followerList.clear();
    _followingList.clear();
    _userPosts.clear();
    _otherUserPosts.clear();
    _peopleDemoList.clear();
    _notificationList.clear();
  }

  Future<void> getNotifications() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final String? myNumber = pref.getString('mobileNo');
    try {
      await FirebaseFirestore.instance
          .collection('Notifications')
          .where('receiverId', isEqualTo: myNumber!)
          .orderBy('date', descending: true)
          .get()
          .then((snapshot) {
        _notificationList.clear();
        _totalNotifications = 0;
        snapshot.docChanges.forEach((element) {
          if (element.doc['postId'] != '' &&
              element.doc['senderId'] != myNumber) {
            MyNotification notification = MyNotification(
              notificationId: element.doc['notificationId'],
              date: element.doc['date'].toString(),
              senderId: element.doc['senderId'],
              receiverId: element.doc['receiverId'],
              title: element.doc['title'],
              body: element.doc['body'],
              senderName: element.doc['senderName'],
              receiverName: element.doc['receiverName'],
              status: element.doc['status'],
              postId: element.doc['postId'],
              groupId: element.doc['groupId'],
            );
            _notificationList.add(notification);
            if (element.doc['status'] == 'unclicked') _totalNotifications++;
          }
        });
      });
      notifyListeners();
      print('Get Notification called');
      Future.delayed(Duration(minutes: 3)).then((value) => getNotifications());
    } catch (error) {
      print('Fetching notifications error: $error');
    }
  }

  // Future<void> countNotifications(UserProvider userProvider) async {
  //   try {
  //     _totalNotifications = 0;
  //     userProvider.getCurrentUserInfo().then((value) async {
  //       await FirebaseFirestore.instance
  //           .collection('Notifications')
  //           .get()
  //           .then((snapshot) {
  //         snapshot.docChanges.forEach((element) {
  //           if (element.doc['receiverId'] ==
  //                   userProvider.currentUserMap['mobileNo'] &&
  //               element.doc['postId'] != '' &&
  //               element.doc['status'] == 'unclicked') {
  //             // MyNotification notification = MyNotification(
  //             //     notificationId: element.doc['notificationId'],
  //             //     date: element.doc['date'].toString(),
  //             //     senderId: element.doc['senderId'],
  //             //     receiverId: element.doc['receiverId'],
  //             //     title: element.doc['title'],
  //             //     body: element.doc['body'],
  //             //     senderName: element.doc['senderName'],
  //             //     receiverName: element.doc['receiverName'],
  //             //     status: element.doc['status'],
  //             //     postId: element.doc['postId']);
  //
  //             _totalNotifications++;
  //           }
  //         });
  //         print('total notifications count = $_totalNotifications');
  //       });
  //     });
  //     notifyListeners();
  //   } catch (error) {
  //     print('Counting notifications error: $error');
  //   }
  // }

  Future<void> getSpecificPost(String postId) async {
    try {
      _specificPost.clear();
      await FirebaseFirestore.instance
          .collection('allPosts')
          .where('postId', isEqualTo: postId)
          .get()
          .then((snapshot) {
        snapshot.docChanges.forEach((element) {
          Post post = Post(
              postId: element.doc['postId'],
              postOwnerId: element.doc['postOwnerId'],
              postOwnerMobileNo: element.doc['postOwnerMobileNo'],
              postOwnerName: element.doc['postOwnerName'],
              postOwnerImage: element.doc['postOwnerImage'],
              date: element.doc['date'],
              status: element.doc['status'],
              photo: element.doc['photo'],
              video: element.doc['video'],
              animalToken: element.doc['animalToken'],
              animalName: element.doc['animalName'],
              animalColor: element.doc['animalColor'],
              animalAge: element.doc['animalAge'],
              animalGender: element.doc['animalGender'],
              animalGenus: element.doc['animalGenus'],
              totalFollowers: element.doc['totalFollowers'],
              totalComments: element.doc['totalComments'],
              totalShares: element.doc['totalShares'],
              groupId: element.doc['groupId'],
              shareId: element.doc['shareId']);

          _specificPost.add(post);
          notifyListeners();
        });
      });
    } catch (error) {
      print('getting specific post error: $error');
    }
  }

  Future<void> setChecked(String notificationId, int index) async {
    if (_totalNotifications > 0) {
      await FirebaseFirestore.instance
          .collection('Notifications')
          .doc(notificationId)
          .update({'status': 'clicked'}).then((value) async {
        await FirebaseFirestore.instance
            .collection('Notifications')
            .doc(notificationId)
            .get()
            .then((snapshot) {
          _notificationList[index].status = snapshot['status'];
        });
      });
      _totalNotifications--;
      notifyListeners();
    }
  }

  Future<void> searchAnimalsByName(String animalName) async {
    try {
      _animalNameSearchList.clear();

      await FirebaseFirestore.instance
          .collection('allPosts')
          .get()
          .then((snapshot) {
        snapshot.docChanges.forEach((element) {
          if (element.doc['shareId'] == '' &&
              element.doc['animalName'].toLowerCase() ==
                  animalName.toLowerCase()) {
            Post post = Post(
                postId: element.doc['postId'],
                postOwnerId: element.doc['postOwnerId'],
                postOwnerMobileNo: element.doc['postOwnerMobileNo'],
                postOwnerName: element.doc['postOwnerName'],
                postOwnerImage: element.doc['postOwnerImage'],
                date: element.doc['date'],
                status: element.doc['status'],
                photo: element.doc['photo'],
                video: element.doc['video'],
                animalToken: element.doc['animalToken'],
                animalName: element.doc['animalName'],
                animalColor: element.doc['animalColor'],
                animalAge: element.doc['animalAge'],
                animalGender: element.doc['animalGender'],
                animalGenus: element.doc['animalGenus'],
                totalFollowers: element.doc['totalFollowers'],
                totalComments: element.doc['totalComments'],
                totalShares: element.doc['totalShares'],
                groupId: element.doc['groupId'],
                shareId: element.doc['shareId']);
            _animalNameSearchList.add(post);
          }
        });
      });
      notifyListeners();
    } catch (error) {
      print('searching animal by name error: $error');
    }
  }

  void makeAnimalNameSearchListEmpty() {
    _animalNameSearchList.clear();
  }
}
