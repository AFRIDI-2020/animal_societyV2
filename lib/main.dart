import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pet_lover/home.dart';
import 'package:pet_lover/login.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pet_lover/provider/animalProvider.dart';
import 'package:pet_lover/provider/groupProvider.dart';
import 'package:pet_lover/provider/postProvider.dart';
import 'package:pet_lover/provider/userProvider.dart';
import 'package:pet_lover/sub_screens/maintenanceBreak.dart';
import 'package:pet_lover/sub_screens/notificationList.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await FlutterDownloader.initialize();
  final _prefs = await SharedPreferences.getInstance();
  String? _currentMobileNo = _prefs.getString('mobileNo') ?? null;

  Widget _homeWidget;
  if (_currentMobileNo != null) {
    _homeWidget = Home();
  } else {
    _homeWidget = Login();
  }
  runApp(MyApp(homepage: _homeWidget));
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message ${message.messageId}');
}

class MyApp extends StatefulWidget {
  Widget homepage;
  MyApp({required this.homepage});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  void _initialize() {
    _fcm.getInitialMessage();

    ///Destroy
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message!.data['screen'].isNotEmpty) {
        setState(() => widget.homepage = Notifications(isPush: true));
      }
    });

    ///App Running
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.data['screen'].isNotEmpty) {
        setState(() => widget.homepage = MyApp(homepage: Home()));
      }
    });

    ///Minimize
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data['screen'].isNotEmpty) {
        setState(() => widget.homepage = Notifications(isPush: true));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.grey.shade100,
        statusBarIconBrightness: Brightness.dark));

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AnimalProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => GroupProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider())
      ],
      child: MaterialApp(
        title: 'Animal Society',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          backgroundColor: Colors.black,
          primarySwatch: Colors.deepOrange,
        ),
        home: widget.homepage,
      ),
    );
  }
}
