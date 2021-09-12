import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:pet_lover/model/group.dart';
import 'package:pet_lover/model/group_post.dart';
import 'package:pet_lover/model/member.dart';
import 'package:pet_lover/model/myGroup.dart';
import 'package:pet_lover/provider/postProvider.dart';
import 'package:pet_lover/provider/userProvider.dart';
import 'package:pet_lover/sub_screens/groups.dart';

class GroupProvider extends ChangeNotifier {
  List<MyGroup> _myGroups = [];
  Map<String, String> _groupInfo = {};
  bool _isGroupMember = false;
  List<Member> _members = [];
  List<Group> _publicGroups = [];
  int _numbrOfGroupMembers = 0;
  List<Group> _searchedGroups = [];
  List<Group> _allGroups = [];
  List<Group> _allPublicGroups = [];
  List<GroupPost> _groupPostList = [];
  DocumentSnapshot? _startAfter;
  List<GroupPost> _allGroupPosts = [];
  int _numberOfComments = 0;
  int _totalGroupMembers = 0;

  get groupPostList => _groupPostList;
  get myGroups => _myGroups;
  get groupInfo => _groupInfo;
  get isGroupMember => _isGroupMember;
  get members => _members;
  get publicGroups => _publicGroups;
  get numberOfGroupMembers => _numbrOfGroupMembers;
  get searchedGroups => _searchedGroups;
  get allGroups => _allGroups;
  get allPublicGroups => _allPublicGroups;
  get allGroupPosts => _allGroupPosts;
  get numberOfComments => _numberOfComments;
  get totalGroupMembers => _totalGroupMembers;

  Future<List<MyGroup>> getMyGroups(String currentMobileNo) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentMobileNo)
          .collection('myGroups')
          .orderBy('date', descending: true)
          .get();

      _myGroups.clear();

      querySnapshot.docChanges.forEach((element) {
        MyGroup myGroup = MyGroup(
            admin: element.doc['admin'],
            date: element.doc['date'],
            description: element.doc['description'],
            groupImage: element.doc['groupImage'],
            groupName: element.doc['groupName'],
            id: element.doc['id'],
            privacy: element.doc['privacy'],
            myRole: element.doc['myRole']);
        _myGroups.add(myGroup);
      });
      return _myGroups;
    } catch (error) {
      print('Cannot get myGroups - $error');
      return [];
    }
  }

  Future<void> createGroup(
      BuildContext context,
      String groupName,
      String currentMobileNo,
      File? image,
      String id,
      String privacy,
      String description,
      UserProvider userProvider) async {
    String groupImage = '';
    Reference groupStorageRef =
        FirebaseStorage.instance.ref().child('group_photos').child(id);
    if (image != null) {
      UploadTask groupPhotoUploadTask = groupStorageRef.putFile(image);
      TaskSnapshot taskSnapshot;
      groupPhotoUploadTask.then((value) {
        taskSnapshot = value;
        taskSnapshot.ref.getDownloadURL().then((imageDownloadLink) {
          groupImage = imageDownloadLink;
          saveGroupInfo(context, id, groupName, groupImage, currentMobileNo,
              privacy, description, userProvider);
        });
      });
    } else {
      saveGroupInfo(context, id, groupName, groupImage, currentMobileNo,
          privacy, description, userProvider);
    }
  }

  Future<void> updateGroup(
      BuildContext context,
      String groupName,
      String currentMobileNo,
      File? image,
      String id,
      String privacy,
      String description,
      UserProvider userProvider,
      String groupPhoto) async {
    String groupImg = '';
    Reference groupStorageRef =
        FirebaseStorage.instance.ref().child('group_photos').child(id);
    if (image != null) {
      UploadTask groupPhotoUploadTask = groupStorageRef.putFile(image);
      TaskSnapshot taskSnapshot;
      groupPhotoUploadTask.then((value) {
        taskSnapshot = value;
        taskSnapshot.ref.getDownloadURL().then((imageDownloadLink) {
          groupImg = imageDownloadLink;
          updateGroupInfo(context, id, groupName, groupImg, currentMobileNo,
              privacy, description, userProvider);
        });
      });
    } else {
      groupImg = groupPhoto;
      updateGroupInfo(context, id, groupName, groupImg, currentMobileNo,
          privacy, description, userProvider);
    }
  }

  Future<void> updateGroupInfo(
      BuildContext context,
      String uuid,
      String groupName,
      String groupImage,
      String currentMobileNo,
      String privacy,
      String description,
      UserProvider userProvider) async {
    Map<String, String> userInfo = {};
    String date = DateTime.now().millisecondsSinceEpoch.toString();

    DocumentReference groupCollection =
        FirebaseFirestore.instance.collection('Groups').doc(uuid);

    DocumentReference myGroups = FirebaseFirestore.instance
        .collection('users')
        .doc(currentMobileNo)
        .collection('myGroups')
        .doc(uuid);

    DocumentReference memberRef = FirebaseFirestore.instance
        .collection('Groups')
        .doc(uuid)
        .collection('members')
        .doc(currentMobileNo);

    await userProvider.getCurrentUserInfo().then((value) {
      userInfo = userProvider.currentUserMap;
    });

    await myGroups.update({
      'groupName': groupName,
      'groupImage': groupImage,
      'date': date,
      'admin': currentMobileNo,
      'id': uuid,
      'privacy': privacy,
      'description': description,
      'myRole': 'admin'
    });

    await memberRef.update({
      'date': date,
      'mobileNo': currentMobileNo,
      'profileImageLink': userInfo['profileImageLink'],
      'username': userInfo['username'],
      'memberRole': 'admin'
    });

    await groupCollection.update({
      'groupName': groupName,
      'groupImage': groupImage,
      'date': date,
      'admin': currentMobileNo,
      'id': uuid,
      'privacy': privacy,
      'description': description
    }).then((value) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Groups()));
    });
  }

  Future<void> saveGroupInfo(
      BuildContext context,
      String uuid,
      String groupName,
      String groupImage,
      String currentMobileNo,
      String privacy,
      String description,
      UserProvider userProvider) async {
    Map<String, String> userInfo = {};
    String date = DateTime.now().millisecondsSinceEpoch.toString();

    DocumentReference groupCollection =
        FirebaseFirestore.instance.collection('Groups').doc(uuid);

    DocumentReference myGroups = FirebaseFirestore.instance
        .collection('users')
        .doc(currentMobileNo)
        .collection('myGroups')
        .doc(uuid);

    DocumentReference memberRef = FirebaseFirestore.instance
        .collection('Groups')
        .doc(uuid)
        .collection('members')
        .doc(currentMobileNo);

    await userProvider.getCurrentUserInfo().then((value) {
      userInfo = userProvider.currentUserMap;
    });

    await myGroups.set({
      'groupName': groupName,
      'groupImage': groupImage,
      'date': date,
      'admin': currentMobileNo,
      'id': uuid,
      'privacy': privacy,
      'description': description,
      'myRole': 'admin'
    });

    await memberRef.set({
      'date': date,
      'mobileNo': currentMobileNo,
      'profileImageLink': userInfo['profileImageLink'],
      'username': userInfo['username'],
      'memberRole': 'admin'
    });

    await groupCollection.set({
      'groupName': groupName,
      'groupImage': groupImage,
      'date': date,
      'admin': currentMobileNo,
      'id': uuid,
      'privacy': privacy,
      'description': description,
    }).then((value) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Groups()));
    });
  }

  Future<void> getGroupInfo(String groupId) async {
    DocumentReference groupInfoRef =
        FirebaseFirestore.instance.collection('Groups').doc(groupId);

    try {
      await groupInfoRef.get().then((doc) {
        _groupInfo = {
          'admin': doc['admin'],
          'date': doc['date'],
          'description': doc['description'],
          'groupImage': doc['groupImage'],
          'groupName': doc['groupName'],
          'id': doc['id'],
          'privacy': doc['privacy']
        };
      });
    } catch (error) {
      print('Fetching groupInfo failed - $error');
    }
  }

  Future<void> addMember(String groupId, String mobileNo, String date,
      UserProvider userProvider, PostProvider postProvider) async {
    try {
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
        'groupName': _groupInfo['groupName'],
        'groupImage': _groupInfo['groupImage'],
        'date': date,
        'admin': _groupInfo['admin'],
        'id': groupId,
        'privacy': _groupInfo['privacy'],
        'description': _groupInfo['description'],
        'myRole': 'member'
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
      });
    } catch (error) {
      print('Adding member in group failed - $error');
    }
  }

  Future<bool> isGroupMemberOrNot(String groupId, String mobileNo) async {
    bool member = false;
    try {
      DocumentReference memberQuery = FirebaseFirestore.instance
          .collection('Groups')
          .doc(groupId)
          .collection('members')
          .doc(mobileNo);

      await memberQuery.get().then((snapshot) async {
        if (snapshot.exists) {
          _isGroupMember = true;
          member = true;
          return;
        }
        _isGroupMember = false;
        member = false;
      });
      return member;
    } catch (error) {
      print('Determining group member or not failed - $error');
      return member;
    }
  }

  Future<void> getAllMembers(String groupId) async {
    try {
      CollectionReference membersRef = FirebaseFirestore.instance
          .collection('Groups')
          .doc(groupId)
          .collection('members');
      _members.clear();

      await membersRef.get().then((snapshot) {
        snapshot.docChanges.forEach((element) {
          Member member = Member(
              date: element.doc['date'],
              mobileNo: element.doc['mobileNo'],
              profileImageLink: element.doc['profileImageLink'],
              memberRole: element.doc['memberRole'],
              username: element.doc['username']);
          _members.add(member);
          notifyListeners();
        });
        _totalGroupMembers = _members.length;
        notifyListeners();
      });
    } catch (error) {
      print('Group members list cannot be fetched - $error');
    }
  }

  Future<void> publicGroupSuggessions(String currentMobileNo) async {
    try {
      _publicGroups.clear();
      await FirebaseFirestore.instance
          .collection('Groups')
          .where('privacy', isEqualTo: 'Public')
          .get()
          .then((document) {
        document.docChanges.forEach((element) {
          Group group = Group(
              admin: element.doc['admin'],
              date: element.doc['date'],
              description: element.doc['description'],
              groupImage: element.doc['groupImage'],
              groupName: element.doc['groupName'],
              id: element.doc['id'],
              privacy: element.doc['privacy']);
          String groupId = element.doc['id'];
          isGroupMemberOrNot(groupId, currentMobileNo).then((value) {
            if (_isGroupMember == false) {
              _publicGroups.add(group);
            }
          });
        });
      });
    } catch (error) {
      print('Public grouplist cannot be shown - $error');
    }
  }

  Future<void> joinGroup(String groupId, String mobileNo, String date,
      UserProvider userProvider) async {
    try {
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

      await getGroupInfo(groupId).then((value) async {
        await myGroups.set({
          'groupName': _groupInfo['groupName'],
          'groupImage': _groupInfo['groupImage'],
          'date': date,
          'admin': _groupInfo['admin'],
          'id': groupId,
          'privacy': _groupInfo['privacy'],
          'description': _groupInfo['description'],
          'myRole': 'member'
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
      });
    } catch (error) {
      print('Adding member in group failed - $error');
    }
  }

  Future<void> getAllGroups() async {
    _allGroups.clear();
    await FirebaseFirestore.instance
        .collection('Groups')
        .get()
        .then((snapshot) {
      snapshot.docChanges.forEach((element) {
        Group group = Group(
            admin: element.doc['admin'],
            date: element.doc['date'],
            description: element.doc['description'],
            groupImage: element.doc['groupImage'],
            groupName: element.doc['groupName'],
            id: element.doc['id'],
            privacy: element.doc['privacy']);
        _allGroups.add(group);
      });
    });
  }

  Future<void> getAllPublicGroups() async {
    _allPublicGroups.clear();
    await FirebaseFirestore.instance
        .collection('Groups')
        .where('privacy', isEqualTo: 'Public')
        .get()
        .then((snapshot) {
      snapshot.docChanges.forEach((element) {
        Group group = Group(
            admin: element.doc['admin'],
            date: element.doc['date'],
            description: element.doc['description'],
            groupImage: element.doc['groupImage'],
            groupName: element.doc['groupName'],
            id: element.doc['id'],
            privacy: element.doc['privacy']);
        _allPublicGroups.add(group);
      });
    });
  }

  Future<void> makeModerator(
      String groupId, String memberMobileNo, UserProvider userProvider) async {
    try {
      Map<String, String> userInfo = {};
      DocumentReference memberRef = FirebaseFirestore.instance
          .collection('Groups')
          .doc(groupId)
          .collection('members')
          .doc(memberMobileNo);

      DocumentReference myGroup = FirebaseFirestore.instance
          .collection('users')
          .doc(memberMobileNo)
          .collection('myGroups')
          .doc(groupId);

      await myGroup.update({'myRole': 'moderator'});

      await userProvider.getSpecificUserInfo(memberMobileNo).then((value) {
        userInfo = userProvider.specificUserMap;
      });

      await memberRef.update({'memberRole': 'moderator'});
    } catch (error) {
      print('Failed to make moderator - $error');
    }
  }

  Future<void> DemoteToMember(
      String groupId, String memberMobileNo, UserProvider userProvider) async {
    try {
      Map<String, String> userInfo = {};
      DocumentReference memberRef = FirebaseFirestore.instance
          .collection('Groups')
          .doc(groupId)
          .collection('members')
          .doc(memberMobileNo);

      DocumentReference myGroup = FirebaseFirestore.instance
          .collection('users')
          .doc(memberMobileNo)
          .collection('myGroups')
          .doc(groupId);

      await myGroup.update({'myRole': 'member'});

      await userProvider.getSpecificUserInfo(memberMobileNo).then((value) {
        userInfo = userProvider.specificUserMap;
      });

      await memberRef.update({'memberRole': 'member'});
    } catch (error) {
      print('Failed to make moderator - $error');
    }
  }

  Future<void> RemoveFromGroup(String groupId, String memberMobileNo) async {
    try {
      DocumentReference myGroup = FirebaseFirestore.instance
          .collection('users')
          .doc(memberMobileNo)
          .collection('myGroups')
          .doc(groupId);

      DocumentReference memberRef = FirebaseFirestore.instance
          .collection('Groups')
          .doc(groupId)
          .collection('members')
          .doc(memberMobileNo);

      myGroup.delete();
      memberRef.delete();
    } catch (error) {
      print('Removing member failed - $error');
    }
  }

  Future<List<GroupPost>> getGroupPost(int limit, String groupId) async {
    print('getAnimals() running');
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Groups')
          .doc(groupId)
          .collection('posts')
          .orderBy('date', descending: true)
          .limit(limit)
          .get();
      _groupPostList.clear();
      if (querySnapshot.docs.isNotEmpty) {
        _startAfter = querySnapshot.docs.last;
        print('the _startAfter value ${_startAfter!.data()}');
      } else {
        _startAfter = null;
      }

      querySnapshot.docChanges.forEach((element) {
        GroupPost groupPost = GroupPost(
          userProfileImage: element.doc['userProfileImage'],
          username: element.doc['username'],
          mobile: element.doc['mobile'],
          age: element.doc['age'],
          color: element.doc['color'],
          date: element.doc['date'],
          gender: element.doc['gender'],
          genus: element.doc['genus'],
          id: element.doc['id'],
          petName: element.doc['petName'],
          photo: element.doc['photo'],
          totalComments: element.doc['totalComments'],
          totalFollowings: element.doc['totalFollowings'],
          totalShares: element.doc['totalShares'],
          video: element.doc['video'],
          status: element.doc['status'],
          groupId: element.doc['groupId'],
        );
        _groupPostList.add(groupPost);
      });
      return groupPostList;
    } catch (error) {
      print('Error: $error');
      return [];
    }
  }

  Future<List<GroupPost>> getMorePost(int limit, String groupId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Groups')
          .doc(groupId)
          .collection('posts')
          .orderBy('date', descending: true)
          .limit(limit)
          .startAfterDocument(_startAfter!)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        _startAfter = querySnapshot.docs.last;
        print('after scrolling last animal ${_startAfter!.data()}');
      } else {
        _startAfter = null;
      }

      querySnapshot.docChanges.forEach((element) {
        GroupPost groupPost = GroupPost(
          userProfileImage: element.doc['userProfileImage'],
          username: element.doc['username'],
          mobile: element.doc['mobile'],
          age: element.doc['age'],
          color: element.doc['color'],
          date: element.doc['date'],
          gender: element.doc['gender'],
          genus: element.doc['genus'],
          id: element.doc['id'],
          petName: element.doc['petName'],
          photo: element.doc['photo'],
          totalComments: element.doc['totalComments'],
          totalFollowings: element.doc['totalFollowings'],
          totalShares: element.doc['totalShares'],
          video: element.doc['video'],
          status: element.doc['status'],
          groupId: element.doc['groupId'],
        );
        _groupPostList.add(groupPost);
      });
      return _groupPostList;
    } catch (error) {
      print('Error: $error');
      return [];
    }
  }

  Future<void> leaveGroup(UserProvider userProvider, String groupId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Groups')
          .doc(groupId)
          .collection('members')
          .doc(userProvider.currentUserMobile)
          .delete();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userProvider.currentUserMobile)
          .collection('myGroups')
          .doc(groupId)
          .delete();
    } catch (error) {
      print('Leaving group failed! - $error');
    }
  }

  Future<void> deleteGroup(BuildContext context, String groupId,
      String groupImage, UserProvider userProvider) async {
    try {
      if (groupImage != '') {
        Reference storageRef = FirebaseStorage.instance.refFromURL(groupImage);
        await storageRef.delete();
      }
      await FirebaseFirestore.instance
          .collection('Groups')
          .doc(groupId)
          .collection('members')
          .get()
          .then((snapshot) async {
        snapshot.docChanges.forEach((element) async {
          String userId = element.doc['mobileNo'];
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('myGroups')
              .doc(groupId)
              .delete()
              .then((value) async {
            await FirebaseFirestore.instance
                .collection('Groups')
                .doc(groupId)
                .collection('members')
                .doc(userId)
                .delete();
          });
        });
        await FirebaseFirestore.instance
            .collection('Groups')
            .doc(groupId)
            .delete()
            .then((value) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Groups()));
        });
      });
    } catch (error) {
      print('Deleting group failed - $error');
    }
  }

  Future<String> totalComments(String groupId) async {
    try {
      String numberOfComments = '';
      await FirebaseFirestore.instance
          .collection('users')
          .doc(groupId)
          .get()
          .then((value) {
        numberOfComments = value['totalComments'];
      });
      return numberOfComments;
    } catch (error) {
      print('Counting number of comments in group post error - $error');
      return '';
    }
  }

  Future<void> getAllGroupPosts(int limit) async {
    try {
      _allGroupPosts.clear();
      await FirebaseFirestore.instance
          .collection('groupPosts')
          .limit(limit)
          .get()
          .then((snapshot) {
        snapshot.docChanges.forEach((element) {
          GroupPost groupPost = GroupPost(
              userProfileImage: element.doc['userProfileImage'],
              username: element.doc['username'],
              mobile: element.doc['mobile'],
              id: element.doc['id'],
              photo: element.doc['photo'],
              video: element.doc['video'],
              petName: element.doc['petName'],
              color: element.doc['color'],
              age: element.doc['age'],
              gender: element.doc['gender'],
              genus: element.doc['genus'],
              totalComments: element.doc['totalComments'],
              totalFollowings: element.doc['totalFollowings'],
              totalShares: element.doc['totalShares'],
              date: element.doc['date'],
              groupId: element.doc['groupId'],
              status: element.doc['status']);
          print('geting groupData = ${groupPost.status}');
          _allGroupPosts.add(groupPost);

          notifyListeners();
        });
      });
    } catch (error) {
      print('Getting all group posts error - $error');
    }
  }

  Future<void> addGroupPostComment(
    String postId,
    String commentId,
    String comment,
    String postOwnerMobileNo,
    String currentUserMobileNo,
    String date,
    String totalLikes,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('groupPosts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .set({
        'commentId': commentId,
        'comment': comment,
        'date': date,
        'animalOwnerMobileNo': postOwnerMobileNo,
        'commenter': currentUserMobileNo,
        'totalLikes': totalLikes,
        'petId': postId
      });

      await getNumberOfComments(postId).then((value) async {
        await FirebaseFirestore.instance
            .collection('groupPosts')
            .doc(postId)
            .update({
          'totalComments': _numberOfComments.toString(),
        });
      });
    } catch (error) {
      print('Add comment failed: $error');
    }
  }

  Future<void> getNumberOfComments(String postId) async {
    try {
      await FirebaseFirestore.instance
          .collection('groupPosts')
          .doc(postId)
          .collection('comments')
          .get()
          .then((snapshot) {
        _numberOfComments = snapshot.docs.length;
        notifyListeners();
      });
    } catch (error) {
      print('Number of comments in group post cannot be showed - $error');
    }
  }

  Future<void> deleteComment(String postId, String commentId) async {
    await FirebaseFirestore.instance
        .collection('groupPosts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .delete();

    await getNumberOfComments(postId).then((value) async {
      await FirebaseFirestore.instance
          .collection('groupPosts')
          .doc(postId)
          .update({
        'totalComments': _numberOfComments.toString(),
      });
    });
  }

  Future<void> editComment(
      String petId, String commentId, String newComment) async {
    await FirebaseFirestore.instance
        .collection('groupPosts')
        .doc(petId)
        .collection('comments')
        .doc(commentId)
        .update({
      'comment': newComment,
    });
  }
}
