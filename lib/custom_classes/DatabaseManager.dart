import 'dart:io';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseManager {
  CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  CollectionReference animalCollection =
      FirebaseFirestore.instance.collection('Animals');

  Future<void> addUser(
      String username,
      String mobileNo,
      String address,
      String registrationDate,
      String profileImageLink,
      String password,
      String about) async {
    final FirebaseMessaging fcm = FirebaseMessaging.instance;
    final fcmToken = await fcm.getToken();

    return await usersCollection.doc(mobileNo).set({
      'username': username,
      'mobileNo': mobileNo,
      'address': address,
      'registrationDate': registrationDate,
      'profileImageLink': profileImageLink,
      'password': password,
      'about': about
    }).then((value) async{
      await FirebaseFirestore.instance
          .collection('users')
          .doc(mobileNo)
          .collection('token')
          .doc(fcmToken)
          .set({
        'token': fcmToken!,
        'createdAt': FieldValue.serverTimestamp()
      });
    });
  }

  Future<bool> addAnimalsData(
    Map<String, String> animalMap,
    String _currentMobileNo,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection("Animals")
          .doc(animalMap['id'])
          .set(animalMap);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentMobileNo)
          .collection('my_pets')
          .doc(animalMap['id'])
          .set(animalMap);

      return true;
    } catch (err) {
      return false;
      //Hello
    }
  }

  Future<bool> UpdateAnimalsData(
      Map<String, String> map, String _currentMobileNo) async {
    try {
      await FirebaseFirestore.instance
          .collection("Animals")
          .doc(map['id'])
          .update(map);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentMobileNo)
          .collection('my_pets')
          .doc(map['id'])
          .update(map);

      return true;
    } catch (err) {
      return false;
    }
  }

  Future<void> updateUserInfo(String username, String mobileNo, String address,
      String registrationDate, String profileImageLink, String about) async {
    return await usersCollection.doc(mobileNo).update({
      'username': username,
      'mobileNo': mobileNo,
      'address': address,
      'registrationDate': registrationDate,
      'profileImageLink': profileImageLink,
      'about': about
    });
  }

  Future<bool> alreadyRegisteredNumber(String mobileNo) async {
    bool exists = false;
    try {
      await usersCollection.doc(mobileNo).get().then((doc) {
        if (doc.exists) {
          exists = true;
        } else {
          exists = false;
        }
      });
      return exists;
    } catch (e) {
      print(
          'Checking mobile number registered or not failed - ${e.toString()}');
      return false;
    }
  }

  Future<String> checkMobileNoPassword(String mobileNo, String password) async {
    String _error = '';

    try {
      await usersCollection
          .doc(mobileNo)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          dynamic nested = documentSnapshot.get(FieldPath(['password']));
          if (nested.toString() == password) {
          } else {
            _error = 'Incorrect password';
          }
        } else {
          _error = 'Not registered';
          print('Document does not exist on the database');
        }
      });
      return _error;
    } catch (e) {
      print('Login error - ${e.toString()}');
      return _error;
    }
  }

  Future uploadProfileImage(String _currentMobileNo, File _imageFile) async {
    try {
      await firebase_storage.FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child(_currentMobileNo)
          .putFile(_imageFile);
    } on firebase_core.FirebaseException catch (error) {
      print('Firebase error while uploading profile image - $error');
    }
  }

  Future<String> profileImageDownloadUrl(String _currentMobileNo) async {
    String downloadUrl = await firebase_storage.FirebaseStorage.instance
        .ref('profile_images/$_currentMobileNo')
        .getDownloadURL();

    return downloadUrl;
  }

  Future updatingProfileImageLink(
      String _profileImageLink, String _currentMobileNo) async {
    return await usersCollection.doc(_currentMobileNo).update({
      'profileImageLink': _profileImageLink,
    }).catchError(
        (error) => print('updating profiel image link failed = $error'));
  }

  Future<String> getUserInfo(String _currentMobileNo, String fieldName) async {
    final _snapshot = await usersCollection.doc(_currentMobileNo).get();
    String data = _snapshot[fieldName];
    return data;
  }

  Future<int> getNumberOfComments(String _animalId) async {
    int _numberOfComments = 0;
    try {
      await FirebaseFirestore.instance
          .collection('Animals')
          .doc(_animalId)
          .collection('comments')
          .get()
          .then((snapshot) {
        _numberOfComments = snapshot.docs.length;
      });
      return _numberOfComments;
    } catch (error) {
      print('Number of followers cannot be showed - $error');
      return _numberOfComments;
    }
  }

  clearSharedPref() async {
    final _prefs = await SharedPreferences.getInstance();
    await _prefs.clear();
  }

  Future<String> getCurrentMobileNo() async {
    final _prefs = await SharedPreferences.getInstance();
    final _currentMobileNo = _prefs.getString('mobileNo') ?? null;
    String _currentUserMobile = _currentMobileNo!;
    print('Current Mobile no given by userProvider is $_currentMobileNo');
    return _currentUserMobile;
  }

  Future<void> updateProfileImage(String profileImage) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    String currentMobileNo = await getCurrentMobileNo();
    try {
      await FirebaseFirestore.instance
          .collection('allPosts')
          .where('postOwnerId', isEqualTo: currentMobileNo)
          .get()
          .then((snapshot) {
        snapshot.docChanges.forEach((element) {
          batch.update(
              FirebaseFirestore.instance
                  .collection('allPosts')
                  .doc(element.doc.id),
              {
                'postOwnerImage': profileImage,
              });
        });
        return batch.commit();
      });
    } catch (error) {
      print('profile image batch update error - $error');
    }
  }

  Future<void> updateUsername(String username) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    String currentMobileNo = await getCurrentMobileNo();
    try {
      await FirebaseFirestore.instance
          .collection('allPosts')
          .where('postOwnerId', isEqualTo: currentMobileNo)
          .get()
          .then((snapshot) {
        snapshot.docChanges.forEach((element) {
          batch.update(
              FirebaseFirestore.instance
                  .collection('allPosts')
                  .doc(element.doc.id),
              {
                'postOwnerName': username,
              });
        });
        return batch.commit();
      });
    } catch (error) {
      print('profile image batch update error - $error');
    }
  }
}
