import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:store_redirect/store_redirect.dart';

class MaintenanceBreak extends StatefulWidget {
  const MaintenanceBreak({Key? key}) : super(key: key);

  @override
  _MaintenanceBreakState createState() => _MaintenanceBreakState();
}

class _MaintenanceBreakState extends State<MaintenanceBreak> {
  String current_version = '';
  String running_version = '';
  int count = 0;

  _customInit() async {
    setState(() {
      count++;
    });
    await FirebaseFirestore.instance
        .collection('Developer')
        .doc('123456')
        .get()
        .then((snapshot) {
      setState(() {
        current_version = snapshot['current_version'];
      });
    });
    await PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      setState(() {
        running_version = packageInfo.version;
      });
      print('running version = $running_version');
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    if (count == 0) _customInit();
    return Scaffold(
      backgroundColor: Colors.white,
      body: current_version == running_version
          ? Container(
              width: size.width,
              height: size.height,
              child: Stack(
                children: [
                  Container(
                    width: size.width,
                    height: size.height - size.width * .2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'MAINTENANCE',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: size.width * .08,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'BREAK',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: size.width * .08,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: size.width * .1,
                        ),
                        Icon(
                          Icons.build_rounded,
                          color: Colors.deepOrange,
                          size: size.width * .3,
                        ),
                        SizedBox(
                          height: size.width * .1,
                        ),
                        Container(
                          padding: EdgeInsets.only(
                              left: size.width * .05, right: size.width * .05),
                          child: Text(
                            'Currently App is under maintenace and soon there will be an update.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: size.width * .04,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: size.width * .1,
                    child: Container(
                      width: size.width,
                      alignment: Alignment.center,
                      child: Text(
                        'Thank you.',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: size.width * .04,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Container(
              width: size.width,
              height: size.height,
              child: Stack(
                children: [
                  Container(
                    width: size.width,
                    height: size.height - size.width * .2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'UPDATE',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: size.width * .08,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'AVAILABLE',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: size.width * .08,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: size.width * .1,
                        ),
                        Icon(
                          Icons.update,
                          color: Colors.deepOrange,
                          size: size.width * .3,
                        ),
                        SizedBox(
                          height: size.width * .1,
                        ),
                        Container(
                          padding: EdgeInsets.only(
                              left: size.width * .05, right: size.width * .05),
                          child: Text(
                            'Version $current_version is available!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: size.width * .04,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: size.width * .02,
                        ),
                        Container(
                            width: size.width,
                            height: size.width * .13,
                            padding: EdgeInsets.only(
                                left: size.width * .06,
                                right: size.width * .06,
                                top: size.width * .02),
                            child: ElevatedButton(
                              onPressed: () {
                                StoreRedirect.redirect(
                                  androidAppId:
                                      "com.glamworlditltd.animal_society",
                                );
                              },
                              child: Text(
                                'UPDATE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: size.width * .04,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ButtonStyle(
                                  shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ))),
                            ))
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: size.width * .1,
                    child: Container(
                      width: size.width,
                      alignment: Alignment.center,
                      child: Text(
                        'Thank you.',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: size.width * .04,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
