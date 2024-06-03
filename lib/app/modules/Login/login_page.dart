// create a stateful widget login page with background image from assets/images/bg_auth.png

// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:async';

import 'package:aquila_hundi/app/helper_widgets/config.dart';
import 'package:aquila_hundi/app/modules/Login/deviceotp_page.dart';
import 'package:aquila_hundi/app/modules/Login/register_page.dart';
import 'package:aquila_hundi/store/app.state.dart';
import 'package:aquila_hundi/store/auth/auth.action.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:aquila_hundi/app/helper_widgets/style.dart';
// import redux store
import 'package:redux/redux.dart';
import 'package:aquila_hundi/app/helper_widgets/circular_loading_overlay.dart';
import 'package:aquila_hundi/app/helper_widgets/states_list.dart';
// import firebase messaging
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';




class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}



class _LoginPageState extends State<LoginPage> {
  // get screen dimensions
  // add text editing controllers
TextEditingController mobileNumberController = TextEditingController();
TextEditingController otpController = TextEditingController();
final _scaffoldKey = GlobalKey<ScaffoldState>();

var messageDisplay = true;
final String firebaseToken = '';
  
  // define currentState of ScaffoldState




@override
void initState() {
  super.initState();
  mobileNumberController.text = '';
  otpController.text = '';
  messageDisplay = true;

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
}

@override
void dispose() {
  mobileNumberController.dispose();
  otpController.dispose();
  super.dispose();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);
}

Future generateFirebaseToken() async {
  // get firebase token
  // generate firebase token
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  String? firebaseToken = await firebaseMessaging.getToken();
  if (firebaseToken != null) {
    // store to redux
    StoreProvider.of<AppState>(context).dispatch(UpdateFirebaseTokenAction(firebaseToken));
    // store to shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('firebaseToken', firebaseToken);

    setState(() {
      firebaseToken = firebaseToken;
    });

  } else {
    print('firebaseToken is null');
  }
}


Future <void> delay10sec() async {
    await Future.delayed(const Duration(seconds: 10), () {
      setState(() {
        messageDisplay = false;
      });
    });
  }




  @override
  Widget build(BuildContext context) {
     SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.orange,
        statusBarIconBrightness: Brightness.dark,
      ));
    return StoreConnector(
      converter: (Store<AppState> store) {
        return _LoginViewModel(
          otpStatus: store.state.authState.otpStatus,
          otp: store.state.authState.otp,
          screenWidth: store.state.commonValuesState.screenWidth,
          screenHeight: store.state.commonValuesState.screenHeight,
          firebaseToken: store.state.authState.firebaseToken,
          isOTPVerified: store.state.authState.isOTPVerified,

        );
        
      },
      builder: (BuildContext context, _LoginViewModel viewModel,) {
    otpController.text = viewModel.otp != 0 ? viewModel.otp.toString() : '';
    final double screenWidth = viewModel.screenWidth;
    final double screenHeight = viewModel.screenHeight;
    final String customerType = StoreProvider.of<AppState>(context).state.authState.customerType;
    final bool loading = StoreProvider.of<AppState>(context).state.authState.loading;
    final String error = StoreProvider.of<AppState>(context).state.authState.error;
    final String firebaseToken = StoreProvider.of<AppState>(context).state.authState.firebaseToken;
    final bool isOTPVerified = StoreProvider.of<AppState>(context).state.authState.isOTPVerified;

    // create timer for 3 seconds
    // Timer(const Duration(seconds: 10), () {
    //   print('Timer executed');
    //   setState(() {
    //     messageDisplay = false;
    //   });
    // });

    Future<void> onButtonClicked() async {
    if (mobileNumberController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 3),
              showCloseIcon: true,
              content: Text('Mobile number cannot be empty'),
            ),
          );
          return;
        }

        // if mobile number is not numeric
    if (!AppFunc.isNumeric(mobileNumberController.text)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 3),
              showCloseIcon: true,
              content: Text('Mobile number should be numeric'),
            ),
          );
          return;
        }

        // check if mobile number is less than 10 digits
    if (mobileNumberController.text.length < 10) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 3),
              showCloseIcon: true,
              content: Text('Mobile number should be 10 digits'),
            ),
          );
          return;
        }
    if (error != 'Already this number logged another device.') {
      // dispatch loading action true
        if (!viewModel.otpStatus) {
        StoreProvider.of<AppState>(context).dispatch(AuthSuccessAction(loading: true)); 
        StoreProvider.of<AppState>(context).dispatch(updateOTP(mobileNumberController.text));
        } else {     
          if (otpController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 3),
                showCloseIcon: true,
                content: Text('OTP cannot be empty'),
              ),
            );
            return;
          }
          // if otp is not numeric
          if (!AppFunc.isNumeric(otpController.text)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 3),
                showCloseIcon: true,
                content: Text('OTP should be numeric'),
              ),
            );
            return;
          }
          // check if otp is less than 6 digits
          if (otpController.text.length < 6) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 3),
                showCloseIcon: true,
                content: Text('OTP should be 6 digits'),
              ),
            );
            return;
          }

          // dispatch loading action true
          StoreProvider.of<AppState>(context).dispatch(AuthSuccessAction(loading: true));
          // dispatch verify otp
          final int otp = otpController.text.isNotEmpty ? int.parse(otpController.text) : 0;
          StoreProvider.of<AppState>(context).dispatch(verifyOtp(
            mobileNumberController.text, 
            otp, ));

            // if (customerType == 'New') {
            //   // navigate to register page
            //   Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       builder: (context) => const RegisterPage(),
            //     ),
            //   );
            // } else if (customerType == 'Existing') {
            //   // check if otp is empty
            //       print('existing customer');
            //   }
        } 
        } else if (error == 'Already this number logged another device.'){          
          // set loading true
          // logout devices
          StoreProvider.of<AppState>(context).dispatch(AuthSuccessAction(loading: true));
          // logout other devices
          StoreProvider.of<AppState>(context).dispatch(logout(mobileNumberController.text));

        }
}

print('FirebaseToken: $firebaseToken');

if (isOTPVerified && customerType == 'New') {
  // change isOTPVerified to false
  StoreProvider.of<AppState>(context).dispatch(UpdateOTPVerifiedAction(false));
  // wait for scaffold to be mounted
  // create async function
  Future.delayed(Duration.zero, () {
    // navigate to register page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RegisterPage(),
      ),
    );
  });
  // navigate to register page
}

if (isOTPVerified && customerType == 'Existing') {
  // change isOTPVerified to false
  StoreProvider.of<AppState>(context).dispatch(UpdateOTPVerifiedAction(false));
  // set loading true
  Future.delayed(Duration.zero, () {
    // navigate to register page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OTPScreen(),
      ),
    );
  });
  // wait for scaffold to be mounted
  // create async function
  // navigate to register page
}



// if (error.isNotEmpty) {
//   // show dialog
//   //wait till scaffold is mounted
//   // create async function
//   Future.delayed(Duration.zero, () {
//     popUpDialog(context, 'Error', error);
//   });
// }


// if (messageDisplay == true) {
//   Future <void> delay10sec() async {
//     await Future.delayed(const Duration(seconds: 10), () {
//       setState(() {
//         messageDisplay = false;
//       });
//     });
//   }
//   delay10sec();
// }


if (error == 'Invalid OTP') {
  // show dialog
  //wait till scaffold is mounted
  // create async function
  Future.delayed(Duration.zero, () {
    popUpDialog(context, 'Error', error);
  });
  // remove error
  StoreProvider.of<AppState>(context).dispatch(AuthFailedAction(error: ''));
}




    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AppConfig.isPortrait(context) ? const AssetImage('assets/images/bg_auth.png') : const AssetImage('assets/images/bg_auth_web.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: 
        Center(
          child: ListView(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: screenHeight * 0.1),
                  ),
                  Image.asset(
                    'assets/images/ic_hundi_logo.png',
                    width: AppConfig.isPortrait(context) ? screenWidth * 0.2 : screenWidth * 0.1,
                  ),
                ],
              ),
              // if portrait mode add sizedbox of height screenHeight * 0.1
              if (AppConfig.isPortrait(context))
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.15),
                ),
              Column(
                // add textinput fields
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: screenHeight * 0.1),
                  ),
                  SizedBox(
                    height: AppConfig.isPortrait(context) ? AppConfig.size(context, 60) : AppConfig.size(context, 100),
                    width: AppConfig.isPortrait(context) ? screenWidth * 0.8 : screenWidth * 0.5,
                    child: AppStyle.textField(
                    context, TextInputType.number, 'Mobile Number *',
                    inputFormatters: [LengthLimitingTextInputFormatter(10)],
                    controller: mobileNumberController,
                    iconName: 'phone',
                    iconColor: Colors.orange,
                    borderColor: Colors.orange,
                    ),
                  ),
                  if (viewModel.otpStatus)
                  SizedBox(
                    height: AppConfig.isPortrait(context) ? AppConfig.size(context, 60) : AppConfig.size(context, 100),
                    width: AppConfig.isPortrait(context) ? screenWidth * 0.8 : screenWidth * 0.5,
                    child: AppStyle.textField(
                    context, TextInputType.number, 'OTP *',
                    inputFormatters: [LengthLimitingTextInputFormatter(6)],
                    controller: otpController,
                    iconName: 'lock',
                    iconColor: Colors.orange,
                    borderColor: Colors.orange,
                    ),
                  ),
                if (error == 'Already this number logged another device.')
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(10),
                      width: AppConfig.isPortrait(context) ? screenWidth * 0.8 : screenWidth * 0.5,
                      child: Text(
                        '$error Do you want to logout from other device?',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.only(top: screenHeight * 0.02),
                  ),
                  
                  if (loading) const CircularLoadingOverlay() else
                  // logout button
                  SizedBox(
                    width: AppConfig.isPortrait(context) ? screenWidth * 0.5 : screenWidth * 0.3,
                    child: ElevatedButton.icon(
                      icon: 
                      error != '' ? const Icon(Icons.error) :
                      (viewModel.otpStatus && customerType == 'New' ? const Icon(Icons.person_add) : viewModel.otpStatus && customerType == 'Existing' ? const Icon(Icons.lock_open) : const Icon(Icons.lock_reset)),
                      label: error != '' ? const Text('Logout Other Device') : 
                      (viewModel.otpStatus && customerType == 'New' ? const Text('Register') : viewModel.otpStatus && customerType == 'Existing' ? const Text('Login') :
                      const Text('Generate OTP')),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: AppColors.primaryColor,
                        backgroundColor: 
                        error == 'Already this number logged another device.' ? Colors.red :
                        (viewModel.otpStatus ? Colors.green[700] :
                         AppColors.secondaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32.0),
                        ),
                      ),
                      onPressed: () {
                        onButtonClicked();
                      },
                      ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: screenHeight * 0.02),
                  ),
                  if (messageDisplay)
                     Container(
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(10),
                      width: AppConfig.isPortrait(context) ? screenWidth * 0.8 : screenWidth * 0.5,
                      child: const Text(
                        'MSME message will be displayed here. MSME message will be displayed here. MSME message will be displayed here.',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.only(top: screenHeight * 0.02),
                  ),
     
                ],
              ),
            
            ],
          ),
        ),
      ),
    );
  }
  );
  }
}


class _LoginViewModel {
  final bool otpStatus;
  final int otp;
  final double screenWidth;
  final double screenHeight;
  final String firebaseToken;
  final bool isOTPVerified;

  _LoginViewModel({
    required this.otpStatus,
    required this.otp,
    required this.screenWidth,
    required this.screenHeight,
    required this.firebaseToken,
    required this.isOTPVerified,
  });
}

Future<void> popUpDialog(
  BuildContext context, String title, String message) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}


// create a function that waits for 10 sec and gives response
Future delayResponse() async {
  await Future.delayed(const Duration(seconds: 10), () {
    return 'OK';
  });
}



