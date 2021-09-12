import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_lover/custom_classes/DatabaseManager.dart';
import 'package:pet_lover/custom_classes/toast.dart';
import 'package:pet_lover/demo_designs/text_field_demo.dart';
import 'package:pet_lover/sub_screens/confirm_pass.dart';

class Forgot_pass extends StatefulWidget {
  const Forgot_pass({Key? key}) : super(key: key);

  @override
  _Forgot_passState createState() => _Forgot_passState();
}

class _Forgot_passState extends State<Forgot_pass> {
  TextEditingController _mobileNoController = TextEditingController();
  TextEditingController _otpController = TextEditingController();
  String? _mobileNoErrorText;
  String? _otpErrorText;
  FocusNode _mobileNoFocusNode = FocusNode();
  FocusNode _otpFocusNode = FocusNode();
  String _verificationId = '';
  // bool _loading = false;
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool _mobileNoVisibility = true;
  bool _otpVisibility = false;
  bool _sendingOtpLoading = false;
  bool _verifyOtpLoading = false;

  int _start = 120;

  // @override
  // void dispose() {
  //   _timer.cancel();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            'Forget password',
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
              Navigator.pop(context);
            },
          ),
        ),
        body: _bodyUI(context));
  }

  Widget _bodyUI(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: size.width * .15),
          Icon(
            Icons.phonelink_lock,
            size: size.width * .30,
          ),
          SizedBox(height: size.width * .05),
          Text(
            'FORGET',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          Text(
            'PASSWORD',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          Visibility(
            visible: _mobileNoVisibility,
            child: Container(
              width: size.width,
              padding: EdgeInsets.only(
                left: size.width * .1,
                right: size.width * .1,
                top: size.width * .05,
                bottom: size.width * .05,
              ),
              child: Text(
                'Provide your accounts phone number to reset your password!',
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Visibility(
            visible: _otpVisibility,
            child: Container(
              width: size.width,
              padding: EdgeInsets.only(
                left: size.width * .1,
                right: size.width * .1,
                top: size.width * .05,
                bottom: size.width * .05,
              ),
              child: Text(
                'We are sending an OTP to verify mobile number. Please write down the OTP below.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Visibility(
            visible: _mobileNoVisibility,
            child: Container(
              padding: EdgeInsets.only(
                left: size.width * .05,
                right: size.width * .05,
                top: size.width * .01,
                bottom: size.width * .01,
              ),
              child: TextFieldBuilder().showtextFormBuilder(
                  context,
                  'Mobile number',
                  Icons.phone_android,
                  _mobileNoController,
                  _mobileNoErrorText,
                  false,
                  _mobileNoFocusNode,
                  null),
            ),
          ),
          Visibility(
            visible: _mobileNoVisibility,
            child: Container(
              width: size.width,
              height: size.width * .18,
              padding: EdgeInsets.fromLTRB(
                  size.width * .05, 20.0, size.width * .05, 0.0),
              child: _sendingOtpLoading
                  ? Visibility(
                      visible: _mobileNoVisibility,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                        ],
                      ),
                    )
                  : Visibility(
                      visible: _mobileNoVisibility,
                      child: ElevatedButton(
                        child: Text(
                          'Next',
                          style: TextStyle(
                              fontSize: size.width * .04,
                              fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          _validatePhoneNo(_mobileNoController.text);
                        },
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ))),
                      ),
                    ),
            ),
          ),
          Visibility(
            visible: _otpVisibility,
            child: Container(
              padding: EdgeInsets.only(
                left: size.width * .05,
                right: size.width * .05,
                top: size.width * .05,
                bottom: size.width * .05,
              ),
              child: TextFieldBuilder().showtextFormBuilder(
                  context,
                  'OTP',
                  Icons.security,
                  _otpController,
                  _otpErrorText,
                  false,
                  _otpFocusNode,
                  null),
            ),
          ),
          Container(
            width: size.width,
            height: size.width * .18,
            padding: EdgeInsets.fromLTRB(
                size.width * .05, 0.0, size.width * .05, 20.0),
            child: _verifyOtpLoading
                ? Visibility(
                    visible: _verifyOtpLoading,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                      ],
                    ),
                  )
                : Visibility(
                    visible: _otpVisibility,
                    child: ElevatedButton(
                      child: Text(
                        'Verify',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: size.width * .04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () async {
                        PhoneAuthCredential phoneAuthCredential =
                            PhoneAuthProvider.credential(
                                verificationId: _verificationId,
                                smsCode: _otpController.text);
                        _signInWithCredential(phoneAuthCredential);
                      },
                      style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ))),
                    ),
                  ),
          ),
          Visibility(
            visible: _mobileNoVisibility,
            child: Text('You will be sent an OTP to verify',
                style: TextStyle(
                    fontSize: size.width * .033, color: Colors.grey[600])),
          ),
          Visibility(
            visible: _otpVisibility,
            child: Text('OTP will expired after 2 minutes: $_start sec',
                style: TextStyle(
                    fontSize: size.width * .033, color: Colors.grey[600])),
          )
        ],
      ),
    );
  }

  void _signInWithCredential(PhoneAuthCredential phoneAuthCredential) async {
    setState(() {
      _verifyOtpLoading = true;
    });
    try {
      final _authCredential =
          await _auth.signInWithCredential(phoneAuthCredential);

      setState(() {
        _verifyOtpLoading = false;
      });

      if (_authCredential.user != null) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    Confirm_pass(mobileNo: _mobileNoController.text)));
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _verifyOtpLoading = false;
      });
      Toast().showToast(context, e.message.toString());
    }
  }

  void _validatePhoneNo(String mobileNo) async {
    if (mobileNo.isEmpty || mobileNo.length < 11) {
      _mobileNoErrorText = 'Invalid mobile number!';
      return;
    }
    _mobileNoErrorText = null;
    bool _isRegistered =
        await DatabaseManager().alreadyRegisteredNumber(mobileNo);
    if (_isRegistered) {
      String newMobileNo = '+88$mobileNo';
      print('Credential checking mobile = $newMobileNo');
      _sendOTP(newMobileNo);
    } else {
      Toast().showToast(context, 'Mobile number not registered yet!');
    }
  }

  void _sendOTP(String mobileNo) async {
    setState(() {
      _sendingOtpLoading = true;
    });

    await _auth.verifyPhoneNumber(
        phoneNumber: mobileNo,
        verificationCompleted: (phoneAuthCredential) async {
          setState(() {
            _sendingOtpLoading = false;
            _mobileNoVisibility = false;
            _otpVisibility = true;
          });
        },
        verificationFailed: (verificationFailed) async {
          setState(() {
            _sendingOtpLoading = false;
          });
          Toast().showToast(
              context, 'Verification failed: ${verificationFailed.message}');
        },
        codeSent: (verificationId, resendingToken) async {
          setState(() {
            startTimer();
            _sendingOtpLoading = false;
            _mobileNoVisibility = false;
            _otpVisibility = true;
          });
          this._verificationId = verificationId;
        },
        codeAutoRetrievalTimeout: (verificationId) async {});
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    Timer _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  // Future<void> _OTPVerification(RegAuth regAuth,DoctorProvider operation)async{
  //   FirebaseAuth _auth = FirebaseAuth.instance;
  //   await _auth.verifyPhoneNumber(
  //     phoneNumber: regAuth.doctorDetails.countryCode+regAuth.doctorDetails.phone,
  //     //Automatic verify....
  //     verificationCompleted: (PhoneAuthCredential credential) async{
  //       await _auth.signInWithCredential(credential).then((value) async{
  //         if(value.user!=null){
  //           bool result = await regAuth.registerUser(regAuth.doctorDetails);
  //           if(result){
  //             //save data to local
  //             SharedPreferences pref = await SharedPreferences.getInstance();
  //             pref.setString('id', regAuth.doctorDetails.countryCode+regAuth.doctorDetails.phone);
  //             pref.setStringList('likeId', []);
  //             await operation.getDoctor().then((value)async{
  //               await operation.getHospitals();
  //               Navigator.pop(context);
  //               //regAuth.doctorDetails =null;
  //               Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>HomePage()), (route) => false);
  //             });
  //           }
  //           else{
  //             Navigator.pop(context);
  //             showSnackBar(_scaffoldKey,'Error register doctor. Try again', Colors.deepOrange);
  //           }
  //         }
  //       });
  //     },
  //     verificationFailed: (FirebaseAuthException e){
  //       if (e.code == 'invalid-phone-number') {
  //         Navigator.pop(context);
  //         showSnackBar(_scaffoldKey,'The provided phone number is not valid', Colors.deepOrange);
  //       }
  //     },
  //     codeSent: (String verificationId, int resendToken){
  //       _verificationCode = verificationId;
  //       Navigator.pop(context);
  //       _OTPDialog(regAuth,operation);
  //     },
  //     codeAutoRetrievalTimeout: (String verificationId){
  //       _verificationCode = verificationId;
  //       Navigator.pop(context);
  //       _OTPDialog(regAuth,operation);
  //     },
  //     timeout: Duration(seconds: 120),
  //   );
  // }

  // // ignore: non_constant_identifier_names
  // void _OTPDialog(RegAuth regAuth,DoctorProvider operation){
  //   showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (context) {
  //         Size size=MediaQuery.of(context).size;
  //         return AlertDialog(
  //           scrollable: true,
  //           contentPadding: EdgeInsets.all(20),
  //           title: Text("Phone Verification", style:TextStyle(fontSize: size.width*.04),textAlign: TextAlign.center),
  //           content: Container(
  //             child: Column(
  //               children: [
  //                 SizedBox(height: 20),
  //                 Container(
  //                   child: Text(
  //                     "We've sent OTP verification code on your given number.",
  //                     textAlign: TextAlign.center,
  //                     style: TextStyle(color: Colors.grey[700],fontSize: size.width*.034),
  //                   ),
  //                 ),
  //                 SizedBox(height: 25),
  //                 TextField(
  //                   controller: _otpController,
  //                   keyboardType: TextInputType.number,
  //                   style: TextStyle(fontSize: size.width*.04),
  //                   decoration: FormDecoration.copyWith(
  //                       labelText: "Enter OTP here",
  //                       labelStyle: TextStyle(
  //                         fontSize: size.width*.033,
  //                       ),
  //                       fillColor: Colors.grey[100],
  //                       prefixIcon: Icon(Icons.security)),
  //                 ),
  //                 SizedBox(height: 10),
  //                 Consumer<DoctorProvider>(
  //                   builder: (context, operation, child){
  //                     return GestureDetector(
  //                       onTap: ()async{
  //                         regAuth.loadingMgs = 'Verifying OTP...';
  //                         showLoadingDialog(context, regAuth);
  //                         try{
  //                           await FirebaseAuth.instance.signInWithCredential(PhoneAuthProvider.credential(
  //                               verificationId: _verificationCode, smsCode: _otpController.text)).then((value)async{
  //                             if(value.user!=null){
  //                               bool result = await regAuth.registerUser(regAuth.doctorDetails);
  //                               if(result){

  //                                 //Save data to local
  //                                 SharedPreferences pref = await SharedPreferences.getInstance();
  //                                 pref.setString('id', regAuth.doctorDetails.countryCode+regAuth.doctorDetails.phone);

  //                                 pref.setStringList('likeId', []);
  //                                 //clear all list
  //                                 // operation.clearDoctorList();
  //                                 // operation.clearHospitalList();
  //                                 // operation.clearFaqList();

  //                                 await operation.getDoctor().then((value)async{
  //                                   await operation.getHospitals();
  //                                   Navigator.pop(context);
  //                                   Navigator.pop(context);
  //                                   //regAuth.doctorDetails =null;
  //                                   Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>HomePage()), (route) => false);
  //                                 });
  //                               }
  //                               else{
  //                                 Navigator.pop(context);
  //                                 Navigator.pop(context);
  //                                 showSnackBar(_scaffoldKey,'Error register doctor. Try again', Colors.deepOrange);
  //                               }
  //                             }
  //                           });
  //                         }catch(e){
  //                           Navigator.pop(context);
  //                           Navigator.pop(context);
  //                           showSnackBar(_scaffoldKey,'Invalid OTP', Colors.deepOrange);
  //                         }
  //                       },
  //                       child: Button(context, 'Submit'),
  //                     );
  //                   },
  //                 ),
  //                 SizedBox(height: 15),

  //                 Text('OTP will expired after 2 minutes',style: TextStyle(fontSize: size.width*.033,color: Colors.grey[600]))
  //               ],
  //             ),
  //           ),
  //         );
  //       });
  // }
}
