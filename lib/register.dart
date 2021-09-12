import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pet_lover/custom_classes/DatabaseManager.dart';
import 'package:pet_lover/custom_classes/TextFieldValidation.dart';
import 'package:pet_lover/custom_classes/progress_dialog.dart';
import 'package:pet_lover/custom_classes/toast.dart';
import 'package:pet_lover/login.dart';
import 'package:pet_lover/sub_screens/successful_registration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'demo_designs/text_field_demo.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _mobileNoController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  String? _mobileNoErrorText;
  String? _usernameErrorText;
  String? _addressErrorText;
  String? _passwordErrorText;
  String? _confirmPasswordErrorText;

  FocusNode usernameFocusNode = FocusNode();
  FocusNode mobileNoFocusNode = FocusNode();
  FocusNode addressFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  FocusNode confirmFocusNode = FocusNode();

  bool passwordObscureText = true;
  bool confirmPasswordObscureText = true;

  DateTime now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text(
          'Register',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        child: _bodyUI(context),
        physics: ClampingScrollPhysics(),
      ),
    );
  }

  Widget _bodyUI(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
        width: size.width,
        child: Column(children: [
          Container(
            width: size.width,
            height: size.height * .2,
            padding: EdgeInsets.only(bottom: size.width * .05),
            decoration: BoxDecoration(
                color: Colors.deepOrange,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(size.width * .1),
                  bottomRight: Radius.circular(size.width * .1),
                )),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Animal Society',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: size.width * .1,
                      fontFamily: 'MateSC',
                      fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(FontAwesomeIcons.paw,
                        size: size.width * .04, color: Colors.white),
                    SizedBox(width: size.width * .03),
                    Text(
                      'A community for pet lovers',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: size.width * .045,
                      ),
                    ),
                    SizedBox(width: size.width * .03),
                    Icon(FontAwesomeIcons.paw,
                        size: size.width * .04, color: Colors.white),
                  ],
                )
              ],
            ),
          ),
          Container(
            width: size.width,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(
                right: size.width * .05,
                top: size.width * .05,
                left: size.width * .05,
                bottom: size.width * .05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Register',
                  style: TextStyle(
                    color: Colors.deepOrange,
                    fontSize: size.width * .06,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: size.width * .02,
                ),
                Text(
                  'Get resistered for better experience',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: size.width * .032,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: size.width,
            padding:
                EdgeInsets.fromLTRB(size.width * .05, 0, size.width * .05, 0.0),
            child: TextFieldBuilder().showtextFormBuilder(
                context,
                'Username',
                Icons.person,
                _usernameController,
                _usernameErrorText,
                false,
                usernameFocusNode,
                null),
          ),
          Container(
            width: size.width,
            padding: EdgeInsets.fromLTRB(
                size.width * .05, size.width * .04, size.width * .05, 0.0),
            child: TextFieldBuilder().showtextFormBuilder(
                context,
                'Mobile number',
                Icons.phone_android_outlined,
                _mobileNoController,
                _mobileNoErrorText,
                false,
                mobileNoFocusNode,
                null),
          ),
          Container(
            width: size.width,
            padding: EdgeInsets.fromLTRB(
                size.width * .05, size.width * .04, size.width * .05, 0.0),
            child: TextFieldBuilder().showtextFormBuilder(
                context,
                'Address',
                Icons.location_city,
                _addressController,
                _addressErrorText,
                false,
                addressFocusNode,
                null),
          ),
          Container(
            width: size.width,
            padding: EdgeInsets.fromLTRB(
                size.width * .05, size.width * .04, size.width * .05, 0.0),
            child: TextFieldBuilder().showtextFormBuilder(
                context,
                'Password',
                Icons.vpn_key,
                _passwordController,
                _passwordErrorText,
                passwordObscureText,
                passwordFocusNode,
                InkWell(
                    onTap: () {
                      setState(() {
                        passwordObscureText = !passwordObscureText;
                      });
                    },
                    child: Icon(
                      passwordObscureText
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.deepOrange,
                    ))),
          ),
          Container(
            width: size.width,
            padding: EdgeInsets.fromLTRB(
                size.width * .05, size.width * .04, size.width * .05, 0.0),
            child: TextFieldBuilder().showtextFormBuilder(
                context,
                'Confirm Password',
                Icons.vpn_key,
                _confirmPasswordController,
                _confirmPasswordErrorText,
                confirmPasswordObscureText,
                confirmFocusNode,
                InkWell(
                    onTap: () {
                      setState(() {
                        confirmPasswordObscureText =
                            !confirmPasswordObscureText;
                      });
                    },
                    child: Icon(
                      confirmPasswordObscureText
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.deepOrange,
                    ))),
          ),
          Container(
            width: size.width,
            height: size.width * .18,
            padding: EdgeInsets.fromLTRB(
                size.width * .05, 20.0, size.width * .05, 0.0),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  if (!TextFieldValidation()
                      .usernameValidation(_usernameController.text)) {
                    _usernameErrorText = 'Username is required!';
                    return;
                  } else {
                    _usernameErrorText = null;
                  }
                  if (!TextFieldValidation()
                      .mobileNoValidate(_mobileNoController.text)) {
                    _mobileNoErrorText = 'Invalid mobile number!';
                    return;
                  } else {
                    _mobileNoErrorText = null;
                  }
                  if (!TextFieldValidation()
                      .addressValidation(_addressController.text)) {
                    _addressErrorText = 'Address is required!';
                    return;
                  } else {
                    _addressErrorText = null;
                  }
                  if (!TextFieldValidation()
                      .passwordValidation(_passwordController.text)) {
                    _passwordErrorText =
                        'Password must be of at least 6 digits!';
                    return;
                  } else {
                    _passwordErrorText = null;
                  }
                  if (_confirmPasswordController.text !=
                      _passwordController.text) {
                    _confirmPasswordErrorText = 'Passwords does not match!';
                    return;
                  } else {
                    _confirmPasswordErrorText = null;
                  }
                  registerUser(context);
                });
              },
              child: Text(
                'REGISTER',
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
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            padding:
                EdgeInsets.only(top: size.width * .1, bottom: size.width * .1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have account?',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: size.width * .038,
                  ),
                ),
                SizedBox(
                  width: size.width * .02,
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Login()));
                  },
                  child: Text(
                    'Get looged in',
                    style: TextStyle(
                      color: Colors.deepOrange,
                      fontSize: size.width * .038,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          )
        ]));
  }

  Future<void> registerUser(BuildContext context) async {
    String date = DateTime.now().millisecondsSinceEpoch.toString();
    try {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return ProgressDialog(
                message: 'Please wait while you are getting registered...');
          });

      if (await DatabaseManager()
              .alreadyRegisteredNumber(_mobileNoController.text) ==
          false) {
        await DatabaseManager()
            .addUser(_usernameController.text, _mobileNoController.text,
                _addressController.text, date, '', _passwordController.text, '')
            .then((value) async {
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('mobileNo', _mobileNoController.text);

          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => RegistrationSuccessful()),
              (route) => false);
        });
      } else {
        Toast().showToast(context, 'Already registered!');
        print('Number already registered!');
        _usernameController.clear();
        _mobileNoController.clear();
        _addressController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
        FocusScope.of(context).unfocus();
        Navigator.pop(context);
      }
    } catch (error) {
      Navigator.pop(context);
      print('Registration data inserting faild for - $error');
    }
  }
}
