
import 'dart:async';

import 'package:aquila_hundi/app/helper_widgets/config.dart';
import 'package:aquila_hundi/app/modules/Login/deviceotp_page.dart';
import 'package:aquila_hundi/store/app.state.dart';
import 'package:aquila_hundi/store/auth/auth.action.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:aquila_hundi/app/helper_widgets/style.dart';
import 'package:redux/redux.dart';
import 'package:aquila_hundi/app/helper_widgets/circular_loading_overlay.dart';
import 'package:dropdown_search/dropdown_search.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  RegisterPageState createState() => RegisterPageState();
}


class RegisterPageState extends State<RegisterPage> {

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final List<String> categoryList = ['Buyer', 'Seller', 'Both'];
  var  selectedStateID = '';

  var dropdownValue = 'Select State';
String dropdownCategory = 'Select Category';

  @override
  Widget build(BuildContext context) {
     SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.orange,
        statusBarIconBrightness: Brightness.dark,
      ));

    return StoreConnector<AppState, Store<AppState>>(
      converter: (store) => store,
      builder: (BuildContext context, store) {
    final double screenWidth = StoreProvider.of<AppState>(context).state.commonValuesState.screenWidth;
    final double screenHeight = StoreProvider.of<AppState>(context).state.commonValuesState.screenHeight;
    final int mobileNumber = StoreProvider.of<AppState>(context).state.authState.mobileNumber;
    final String firebaseToken = StoreProvider.of<AppState>(context).state.authState.firebaseToken;
    final List stateList = StoreProvider.of<AppState>(context).state.authState.stateList;
    final bool loading = StoreProvider.of<AppState>(context).state.authState.loading;
    final bool registerSuccess = StoreProvider.of<AppState>(context).state.authState.registerSuccess;
    //stateslist

    if (firebaseToken != '') {
      getStateListServer();
    }

    // create a function to show popup with state list
    Future<void> showStatesList() async {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: AlertDialog(
              title: const Text('Select State'),
              content: SizedBox(
                height: AppConfig.isPortrait(context) ? screenHeight * 0.8 : screenHeight * 0.8,
                width: AppConfig.isPortrait(context) ? screenWidth * 0.8 : screenWidth * 0.8,
                child: ListView.builder(
                  itemCount: stateList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(stateList[index]['State_Name']),
                      onTap: () {
                        setState(() {
                          dropdownValue = stateList[index]['State_Name'];
                          selectedStateID = stateList[index]['_id'];
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ),
          );
        },
      );
    }

    Future<void> showCategoryList() async {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Select Category'),
            content: SizedBox(
              height: AppConfig.isPortrait(context) ? screenHeight * 0.3 : screenHeight * 0.3,
              width: AppConfig.isPortrait(context) ? screenWidth * 0.8 : screenWidth * 0.5,
              child: ListView.builder(
                itemCount: categoryList.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(categoryList[index]),
                    onTap: () {
                      setState(() {
                        dropdownCategory = categoryList[index];
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          );
        },
      );
    }

    Future<void> registerUser() async {
      if (nameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 3),
              showCloseIcon: true,
          content: Text('Please enter your name'),
        ));
        return;
      }

      if (nameController.text.length < 3) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 3),
              showCloseIcon: true,
          content: Text('Name should be atleast 3 characters long'),
        ));
        return;
      }

      if (dropdownValue == 'Select State') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 3),
              showCloseIcon: true,
          content: Text('Please select your state'),
        ));
        return;
      }

      if (dropdownCategory == 'Select Category') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 3),
              showCloseIcon: true,
          content: Text('Please select your category'),
        ));
        return;
      }
    // setloading to true
    StoreProvider.of<AppState>(context).dispatch(AuthSuccessAction(loading: true));

    StoreProvider.of<AppState>(context).dispatch(registerUserServer(
      nameController.text,
      emailController.text,
      dropdownCategory,
      selectedStateID,
    ));
    }      

    if (registerSuccess) {
      store.dispatch(UpdateRegisterSuccess(false));
      Future.delayed(Duration.zero, () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const OTPScreen(),
        ),
      );
      });
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
                Column(
                  children: <Widget>[
                    Padding(padding: 
                      EdgeInsets.only(top: screenHeight * 0.05),
                    ),
                    const Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondaryColor,
                      ),
                    ),
                    Padding(padding: 
                      EdgeInsets.only(top: screenHeight * 0.01),
                    ),
                    SizedBox(
                    height: AppConfig.isPortrait(context) ? AppConfig.size(context, 60) : AppConfig.size(context, 100),
                    width: AppConfig.isPortrait(context) ? screenWidth * 0.8 : screenWidth * 0.5,
                    child: AppStyle.textField(
                    context, TextInputType.number, 'Name *',
                    inputFormatters: [LengthLimitingTextInputFormatter(50)],
                    controller: nameController,
                    iconName: 'person',
                    iconColor: Colors.orange,
                    borderColor: Colors.orange,
                    ),
                  ),
                    SizedBox(
                    height: AppConfig.isPortrait(context) ? AppConfig.size(context, 60) : AppConfig.size(context, 100),
                    width: AppConfig.isPortrait(context) ? screenWidth * 0.8 : screenWidth * 0.5,
                    child: AppStyle.textField(
                    context, TextInputType.number, mobileNumber != 0 ? mobileNumber.toString() : 'Mobile Number *',
                    inputFormatters: [LengthLimitingTextInputFormatter(10)],
                    iconName: 'phone',
                    iconColor: Colors.grey,
                    borderColor: Colors.grey,
                    enabled: false
                    ),
                  ),
                    SizedBox(
                    height: AppConfig.isPortrait(context) ? AppConfig.size(context, 60) : AppConfig.size(context, 100),
                    width: AppConfig.isPortrait(context) ? screenWidth * 0.8 : screenWidth * 0.5,
                    child: AppStyle.textField(
                    context, TextInputType.number, 'Email',
                    inputFormatters: [LengthLimitingTextInputFormatter(50 )],
                    controller: emailController,
                    iconName: 'email',
                    iconColor: Colors.orange,
                    borderColor: Colors.orange,
                    ),
                  ),
                  SizedBox(
                    height: AppConfig.isPortrait(context) ? AppConfig.size(context, 60) : AppConfig.size(context, 100),
                    width: AppConfig.isPortrait(context) ? screenWidth * 0.8 : screenWidth * 0.5,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(30, 0, 30, 20),
                      child: OutlinedButton(
                        onPressed: () {
                          showStatesList();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          side: const BorderSide(color: Colors.orange),
                          alignment: Alignment.centerLeft,
                          textStyle: const TextStyle(
                            color: Colors.orange,
                            fontSize: 16,)
                        ),
                        child: Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.orange),
                              const SizedBox(width: 10),
                              Text(dropdownValue)
                              ]
                          ),
                        
                      ),
                    ),
                  ),
                  SizedBox(
                    height: AppConfig.isPortrait(context) ? AppConfig.size(context, 60) : AppConfig.size(context, 100),
                    width: AppConfig.isPortrait(context) ? screenWidth * 0.8 : screenWidth * 0.5,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(30, 0, 30, 20),
                      child: OutlinedButton(
                        onPressed: () {
                          showCategoryList();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          side: const BorderSide(color: Colors.orange),
                          alignment: Alignment.centerLeft,
                          textStyle: const TextStyle(
                            color: Colors.orange,
                            fontSize: 16,)
                        ),
                        child: Row(
                            children: [
                              const Icon(Icons.category, color: Colors.orange),
                              const SizedBox(width: 10),
                              Text(dropdownCategory)
                              ]
                          ),
                        
                      ),
                    ),
                  ),
                    loading ? const CircularLoadingOverlay() : 
                    SizedBox(
                      width: AppConfig.isPortrait(context) ? screenWidth * 0.5 : screenWidth * 0.3,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Register'),
                        onPressed: () {
                          registerUser();
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
                )
              ],
            ),
          ),
        );
      },
    );
  }
}