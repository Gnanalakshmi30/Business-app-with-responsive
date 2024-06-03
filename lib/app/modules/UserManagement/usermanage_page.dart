
// ignore_for_file: use_build_context_synchronously

import 'dart:math';

import 'package:aquila_hundi/app/helper_widgets/appbar.dart';
import 'package:aquila_hundi/app/helper_widgets/bottom_navigation.dart';
import 'package:aquila_hundi/app/helper_widgets/config.dart';
import 'package:aquila_hundi/app/modules/Dashboard/dashboard_page.dart';
import 'package:aquila_hundi/store/app.state.dart';
import 'package:aquila_hundi/store/auth/auth.action.dart';
import 'package:aquila_hundi/store/business/business.action.dart';
import 'package:aquila_hundi/store/dashboard/dashboard.action.dart';
import 'package:aquila_hundi/store/payments/payments.action.dart';
import 'package:aquila_hundi/store/payments/payments.reducer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:date_picker_plus/date_picker_plus.dart';
import 'package:intl/intl.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:image_picker/image_picker.dart';


class UserManagePage extends StatefulWidget {
  const UserManagePage({super.key});
  @override
  UserManagePageState createState() => UserManagePageState();
}

class UserManagePageState extends State<UserManagePage> {
 final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
 ScrollController scrollController = ScrollController();
int screenIndex = -1;
List selectedBusinesses = [];
List<String> selectedBusinessNames = [];

TextEditingController contactNameController = TextEditingController();
TextEditingController mobileController = TextEditingController();

 @override
 void initState() {
   super.initState();
  }

@override
void dispose() {
  scrollController.dispose();
  super.dispose();
}

 void openDrawer() {
    scaffoldKey.currentState!.openDrawer();
  }

void onBusinessListChange(value, myBusinessList) {
  selectedBusinessNames = value;
  var selectedBusinessesIds = [];
  for (var i = 0; i < value.length; i++) {
    var business = myBusinessList.firstWhere((element) => element['FirstName'] == value[i]);
    selectedBusinessesIds.add({
      'Business': business['_id'],
    });
  }
  selectedBusinesses = selectedBusinessesIds;
}

showdialogPopUp(String title, String content) {
      showDialog(
      context: context, 
      builder: 
      (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              }, 
              child: const Text('OK')
            ),
          ],
        );
      }
      );

}

onAddUserClick() {

    // call add user api
    StoreProvider.of<AppState>(context).dispatch(createUserServer({
      'contactName': contactNameController.text,
      'mobile': mobileController.text,
      'businesses': selectedBusinesses,
    
    }));
    loadingPopUp(context, 'create');
}

onEditUserClick(user) {
    // call add user api
    StoreProvider.of<AppState>(context).dispatch(editUserServer({
      'userId': user['_id'],
      'businesses': selectedBusinesses,
    }));
    loadingPopUp(context, 'edit');
}


  Future onAddClickUserManagement() async {
          await Future.delayed(const Duration(milliseconds: 100));
          showDialog(
            context: context, 
            builder: (BuildContext context) {
              return StoreConnector<AppState, Store<AppState>>(
                converter: (store) => store,
                builder: (BuildContext context, store) {
                  final myBusinessList = store.state.businessState.myBusinessList;
                  return AlertDialog(
                    title: const Text('Add User'),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                           TextField(
                            controller: contactNameController,
                            decoration: const InputDecoration(
                              labelText: 'Contact Name',
                            ),
                          ),
                           TextField(
                            controller: mobileController,
                            // allow only numbers and limit to 10
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Mobile',
                            ),
                          ),
                          // if myBusinessList is not empty show multi selection dropdown
                          if (myBusinessList.isNotEmpty)
                            DropdownSearch<String>.multiSelection(
                              // mode is not available on new dropdown only popupprops
                              popupProps: const PopupPropsMultiSelection.menu(
                                showSearchBox: true,
                                showSelectedItems: true,
                                // if selectedbusinesses is not empty show selected businesses
                                

                              ),
                              dropdownDecoratorProps: const DropDownDecoratorProps(
                                
                                dropdownSearchDecoration: InputDecoration(
                                  labelText: 'Select Businesses',
                                ),
                              ),
                              items: myBusinessList.map((e) => e['FirstName'] as String).toList(),
                              // if selectedbusinesses is not empty show selected businesses
                              selectedItems: selectedBusinessNames.isNotEmpty ? selectedBusinessNames : [],
                              onChanged: (value) => {
                                onBusinessListChange(value, myBusinessList)
                              },
                            ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                               if (contactNameController.text.isEmpty) {
                                  // show error dialog
                                showdialogPopUp('Error', 'Contact Name is required');
                              }
                              else if (contactNameController.text.length < 3) {
                                // show error dialog
                                showdialogPopUp('Error', 'Contact Name should be atleast 3 characters');
                              }
                              else if (mobileController.text.isEmpty) {
                                // show error dialog
                                showdialogPopUp('Error', 'Mobile is required');
                              }
                              else if (mobileController.text.length < 10) {
                                // show error dialog
                                showdialogPopUp('Error', 'Mobile should be 10 digits');
                              }
                              else if (selectedBusinesses.isEmpty) {
                                // show error dialog
                                showdialogPopUp('Error', 'Please select at least one business');
                              } else{
                                onAddUserClick();
                                Navigator.of(context).pop();
                              }
                            },
                            child: const Text('Add User'),
                          ),
                          
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          );
        }

  Future onAddEditUserManagement(user) async {
          // set buseinesses
          var businessAndBranches = user['BusinessAndBranches'];
          List<String> selectedBusinessNames2 = [];
          List selectedBusinesses2 = [];
          for (var i = 0; i < businessAndBranches.length; i++) {
            var business = businessAndBranches[i]['Business'];
            var business2 = businessAndBranches[i]['Business'];
            selectedBusinessNames2.add(business['FirstName']);
            selectedBusinesses2.add({
              'Business': business2['_id'],
            });
          }
          setState(() {
            selectedBusinessNames = selectedBusinessNames2;
          });
          
          selectedBusinesses = user['BusinessAndBranches'];
          await Future.delayed(const Duration(milliseconds: 100));
          showDialog(
            context: context, 
            builder: (BuildContext context) {
              return StoreConnector<AppState, Store<AppState>>(
                converter: (store) => store,
                builder: (BuildContext context, store) {
                  final myBusinessList = store.state.businessState.myBusinessList;
                  return AlertDialog(
                    title: const Text('Add User'),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            title: Text(user['ContactName'].toUpperCase()),
                            subtitle: Text(user['Mobile']),
                          ),
                          // if myBusinessList is not empty show multi selection dropdown
                          if (myBusinessList.isNotEmpty)
                            DropdownSearch<String>.multiSelection(
                              // mode is not available on new dropdown only popupprops
                              popupProps: const PopupPropsMultiSelection.menu(
                                showSearchBox: true,
                                showSelectedItems: true,
                                // if selectedbusinesses is not empty show selected businesses
                                

                              ),
                              dropdownDecoratorProps: const DropDownDecoratorProps(
                                
                                dropdownSearchDecoration: InputDecoration(
                                  labelText: 'Selected Businesses',
                                ),
                              ),
                              items: myBusinessList.map((e) => e['FirstName'] as String).toList(),
                              // if selectedbusinesses is not empty show selected businesses
                              selectedItems: selectedBusinessNames.isNotEmpty ? selectedBusinessNames : [],
                              onChanged: (value) => {
                                onBusinessListChange(value, myBusinessList)
                              },
                            ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              if (selectedBusinesses.isEmpty) {
                                // show error dialog
                                showdialogPopUp('Error', 'Please select at least one business');
                              } else{
                                onEditUserClick(user);
                                Navigator.of(context).pop();
                              }
                            },
                            child: const Text('Update User'),
                          ),
                          
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          );
        }

  
  Future<void> loadingPopUp (BuildContext context, String type) async {
    await Future.delayed(const Duration(milliseconds: 100));
    showDialog(
            context: context, 
            builder: (BuildContext context) {
              return StoreConnector<AppState, Store<AppState>>(
                converter: (store) => store,
                builder: (BuildContext context, store) {
                  final userCreateLoading = store.state.authState.userCreateLoading;
                  final userCreateLoaded = store.state.authState.userCreateSuccess;
                  final userCreateSuccess = store.state.authState.userCreateSuccess;
                  final error = store.state.authState.error;
        return 
        userCreateLoading ?
        const AlertDialog(
          title: Text('Loading'),
          content: CircularProgressIndicator(),
        )  : userCreateSuccess ?
        AlertDialog(
          title: const Text('Success'),
          content: type == 'create' ? const Text('User Created Successfully') : const Text('User Updated Successfully'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                store.dispatch(UpdateUserCreateSuccess(false));
                store.dispatch(UpdateUserCreateLoading(false));
                store.dispatch(AuthFailedAction(error: ''));
                selectedBusinessNames = [];
                contactNameController.clear();
                mobileController.clear();
                selectedBusinesses = [];
                Navigator.of(context).pop();
              }, 
              child: const Text('OK')
            ),
          ],
        ) : error.isNotEmpty ?
        AlertDialog(
          title: const Text('Error'),
          content: Text(error),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              }, 
              child: const Text('OK')
            ),
          ],
        )
        : const Center();
        
      }
    );
      }
    );
  } 
        


  @override
  Widget build(BuildContext context) {
     if (StoreProvider.of<AppState>(context).state.dashboardState.customerCurrentScreen == 'Buyer') {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor:  Color.fromARGB(255, 47, 14, 138),
      statusBarIconBrightness: Brightness.light,
    ));
    } else {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.orange,
        statusBarIconBrightness: Brightness.dark,
      ));
    }
    return StoreConnector<AppState, Store<AppState>>(
      converter: (store) => store,
      builder: (BuildContext context, store) {
        final customerCurrentScreen = store.state.dashboardState.customerCurrentScreen;
        final customerData = store.state.authState.customerData;

        final userList = store.state.authState.userList;
        final userListLoaded = store.state.authState.isUserListLoaded;
        final loading = store.state.authState.loading;
        final myBusinessList = store.state.businessState.myBusinessList;
        final businessListLoaded = store.state.businessState.businessListLoaded;


        if (userList.isEmpty && userListLoaded == false) {
          store.dispatch(UpdateUserListLoaded(true));
          store.dispatch(getUserListServer());
        }

        if (myBusinessList.isEmpty && businessListLoaded == 0) {
          store.dispatch(UpdateBusinessListLoaded(businessListLoaded: 2));
          store.dispatch(getMyBusinessList);
        }

        if (selectedBusinesses.isEmpty && myBusinessList.isNotEmpty) {
          for (var element in selectedBusinesses) { 
            var business = myBusinessList.firstWhere((element2) => element2['_id'] == element['Business']);
            selectedBusinesses.add({
              'Business': business['FirstName'],
            });
          }
        }

        return Scaffold(
          key: scaffoldKey,
          appBar: PreferredSize(
            preferredSize:  BoxConstraints.tightFor(height: AppConfig.size(context, 45)).smallest,
            child: WidgetHelper.getAppBar(context, 'Users', openDrawer, customerCurrentScreen == 'Seller' ? Colors.orange : Colors.deepPurple.shade900, onAddClickUserManagement),
          ),
      bottomNavigationBar: const BottomNavigation(),
    drawer: WidgetHelper.leftNavigationBar(context, screenIndex, customerData['ContactName'], customerData['Mobile'], customerCurrentScreen == 'Seller' ? Colors.orange : Colors.deepPurple.shade900),
    body: 
    loading ? const Center(child: CircularProgressIndicator()) :
    userList.isEmpty ? const Center(child: Text('No Users Found')) :
    Center(
      child:ListView.builder(
        // use descending order
        itemCount: userList.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(5),
                color: (customerCurrentScreen == 'Seller' ? Colors.orange.shade100 : Colors.blue.shade100),
            
              ),
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: userList[index]['ContactName'] != null ? Text(userList[index]['ContactName'].toUpperCase()) : const Text(''),
                    subtitle: userList[index]['Mobile'] != null ? Text(userList[index]['Mobile']) : const Text(''),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit_square),
                      onPressed: () {
                        //
                        onAddEditUserManagement(userList[index]);
                      },
                    ),
                  ),
                  // display business list
                  if (userList[index]['BusinessAndBranches'].isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: userList[index]['BusinessAndBranches'].length,
                      itemBuilder: (BuildContext context, int index2) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: Card(
                            child: Column(
                              children: <Widget>[
                                ListTile(
                                  title: Text(userList[index]['BusinessAndBranches'][index2]['Business']['FirstName'].toUpperCase()),
                                  subtitle: userList[index]['BusinessAndBranches'][index2]['Business']['LastName'] != '' ? Text(userList[index]['BusinessAndBranches'][index2]['Business']['LastName']) : const Text('Main Branch'),
                                  leading: const Icon(
                                    Icons.business,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        }
    )
        )
        );
      },
    );
  }
}
