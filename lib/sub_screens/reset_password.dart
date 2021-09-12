import 'package:flutter/material.dart';
import 'package:pet_lover/demo_designs/text_field_demo.dart';
import 'package:pet_lover/login.dart';
import 'package:pet_lover/provider/userProvider.dart';
import 'package:pet_lover/sub_screens/pass_update.dart';
import 'package:provider/provider.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({Key? key}) : super(key: key);

  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  Map<String, String> _currentUserInfoMap = {};
  int _count = 0;
  String _password = '';
  TextEditingController _oldPasswordController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _confirmPassswordController = TextEditingController();
  String? _oldPasswordError;
  String? _newPasswordError;
  String? _confirmPasswordError;
  bool _loading = false;
  bool _oldPassObscureText = true;
  bool _newPassObscureText = true;
  bool _confirmPassObscureText = true;
  FocusNode _oldPasswordFocusNode = FocusNode();
  FocusNode _newPasswordFocusNode = FocusNode();
  FocusNode _confirmPasswordFocusNode = FocusNode();

  _customInit(UserProvider userProvider) async {
    setState(() {
      _count++;
    });

    await userProvider.getCurrentUserInfo().then((value) {
      setState(() {
        _currentUserInfoMap = userProvider.currentUserMap;
        _password = _currentUserInfoMap['passowrd']!;
        print('previous password = $_password');
      });
    });
  }

  _resetPassword(UserProvider userProvider, String newPassword) async {
    setState(() {
      _loading = true;
    });
    if (_password == _oldPasswordController.text) {
      await userProvider
          .resetPassword(userProvider.currentUserMobile, newPassword)
          .then((value) {
        setState(() {
          _loading = false;
        });
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Pass_update()),
            (route) => false);
      });
    } else {
      setState(() {
        _loading = false;
      });
      _showToast(context, 'Incorrect old password!');
    }
  }

  _showToast(BuildContext context, String text) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    if (_count == 0) _customInit(userProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.deepOrange),
            onPressed: () {
              Navigator.pop(context);
            },
          )),
      body: SingleChildScrollView(
        child: Container(
          width: size.width,
          height: size.height,
          child: Column(
            children: [
              Container(
                width: size.width,
                height: size.width * .40,
                color: Colors.white,
                child: Icon(
                  Icons.vpn_key,
                  size: size.width * .30,
                ),
              ),
              Text(
                'RESET',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              Text(
                'PASSWORD',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    size.width * .02, size.width * .02, size.width * .02, 0.0),
                child: Text(
                  'Set a strong password & protect your account',
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    size.width * .02, 0.0, size.width * .02, 0.0),
                child: Text(
                  'Password must be of more than 6 digits',
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: size.width * .02,
              ),
              Container(
                width: size.width,
                height: size.width * .2,
                padding: EdgeInsets.fromLTRB(
                    size.width * .05, 20.0, size.width * .05, 0.0),
                child: TextFieldBuilder().showtextFormBuilder(
                    context,
                    'Password',
                    Icons.vpn_key,
                    _oldPasswordController,
                    _oldPasswordError,
                    _oldPassObscureText,
                    _oldPasswordFocusNode,
                    InkWell(
                        onTap: () {
                          setState(() {
                            _oldPassObscureText = !_oldPassObscureText;
                          });
                        },
                        child: Icon(
                          _oldPassObscureText == true
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
              SizedBox(
                height: size.width * .03,
                width: size.width,
              ),
              Container(
                width: size.width,
                height: size.width * .14,
                padding: EdgeInsets.fromLTRB(
                    size.width * .06, 0.0, size.width * .06, 0.0),
                child: _loading == true
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
                            if (_oldPasswordController.text.isEmpty) {
                              _oldPasswordError = 'Old password required!';
                              return;
                            } else {
                              _oldPasswordError = null;
                            }
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

                            _oldPasswordError = null;
                            _newPasswordError = null;
                            _confirmPasswordError = null;
                            _resetPassword(
                                userProvider, _newPasswordController.text);
                          });
                        },
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.deepOrange),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(size.width * .04),
                            ))),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
