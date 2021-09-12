import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pet_lover/home.dart';
import 'package:pet_lover/login.dart';

class RegistrationSuccessful extends StatefulWidget {
  const RegistrationSuccessful({Key? key}) : super(key: key);

  @override
  _RegistrationSuccessfulState createState() => _RegistrationSuccessfulState();
}

class _RegistrationSuccessfulState extends State<RegistrationSuccessful> {
  Future<bool> _onBackPressed() async {
    return (await showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Row(
                    children: [
                      Icon(Icons.exit_to_app),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Exit App',
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                  content: Text(
                    'Do you really want to exit the app?',
                    style: TextStyle(color: Colors.black),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('No'),
                    ),
                    TextButton(
                      onPressed: () => SystemChannels.platform
                          .invokeMethod('SystemNavigator.pop'),
                      child: Text(
                        'Yes',
                        style: TextStyle(color: Colors.green),
                      ),
                    )
                  ],
                ))) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        body: _bodyUI(context),
      ),
    );
  }

  Widget _bodyUI(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      height: size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'REGISTRATION',
            style: TextStyle(
                color: Colors.black,
                fontSize: size.width * .08,
                fontWeight: FontWeight.bold),
          ),
          Text(
            'SUCCESSFUL',
            style: TextStyle(
                color: Colors.black,
                fontSize: size.width * .08,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: size.width * .05,
          ),
          Icon(
            Icons.check_circle_sharp,
            color: Colors.deepOrange,
            size: size.width * .3,
          ),
          SizedBox(
            height: size.width * .05,
          ),
          Text(
            'Welcome to Animal Society',
            style: TextStyle(
                color: Colors.black,
                fontSize: size.width * .05,
                fontWeight: FontWeight.w500),
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
                  Navigator.push(context,
                      (MaterialPageRoute(builder: (context) => Home())));
                },
                child: Text(
                  'GET STARTED',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size.width * .04,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ))),
              ))
        ],
      ),
    );
  }
}
