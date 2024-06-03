// ignore_for_file: use_build_context_synchronously

import 'package:aquila_hundi/app/helper_widgets/config.dart';
import 'package:aquila_hundi/app/helper_widgets/style.dart';
import 'package:aquila_hundi/store/app.state.dart';
import 'package:aquila_hundi/store/auth/auth.action.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  OTPScreenState createState() => OTPScreenState();
}


class OTPScreenState extends State<OTPScreen> {
  final TextEditingController otpController = TextEditingController();
  final TextEditingController confirmOtpController = TextEditingController();


  @override
  void initState() {
    super.initState();
    // get customer details
    // get customer details from redux
  }

  @override
  Widget build(BuildContext context) {
     SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.orange,
        statusBarIconBrightness: Brightness.dark,
      ));
    return StoreConnector <AppState, Store<AppState>>(
      converter: (store) => store,
      builder: (BuildContext context, store) {

        final String contactName = store.state.authState.contactName != '' ? store.state.authState.contactName : '';
        final double screenHeight = store.state.commonValuesState.screenHeight;
        final double screenWidth = store.state.commonValuesState.screenWidth;
        final String deviceOtp = store.state.authState.deviceOtp != '' ? store.state.authState.deviceOtp : '';
        final int mobileNumber = store.state.authState.mobileNumber != 0 ? store.state.authState.mobileNumber : 0;

        Future<void> onLoginClicked() async {
          if (otpController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 3),
              showCloseIcon: true,
                content: Text('Please enter OTP'),
              ),
            );
            return;
          }
          if (deviceOtp == ''){
          if (confirmOtpController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 3),
              showCloseIcon: true,
                content: Text('Please enter Confirm OTP'),
              ),
            );
            return;
          }
        

          if (otpController.text != confirmOtpController.text) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 3),
              showCloseIcon: true,
                content: Text('OTP and Confirm OTP should be same'),
              ),
            );
            return;
          }
           SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('deviceOtp', otpController.text);
          // store to redux
          store.dispatch(UpdateDeviceOTP(otpController.text));
          
          // navigate to dashboard
          Navigator.pushNamed(context, '/dashboard');

          }

          if (deviceOtp != '' ) {
            if (otpController.text != deviceOtp) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 3),
              showCloseIcon: true,
                content: Text('Invalid OTP'),
              ),
            );
            return;
            }
            print('continue to dashboard');
            // navigate to dashboard
            Navigator.pushNamed(context, '/dashboard');

          }

          // store otp to local storage
         
        }

        print('deviceOtp: $deviceOtp');

        Future<void> onForgotOtpClicked() async {
          // logout
          store.dispatch(logout(mobileNumber.toString()));
          // navigate to login page
          Navigator.pushNamed(context, '/login');
        }
  
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg_auth.png'),
            fit: BoxFit.cover,
            ),
            ),
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ListView(
                children:[
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Welcome $contactName !',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        deviceOtp == '' ? 'Create Device OTP' : 'Enter Device OTP',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                    height: AppConfig.isPortrait(context) ? AppConfig.size(context, 60) : AppConfig.size(context, 100),
                    width: AppConfig.isPortrait(context) ? screenWidth * 0.8 : screenWidth * 0.5,
                    child: AppStyle.textField(
                    context, TextInputType.number, 'OTP *',
                    inputFormatters: [LengthLimitingTextInputFormatter(4)],
                    controller: otpController,
                    iconName: 'lock',
                    iconColor: Colors.orange,
                    borderColor: Colors.orange,
                    obscureText: true
                    ),
                  ),
                  if (deviceOtp == '')
                      SizedBox(
                    height: AppConfig.isPortrait(context) ? AppConfig.size(context, 60) : AppConfig.size(context, 100),
                    width: AppConfig.isPortrait(context) ? screenWidth * 0.8 : screenWidth * 0.5,
                    child: AppStyle.textField(
                    context, TextInputType.number, 'Confirm OTP *',
                    inputFormatters: [LengthLimitingTextInputFormatter(4)],
                    controller: confirmOtpController,
                    iconName: 'lock',
                    iconColor: Colors.orange,
                    borderColor: Colors.orange,
                    obscureText: true
                    ),
                  ),
                  if(deviceOtp != '') 
                  TextButton(
                    onPressed: () {
                      onForgotOtpClicked();
                    },
                    child: const Text(
                      'Forgot OTP ?',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 14,
                      ),
                    ),
                  ),
                      SizedBox(
                      width: AppConfig.isPortrait(context) ? screenWidth * 0.5 : screenWidth * 0.3,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.lock_open),
                        label: const Text('Login'),
                        onPressed: () {
                           onLoginClicked();
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: AppColors.primaryColor,
                          backgroundColor: Colors.green[700],
                          padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                          textStyle: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    ],
                  ),
                ],
            ),
      ),
        ),
        );
      },
    );
  }
}