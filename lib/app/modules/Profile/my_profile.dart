import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:aquila_hundi/app/helper_widgets/appbar.dart';
import 'package:aquila_hundi/app/helper_widgets/bottom_navigation.dart';
import 'package:aquila_hundi/app/helper_widgets/config.dart';
import 'package:aquila_hundi/app/modules/Login/login_page.dart';
import 'package:aquila_hundi/store/app.state.dart';
import 'package:aquila_hundi/store/auth/auth.action.dart';
import 'package:aquila_hundi/store/myProfile/myProfile.action.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:redux/redux.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});

  @override
  MyProfilePageState createState() => MyProfilePageState();
}

class MyProfilePageState extends State<MyProfilePage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int screenIndex = -1;
  TextEditingController contactNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  String validationMessage = "";
  bool sellerBuyerSwitch = false;
  bool paymentInvoiceApproveSwitch = false;
  bool pageLoaded = false;
  final picker = ImagePicker();
  Image image = Image.asset('assets/images/profile-empty.png');
  bool newImagePicked = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    contactNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void openDrawer() {
    scaffoldKey.currentState!.openDrawer();
  }

  void onEditProfilePage() {}

  @override
  Widget build(BuildContext context) {
    if (StoreProvider.of<AppState>(context)
            .state
            .dashboardState
            .customerCurrentScreen ==
        'Buyer') {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Color.fromARGB(255, 47, 14, 138),
        statusBarIconBrightness: Brightness.light,
      ));
    } else {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.orange,
        statusBarIconBrightness: Brightness.dark,
      ));
    }

    if (newImagePicked) {
      newImagePicked = false;
      // upload image
      // convert image to base64
      var imageInBytes = image.image as FileImage;
      var imageBytes = imageInBytes.file.readAsBytesSync();
      var imageBase64 = base64Encode(imageBytes);
      StoreProvider.of<AppState>(context)
          .dispatch(updateProfileImage(imageBase64));
    }

    return StoreConnector<AppState, Store<AppState>>(
        converter: (store) => store,
        builder: (BuildContext context, store) {
          final screenWidth = MediaQuery.of(context).size.width;
          final customerCurrentScreen =
              store.state.dashboardState.customerCurrentScreen;
          final customerData = store.state.authState.customerData;
          final loading = store.state.myProfileState.loading;

          if (pageLoaded == false) {
            contactNameController.text = customerData['ContactName'] ?? "";
            emailController.text = customerData['Email'] ?? "";
            phoneController.text = customerData['Mobile'] ?? "";
            if (customerCurrentScreen == 'Seller') {
              paymentInvoiceApproveSwitch =
                  customerData['IfSellerUserPaymentApprove'] == true
                      ? true
                      : false;
            } else {
              paymentInvoiceApproveSwitch =
                  customerData['IfBuyerUserInvoiceApprove'] == true
                      ? true
                      : false;
            }
            if (customerData['CustomerCategory'] == "BothBuyerAndSeller") {
              sellerBuyerSwitch = true;
            } else {
              sellerBuyerSwitch = false;
            }
            pageLoaded = true;
          }

          // find if this path exists ${AppConfig.rootUrl}/APP_API/Customer_Image/${customerData['File_Name']}

          return Scaffold(
            key: scaffoldKey,
            appBar: PreferredSize(
              preferredSize:
                  BoxConstraints.tightFor(height: AppConfig.size(context, 45))
                      .smallest,
              child: WidgetHelper.getAppBar(
                  context,
                  'My profile',
                  openDrawer,
                  customerCurrentScreen == 'Seller'
                      ? Colors.orange
                      : Colors.deepPurple.shade900,
                  onEditProfilePage),
            ),
            bottomNavigationBar: const BottomNavigation(),
            drawer: WidgetHelper.leftNavigationBar(
                context,
                screenIndex,
                customerData['ContactName'],
                customerData['Mobile'],
                customerCurrentScreen == 'Seller'
                    ? Colors.orange
                    : Colors.deepPurple.shade900),
            body: loading
                ? Center(
                    child: Container(
                      decoration:
                          const BoxDecoration(color: Colors.transparent),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: customerCurrentScreen == 'Seller'
                                ? Colors.orange
                                : Colors.deepPurple.shade900,
                          ),
                          const Text('Updating profile')
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(height: AppConfig.size(context, 15)),
                        profileImage(
                            screenWidth, customerCurrentScreen, customerData),
                        formFields(customerCurrentScreen),
                        SizedBox(height: AppConfig.size(context, 20)),
                        switchtoBuyerAndSeller(context, customerCurrentScreen,
                            store, customerData),
                        // customerData['CustomerType'] == 'Owner'
                        //     ? paymentOrInvoiceApproveSwitch(
                        //         customerCurrentScreen, store)
                        //     : const SizedBox(),
                        SizedBox(height: AppConfig.size(context, 20)),
                        updateProfile(customerCurrentScreen, store),
                      ],
                    ),
                  ),
          );
        });
  }

  Future findImageExists(customerData) async {
    var imagePath = File(
        '${AppConfig.rootUrl}/APP_API/Customer_Image/${customerData['File_Name']}');
    var fileExists = imagePath.existsSync();
    return fileExists;
  }

  profileImage(screenWidth, customerCurrentScreen, customerData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: screenWidth * 0.4,
          child: Stack(
            children: [
              Positioned(
                child: Container(
                  width: screenWidth * 0.3,
                  height: screenWidth * 0.3,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: customerData['File_Name'].isNotEmpty &&
                              customerData['File_Name'] != null
                          ? NetworkImage(
                                  '${AppConfig.rootUrl}/APP_API/Customer_Image/${customerData['File_Name']}')
                              as ImageProvider<Object>
                          : const AssetImage('assets/images/profile-empty.png')
                              as ImageProvider<Object>,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              Positioned(
                  top: AppConfig.size(context, 85),
                  left: AppConfig.size(context, 75),
                  child: GestureDetector(
                    onTap: () {
                      showOptions();
                    },
                    child: CircleAvatar(
                      backgroundColor: customerCurrentScreen == 'Seller'
                          ? Colors.orange
                          : Colors.deepPurple.shade900,
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                      ),
                    ),
                  ))
            ],
          ),
        ),
      ],
    );
  }

  Future showOptions() async {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: const Text('Photo Gallery'),
            onPressed: () {
              Navigator.of(context).pop();

              getImageFromGallery(context);
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('Camera'),
            onPressed: () {
              Navigator.of(context).pop();

              getImageFromCamera(context);
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('Delete Image'),
            onPressed: () {
              Navigator.of(context).pop();

              StoreProvider.of<AppState>(context).dispatch(deleteProfileImage);
            },
          ),
        ],
      ),
    );
  }

  Future getImageFromCamera(context) async {
    try {
      //get camera permission
      if (await Permission.camera.isGranted) {
        final pickedFile = await picker.pickImage(source: ImageSource.camera);
        if (pickedFile != null) {
          setState(() {
            image = Image.file(File(pickedFile.path));
            newImagePicked = true;
          });
        } else {}
      } else if (await Permission.camera.isDenied) {
        Map<Permission, PermissionStatus> status = await [
          Permission.camera,
        ].request();

        if (await Permission.camera.isGranted) {
          final pickedFile = await picker.pickImage(source: ImageSource.camera);
          if (pickedFile != null) {
            setState(() {
              image = Image.file(File(pickedFile.path));
              newImagePicked = true;
            });
          } else {}
        }
      } else if (await Permission.camera.isPermanentlyDenied) {
        openAppSettings();
      }
      //get camera permission
    } on Exception catch (e) {
      rethrow;
    }
  }

  Future getImageFromGallery(context) async {
    try {
      //get gallery permission
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt <= 32) {
          /// use [Permissions.storage.status]
          if (await Permission.storage.isGranted) {
            final pickedFile = await picker.pickImage(
              source: ImageSource.gallery,
            );
            if (pickedFile != null) {
              setState(() {
                image = Image.file(File(pickedFile.path));
                newImagePicked = true;
              });
            } else {}
          } else if (await Permission.storage.isDenied) {
            Map<Permission, PermissionStatus> status = await [
              Permission.storage,
            ].request();
            if (await Permission.storage.isGranted) {
              final pickedFile = await picker.pickImage(
                source: ImageSource.gallery,
              );
              if (pickedFile != null) {
                setState(() {
                  image = Image.file(File(pickedFile.path));
                  newImagePicked = true;
                });
              } else {}
            } else {
              openAppSettings();
            }
          } else if (await Permission.storage.isPermanentlyDenied) {
            openAppSettings();
          }
        } else {
          /// use [Permissions.photos.status]
          if (await Permission.photos.isGranted) {
            final pickedFile = await picker.pickImage(
              source: ImageSource.gallery,
            );
            if (pickedFile != null) {
              setState(() {
                image = Image.file(File(pickedFile.path));
                newImagePicked = true;
              });
            } else {}
          } else if (await Permission.photos.isDenied) {
            Map<Permission, PermissionStatus> status = await [
              Permission.photos,
            ].request();
            if (await Permission.photos.isGranted) {
              final pickedFile = await picker.pickImage(
                source: ImageSource.gallery,
              );
              if (pickedFile != null) {
                setState(() {
                  image = Image.file(File(pickedFile.path));
                  newImagePicked = true;
                });
              } else {}
            } else {
              openAppSettings();
            }
          } else if (await Permission.photos.isPermanentlyDenied) {
            openAppSettings();
          }
        }
      } else {
        ///iOS
        /// use [Permissions.photos.status]
        if (await Permission.photos.isGranted) {
          final pickedFile = await picker.pickImage(
            source: ImageSource.gallery,
            imageQuality: 50,
          );
          if (pickedFile != null) {
            // reduce file size and upload
            setState(() {
              image = Image.file(File(pickedFile.path));
              newImagePicked = true;
            });
          } else {}
        } else if (await Permission.photos.isDenied) {
          Map<Permission, PermissionStatus> status = await [
            Permission.photos,
          ].request();
          if (await Permission.photos.isGranted) {
            final pickedFile = await picker.pickImage(
              source: ImageSource.gallery,
            );
            if (pickedFile != null) {
              setState(() {
                image = Image.file(File(pickedFile.path));
                newImagePicked = true;
              });
            } else {}
          } else {
            openAppSettings();
          }
        } else if (await Permission.photos.isPermanentlyDenied) {
          openAppSettings();
        }
      }

      //get gallery permission
    } on Exception catch (e) {
      rethrow;
    }
  }

  formFields(customerCurrentScreen) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: AppConfig.size(context, 30)),
          child: TextFormField(
            controller: contactNameController,
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.person,
                color: customerCurrentScreen == 'Seller'
                    ? Colors.orange
                    : Colors.deepPurple.shade900,
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: customerCurrentScreen == 'Seller'
                      ? Colors.orange
                      : Colors.deepPurple.shade900,
                ),
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey,
                ),
              ),
              floatingLabelAlignment: FloatingLabelAlignment.start,
              floatingLabelStyle: TextStyle(
                  color: customerCurrentScreen == 'Seller'
                      ? Colors.orange
                      : Colors.deepPurple.shade900,
                  fontSize: AppConfig.size(context, 20)),
              labelText: "Contact name",
              labelStyle: const TextStyle(color: Colors.grey),
            ),
          ),
        ),
        SizedBox(height: AppConfig.size(context, 15)),
        Container(
          margin: EdgeInsets.symmetric(horizontal: AppConfig.size(context, 30)),
          child: TextFormField(
            controller: emailController,
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.email,
                color: customerCurrentScreen == 'Seller'
                    ? Colors.orange
                    : Colors.deepPurple.shade900,
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: customerCurrentScreen == 'Seller'
                      ? Colors.orange
                      : Colors.deepPurple.shade900,
                ),
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey,
                ),
              ),
              floatingLabelAlignment: FloatingLabelAlignment.start,
              floatingLabelStyle: TextStyle(
                  color: customerCurrentScreen == 'Seller'
                      ? Colors.orange
                      : Colors.deepPurple.shade900,
                  fontSize: AppConfig.size(context, 20)),
              labelText: "Email Id",
              labelStyle: const TextStyle(color: Colors.grey),
            ),
          ),
        ),
        SizedBox(height: AppConfig.size(context, 15)),
        Container(
          margin: EdgeInsets.symmetric(horizontal: AppConfig.size(context, 30)),
          child: TextFormField(
            readOnly: true,
            controller: phoneController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              LengthLimitingTextInputFormatter(10),
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.phone,
                color: customerCurrentScreen == 'Seller'
                    ? Colors.orange
                    : Colors.deepPurple.shade900,
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey,
                ),
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey,
                ),
              ),
              floatingLabelAlignment: FloatingLabelAlignment.start,
              floatingLabelStyle: TextStyle(
                  color: customerCurrentScreen == 'Seller'
                      ? Colors.orange
                      : Colors.deepPurple.shade900,
                  fontSize: AppConfig.size(context, 20)),
              labelText: "Contact number",
              labelStyle: const TextStyle(color: Colors.grey),
            ),
          ),
        )
      ],
    );
  }

  switchtoBuyerAndSeller(
      context, customerCurrentScreen, Store<AppState> store, customerData) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppConfig.size(context, 30)),
      child: CheckboxListTile(
        tristate: false,
        activeColor: customerCurrentScreen == 'Seller'
            ? Colors.orange
            : Colors.deepPurple.shade900,
        title: Text(
          customerCurrentScreen == 'Seller'
              ? "Switch to both seller and buyer"
              : "Switch to both buyer and seller",
          style: TextStyle(
              fontSize: AppConfig.size(context, 17), color: Colors.black),
        ),
        value: sellerBuyerSwitch,
        onChanged: (newValue) async {
          if (customerData['CustomerCategory'] != "BothBuyerAndSeller") {
            setState(() {
              sellerBuyerSwitch = newValue ?? false;
            });
            await store.dispatch(switchtoBothBuyerAndSeller());
            StoreProvider.of<AppState>(context)
                .dispatch(logout(phoneController.text));
            // navigate to login screen
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: customerCurrentScreen == 'Seller'
                        ? Text(
                            'Please verify your mobile number for switching to both seller and buyer',
                            style: TextStyle(
                              fontSize: AppConfig.size(context, 17),
                            ),
                          )
                        : Text(
                            'Please verify your mobile number for switching to both buyer and seller',
                            style: TextStyle(
                              fontSize: AppConfig.size(context, 17),
                            ),
                          ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Close'),
                      ),
                    ],
                  );
                });
            Future.delayed(const Duration(seconds: 3), () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ),
                  (route) => false);
            });
          }
        },
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  paymentOrInvoiceApproveSwitch(customerCurrentScreen, Store<AppState> store) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppConfig.size(context, 30)),
      child: CheckboxListTile(
        tristate: false,
        activeColor: customerCurrentScreen == 'Seller'
            ? Colors.orange
            : Colors.deepPurple.shade900,
        title: Text(
          customerCurrentScreen == 'Seller'
              ? "Allow user to approve payment"
              : "Allow user to approve invoice",
          style: TextStyle(fontSize: AppConfig.size(context, 17)),
        ),
        value: paymentInvoiceApproveSwitch,
        onChanged: (newValue) {
          setState(() {
            paymentInvoiceApproveSwitch = newValue ?? false;
          });
        },
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  updateProfile(customerCurrentScreen, Store<AppState> store) {
    return GestureDetector(
      onTap: () {
        if (checkValidation()) {
          store.dispatch(updateMyProfileData(contactNameController.text,
              emailController.text, phoneController.text));
        } else {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Error'),
                  content: Text(validationMessage),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Close'),
                    ),
                  ],
                );
              });
        }
      },
      child: Container(
          padding: EdgeInsets.all(AppConfig.size(context, 10)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: customerCurrentScreen == 'Seller'
                ? Colors.orange
                : Colors.deepPurple.shade900,
          ),
          child: Text(
            'Update profile',
            style: TextStyle(
                color: Colors.white,
                fontSize: AppConfig.size(context, 20),
                fontWeight: FontWeight.bold),
          )),
    );
  }

  checkValidation() {
    if (contactNameController.text == "") {
      setState(() {
        validationMessage = "Contact name is required";
      });

      return false;
    } else if (emailController.text == "") {
      setState(() {
        validationMessage = "Email id is required";
      });

      return false;
    } else if (!AppFunc.validateEmail(emailController.text)) {
      setState(() {
        validationMessage = "Please enter valid email id";
      });
      return false;
    } else if (phoneController.text == "") {
      setState(() {
        validationMessage = "Contact number is required";
      });
      return false;
    }

    return true;
  }
}
