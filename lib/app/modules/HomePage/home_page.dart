// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:aquila_hundi/app/helper_widgets/navigation_drawer.dart';
import 'package:aquila_hundi/store/app.state.dart';
import 'package:aquila_hundi/store/auth/auth.action.dart';
import 'package:aquila_hundi/store/auth/auth.reducer.dart';
import 'package:aquila_hundi/store/business/business.action.dart';
import 'package:aquila_hundi/store/commonValues/commonvalues.reducer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:aquila_hundi/app/modules/Login/login_page.dart';
import 'package:aquila_hundi/app/modules/Login/register_page.dart';
import 'package:aquila_hundi/app/modules/Login/deviceotp_page.dart';
import 'package:aquila_hundi/app/modules/Dashboard/dashboard_page.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:aquila_hundi/store/commonValues/commonvalues.action.dart';
import 'package:device_info/device_info.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';




class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {

  // get device info
  String deviceID = '';
  String deviceType = '';
  String firebaseToken = '';
  String contactName = '';
  int loadNow = 0;

  @override
  void initState() {
    super.initState();
    getDeviceID();
    getCustomerDetails();
  }


  Future getCustomerDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // get customerDetails from the device storage which is Map value
    final Map<String, dynamic> customerData;
    final String deviceOtp = prefs.getString('deviceOtp') ?? '';
    if (deviceOtp != '') {
      // store to redux
      StoreProvider.of<AppState>(context).dispatch(UpdateDeviceOTP(deviceOtp));
    }
    if (prefs.getString('customerData') != null) {
      customerData = json.decode(
        prefs.getString('customerData') ?? '{}',
      );
    } else {
      customerData = {};
    }
    if (customerData.isEmpty) {
      // get customer details
      // generate customer details
      return;

    } else {
      // store to redux
      StoreProvider.of<AppState>(context).dispatch(UpdateOwnerDetails(
        customerData['ContactName'] ?? '',
        customerData['Email'] ?? '',
        customerData['CustomerCategory'] ?? '',
        customerData['State'] ?? '',
      ));
    }
    StoreProvider.of<AppState>(context).dispatch(UpdateCustomerData(customerData));
    StoreProvider.of<AppState>(context).dispatch(UpdateFirebaseTokenAction(customerData['Firebase_Token']));
    final int mobileNumber = int.parse(customerData['Mobile']);
    StoreProvider.of<AppState>(context).dispatch(UpdateMobileNumberAction(mobileNumber));
    // fetch industrylist
    StoreProvider.of<AppState>(context).dispatch(getIndustryList);
    setState(() {
      firebaseToken = customerData['Firebase_Token'] ?? '';
      contactName = customerData['ContactName'] ?? '';
    });
  }
  

  // 
  Future getDeviceID() async {
    if (kIsWeb){
      print('working here');
      deviceID = 'web';
        print('deviceID: $deviceID');
        StoreProvider.of<AppState>(context).dispatch(UpdateDeviceIDAction(deviceID));
        StoreProvider.of<AppState>(context).dispatch(UpdateDeviceTypeAction('web'));
    } else {
      final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final AndroidDeviceInfo build = await deviceInfoPlugin.androidInfo;
        deviceID = build.androidId;

        // store to redux
        StoreProvider.of<AppState>(context).dispatch(UpdateDeviceIDAction(deviceID));
        StoreProvider.of<AppState>(context).dispatch(UpdateDeviceTypeAction('Android'));
      } else if (Platform.isIOS) {
        final IosDeviceInfo data = await deviceInfoPlugin.iosInfo;
        deviceID = data.identifierForVendor;
        // store to redux
        StoreProvider.of<AppState>(context).dispatch(UpdateDeviceIDAction(deviceID));
        StoreProvider.of<AppState>(context).dispatch(UpdateDeviceTypeAction('iOS'));
      } else if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
        deviceID = 'web';
        print('deviceID inside: $deviceID');
        StoreProvider.of<AppState>(context).dispatch(UpdateDeviceIDAction(deviceID));
        StoreProvider.of<AppState>(context).dispatch(UpdateDeviceTypeAction('web'));
      }
  }
  }



  @override
  Widget build(BuildContext context) {

    // get screen dimensions
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    StoreProvider.of<AppState>(context).dispatch(UpdateScreenWidthAction(screenWidth));
    StoreProvider.of<AppState>(context).dispatch(UpdateScreenHeightAction(screenHeight));

  // wait till firebase token is retrieved from storage and return
// if (loadNow == 0) {

  if (firebaseToken == '') {
    //navigate to login page
    Future.delayed(Duration.zero, () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    });
  } else if(contactName == '') {
    //navigate to register page
    Future.delayed(Duration.zero, () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RegisterPage()),
      );
    });
  }  else{
    //navigate to dashboard page
    Future.delayed(Duration.zero, () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashBaordPage()),
        //MaterialPageRoute(builder: (context) => const NavigationDrawerApp()),
      );
    }
    );
  }



  return const Scaffold(
    body: Center(
      child: CircularProgressIndicator(),
    ),
  );
} 
// else {
// return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Aquila Hundi',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       // routes of all pages
//         // if firebase token is not available, show login page
//         initialRoute: '/login',
//         // initialRoute: firebaseToken == '' ? '/login' 
//         // : contactName == '' ? '/register' : '/deviceotp',
//         routes: 
//         {
//           '/login': (context) => const LoginPage(),
//           '/register': (context) => const RegisterPage(),
//           '/deviceotp': (context) =>  const OTPScreen(),
//           '/dashboard': (context) => const DashBaordPage(),
//         },
//     );
//   }
//   }

  
}

