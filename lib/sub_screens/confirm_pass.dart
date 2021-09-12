import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pet_lover/demo_designs/text_field_demo.dart';
import 'package:pet_lover/login.dart';
import 'package:pet_lover/provider/userProvider.dart';
import 'package:pet_lover/sub_screens/pass_update.dart';
import 'package:provider/provider.dart';

class Confirm_pass extends StatefulWidget {
  String mobileNo;

  Confirm_pass({Key? key, required this.mobileNo}) : super(key: key);

  @override
  _Confirm_passState createState() => _Confirm_passState(mobileNo);
}

class _Confirm_passState extends State<Confirm_pass> {
  String mobileNo;
  _Confirm_passState(this.mobileNo);
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _confirmPassswordController = TextEditingController();
  String? _newPasswordError;
  String? _confirmPasswordError;
  bool _newPassObscureText = true;
  bool _confirmPassObscureText = true;
  FocusNode _newPasswordFocusNode = FocusNode();
  FocusNode _confirmPasswordFocusNode = FocusNode();
  bool _loading = false;

  _resetPassword(UserProvider userProvider, String newPassword) async {
    setState(() {
      _loading = true;
    });
    await userProvider.resetPassword(mobileNo, newPassword).then((value) {
      setState(() {
        _loading = false;
      });
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Pass_update()),
          (route) => false);
    });
  }

  Future<bool> _onBackPressed() async {
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (context) => Login()), (route) => false);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              'Reset Password',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            elevation: 0,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => Login()),
                    (route) => false);
              },
            ),
          ),
          body: _bodyUI(context)),
    );
  }

  Widget _bodyUI(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: size.width * .10),
          Icon(
            Icons.vpn_key,
            size: size.width * .30,
          ),
          SizedBox(height: size.width * .05),
          Text(
            'NEW',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          Text(
            'CREDENTIALS',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: size.width * .05),
          Text(
            'Your identity has been verified.',
            textAlign: TextAlign.center,
          ),
          Text(
            'Set your new password',
            textAlign: TextAlign.center,
          ),
          SizedBox(height: size.width * .05),
          Container(
            width: size.width,
            padding: EdgeInsets.fromLTRB(
                size.width * .05, 20.0, size.width * .05, 0.0),
            child: TextFieldBuilder().showtextFormBuilder(
                context,
                'New password',
                Icons.vpn_key,
                _newPasswordController,
                _newPasswordError,
                _newPassObscureText,
                _newPasswordFocusNode,
                InkWell(
                    onTap: () {
                      setState(() {
                        _newPassObscureText = !_newPassObscureText;
                      });
                    },
                    child: Icon(
                      _newPassObscureText
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.deepOrange,
                    ))),
          ),
          Container(
            width: size.width,
            padding: EdgeInsets.fromLTRB(
                size.width * .05, 20.0, size.width * .05, 0.0),
            child: TextFieldBuilder().showtextFormBuilder(
                context,
                'Confirm password',
                Icons.vpn_key,
                _confirmPassswordController,
                _confirmPasswordError,
                _confirmPassObscureText,
                _confirmPasswordFocusNode,
                InkWell(
                    onTap: () {
                      setState(() {
                        _confirmPassObscureText = !_confirmPassObscureText;
                      });
                    },
                    child: Icon(
                      _confirmPassObscureText
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.deepOrange,
                    ))),
          ),
          SizedBox(height: size.width * .05),
          Container(
            width: size.width,
            height: size.width * .14,
            padding: EdgeInsets.fromLTRB(
                size.width * .05, 0.0, size.width * .05, 0.0),
            child: _loading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                    ],
                  )
                : ElevatedButton(
                    child: Text(
                      'Reset',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        if (_newPasswordController.text.length < 6 ||
                            _newPasswordController.text.isEmpty) {
                          _newPasswordError = 'At least 6 digits required!';
                          return;
                        } else {
                          _newPasswordError = null;
                        }

                        if (_confirmPassswordController.text !=
                            _newPasswordController.text) {
                          _confirmPasswordError =
                              'New passwords does not match!';
                          return;
                        } else {
                          _confirmPasswordError = null;
                        }

                        _newPasswordError = null;
                        _confirmPasswordError = null;
                        _resetPassword(
                            userProvider, _newPasswordController.text);
                      });
                    },
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.deepOrange),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(size.width * .04),
                        ))),
                  ),
          ),
        ],
      ),
    );
  }
}
