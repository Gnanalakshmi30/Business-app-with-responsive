// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:aquila_hundi/app/helper_widgets/config.dart';
import 'package:aquila_hundi/app/modules/Calendar/calendar_page.dart';
import 'package:aquila_hundi/app/modules/Dashboard/dashboard_page.dart';
import 'package:aquila_hundi/app/modules/HomePage/home_page.dart';
import 'package:aquila_hundi/app/modules/InviteHistory/invite_history_page.dart';
import 'package:aquila_hundi/app/modules/InviteListPage/invitelist_page.dart';
import 'package:aquila_hundi/app/modules/Login/deviceotp_page.dart';
import 'package:aquila_hundi/app/modules/Login/login_page.dart';
import 'package:aquila_hundi/app/modules/Login/register_page.dart';
import 'package:aquila_hundi/app/modules/MyBusiness/mybusiness_page.dart';
import 'package:aquila_hundi/app/modules/Notifications/notifications_page.dart';
import 'package:aquila_hundi/app/modules/Payments/payments_page.dart';
import 'package:aquila_hundi/app/modules/Support/support_page.dart';
import 'package:aquila_hundi/app/modules/UserManagement/usermanage_page.dart';
import 'package:aquila_hundi/store/app.reducer.dart';
import 'package:aquila_hundi/store/app.state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:aquila_hundi/firebase/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:overlay_support/overlay_support.dart';

// set globalkey for the navigator
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// @pragma('vm:entry-point')
// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   print('Handling a background message ${message.messageId}');
// }

// initializeFirebase() async {
//   try {
//     await Firebase.initializeApp(
//         options: DefaultFirebaseOptions.currentPlatform);
//     AppConfig.fcmToken = await FirebaseMessaging.instance.getToken() ?? "";
//     FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
//     NotificationSettings settings = await firebaseMessaging.requestPermission(
//       alert: true,
//       announcement: true,
//       badge: true,
//       carPlay: false,
//       criticalAlert: true,
//       provisional: false,
//       sound: true,
//     );
//     print('User granted permission: ${settings.authorizationStatus}');
//     configure();
//   } catch (e) {
//     print('Firebase initialization failed: $e');
//     Timer(const Duration(seconds: 2), () {
//       initializeFirebase();
//     });
//   }
// }

// void _handleNotification(RemoteMessage message) async {
//   String? title;
//   String? body;
//   String image;
//   String tag;

//   if (message.notification != null) {
//     title = message.notification?.title;
//     body = message.notification?.body;
//     image = message.notification?.android?.imageUrl ?? "";
//     }
// }

// Future<void> configure() async {
//   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//     print('Got a message whilst in the foreground!');
//     print(message.data);
//     print(
//         'Message data: ${message.notification?.title} ${message.notification?.body} ');

//     if (message.notification != null) {
//       print('Message also contained a notification: ${message.notification}');
//     }
//     _handleNotification(message);
//   });

//   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//     _handleNotification(message);
//   });

//   FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

//   FlutterForegroundTask.init(
//     androidNotificationOptions: AndroidNotificationOptions(
//       channelId: 'notification_channel_id',
//       channelName: 'Foreground Notification',
//       channelDescription:
//       'This notification appears when the foreground service is running.',
//       channelImportance: NotificationChannelImportance.LOW,
//       priority: NotificationPriority.LOW,
//       iconData: const NotificationIconData(
//         resType: ResourceType.mipmap,
//         resPrefix: ResourcePrefix.ic,
//         name: 'launcher',
//         backgroundColor: Colors.orange,
//       ),
//       buttons: [
//         const NotificationButton(id: 'sendButton', text: 'Send'),
//         const NotificationButton(id: 'testButton', text: 'Test'),
//       ],
//     ),
//     iosNotificationOptions: const IOSNotificationOptions(
//       showNotification: true,
//       playSound: false,
//     ),
//     foregroundTaskOptions: const ForegroundTaskOptions(
//       interval: 5000,
//       isOnceEvent: false,
//       autoRunOnBoot: true,
//       allowWakeLock: true,
//       allowWifiLock: true,
//     ),
//   );

// }

late final Store<AppState> store;

Future<void> main() async {
  // await dotenv.load(fileName: '.env');
  // get device id
  // get widgetflutter binding instance
  WidgetsFlutterBinding.ensureInitialized();
  // set default orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // Set status bar color here
    statusBarBrightness: Brightness.light, // Set status bar brightness here
  ));
  //await initializeFirebase();

  store = Store<AppState>(
    appReducer,
    initialState: AppState.initial(),
    middleware: [thunkMiddleware],
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // add status bar color

    return StoreProvider(
      store: store,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Scaffold(
          body: OverlaySupport(
            child: SafeArea(
              child: MaterialApp(
                navigatorKey: navigatorKey,
                debugShowCheckedModeBanner: false,
                title: 'Aquila Hundi',
                theme: ThemeData(
                  colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
                ),
                initialRoute: '/home',
                routes: {
                  '/home': (context) => const HomePage(),
                  '/login': (context) => const LoginPage(),
                  '/register': (context) => const RegisterPage(),
                  '/deviceotp': (context) => const OTPScreen(),
                  '/dashboard': (context) => const DashBaordPage(),
                  '/mybusiness': (context) => const MyBusinessPage(),
                  '/inviteList': (context) => const InviteListPage(),
                  '/payments': (context) => const PaymentsPage(),
                  '/inviteHistory': (context) => const InviteHistoryPage(),
                  '/calendar': (context) => const CalendarPage(),
                  '/userManage': (context) => const UserManagePage(),
                  '/support': (context) => const SupportPage(),
                  '/notifications': (context) => const NotificationsPage(),
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}


// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   State<MyApp> createState() => MyAppState();
// }

// class MyAppState extends State<MyApp> {
//    String deviceID = '';
//   String deviceType = '';
//   String firebaseToken = '';
//   String contactName = '';
//   int loadNow = 0;

//   @override
//   void initState() {
//     super.initState();
//     getDeviceID();
//     getCustomerDetails();
//     delay2Seconds();
//   }

//   Future getCustomerDetails() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     // get customerDetails from the device storage which is Map value
//     final Map<String, dynamic> customerData;
//     final String deviceOtp = prefs.getString('deviceOtp') ?? '';
//     if (deviceOtp != '') {
//       // store to redux
//       StoreProvider.of<AppState>(context).dispatch(UpdateDeviceOTP(deviceOtp));
//     }
//     if (prefs.getString('customerData') != null) {
//       customerData = json.decode(
//         prefs.getString('customerData') ?? '{}',
//       );
//     } else {
//       customerData = {};
//     }
//     if (customerData.isEmpty) {
//       // get customer details
//       // generate customer details
//       return;

//     } else {
//       // store to redux
//       StoreProvider.of<AppState>(context).dispatch(UpdateOwnerDetails(
//         customerData['ContactName'] ?? '',
//         customerData['Email'] ?? '',
//         customerData['CustomerCategory'] ?? '',
//         customerData['State'] ?? '',
//       ));
//     }
//     StoreProvider.of<AppState>(context).dispatch(UpdateCustomerData(customerData));
//     StoreProvider.of<AppState>(context).dispatch(UpdateFirebaseTokenAction(customerData['Firebase_Token']));
//     final int mobileNumber = int.parse(customerData['Mobile']);
//     StoreProvider.of<AppState>(context).dispatch(UpdateMobileNumberAction(mobileNumber));
//     setState(() {
//       firebaseToken = customerData['Firebase_Token'] ?? '';
//       contactName = customerData['ContactName'] ?? '';
//     });
//   }
  

//   // 

//   Future getDeviceID() async {
//     if (kIsWeb){
//       print('working here');
//       deviceID = 'web';
//         print('deviceID: $deviceID');
//         StoreProvider.of<AppState>(context).dispatch(UpdateDeviceIDAction(deviceID));
//         StoreProvider.of<AppState>(context).dispatch(UpdateDeviceTypeAction('web'));
//     } else {
//       final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
//       if (Platform.isAndroid) {
//         final AndroidDeviceInfo build = await deviceInfoPlugin.androidInfo;
//         deviceID = build.androidId;

//         // store to redux
//         StoreProvider.of<AppState>(context).dispatch(UpdateDeviceIDAction(deviceID));
//         StoreProvider.of<AppState>(context).dispatch(UpdateDeviceTypeAction('Android'));
//       } else if (Platform.isIOS) {
//         final IosDeviceInfo data = await deviceInfoPlugin.iosInfo;
//         deviceID = data.identifierForVendor;
//         // store to redux
//         StoreProvider.of<AppState>(context).dispatch(UpdateDeviceIDAction(deviceID));
//         StoreProvider.of<AppState>(context).dispatch(UpdateDeviceTypeAction('iOS'));
//       } else if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
//         deviceID = 'web';
//         print('deviceID inside: $deviceID');
//         StoreProvider.of<AppState>(context).dispatch(UpdateDeviceIDAction(deviceID));
//         StoreProvider.of<AppState>(context).dispatch(UpdateDeviceTypeAction('web'));
//       }
//   }
//   }

//   Future delay2Seconds() async {
//     await Future.delayed(const Duration(seconds: 1));
//     setState(() {
//       loadNow = 1;
//     });
//   }


//   @override
//   Widget build(BuildContext context) {
//     return StoreProvider(
//       store: store, 
//       child: OverlaySupport(
//         child: 
//         loadNow == 0
//           ? 
//         const MaterialApp(
//             home: Scaffold(
//               body: Center(
//                 child: CircularProgressIndicator(),
//               ),
//             ),
//           )
//           :
        
//         SafeArea(
//           child: MaterialApp(
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
//           ),
//         ),
//       ),
//     );
//   }
// }
