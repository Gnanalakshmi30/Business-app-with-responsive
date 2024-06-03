// ignore_for_file: use_build_context_synchronously

import 'dart:math';

import 'package:aquila_hundi/app/helper_widgets/appbar.dart';
import 'package:aquila_hundi/app/helper_widgets/bottom_navigation.dart';
import 'package:aquila_hundi/app/helper_widgets/config.dart';
import 'package:aquila_hundi/app/modules/Dashboard/dashboard_page.dart';
import 'package:aquila_hundi/store/app.state.dart';
import 'package:aquila_hundi/store/business/business.action.dart';
import 'package:aquila_hundi/store/dashboard/dashboard.action.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:dropdown_search/dropdown_search.dart';




class MyBusinessPage extends StatefulWidget {
  const MyBusinessPage({super.key});

  @override
  MyBusinessPageState createState() => MyBusinessPageState();
}

class MyBusinessPageState extends State<MyBusinessPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    void openDrawer() {
    print('openDrawer');
    scaffoldKey.currentState!.openDrawer();
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
         int screenIndex = -1;
        // create text controller for search
        final TextEditingController searchController = TextEditingController();
        final myBusinessList = store.state.businessState.myBusinessList;
        final customerData = store.state.authState.customerData;
        final String customerCurrentScreen = store.state.dashboardState.customerCurrentScreen;
        final businessLoading = store.state.businessState.loading;
        final businessAddError = store.state.businessState.error;
        final int businessIsSuccess = store.state.businessState.isSuccess;
        final bool businessEditStatus = store.state.businessState.businessEditStatus;
        final int businessListLoaded = store.state.businessState.businessListLoaded;
        final myBusinessListLocal = store.state.businessState.myBusinessListLocal;


        if (myBusinessList.isEmpty && businessListLoaded == 0) {
          store.dispatch(UpdateBusinessListLoaded(businessListLoaded: 2));
          store.dispatch(getMyBusinessList);
        }

        if (myBusinessList.isNotEmpty && myBusinessListLocal.isEmpty) {
          store.dispatch(UpdateMyBusinessListLocal(myBusinessListLocal: myBusinessList));
        }

        // change mybusinesslistlocal only if there is change in mybusinesslist


        // if search is not empty, filter the list
        void filterList(search) {
          if (search != null && search != '') {
            var myBusinessListLocal2 = myBusinessList.where((element) => element['FirstName'].toString().contains(search)).toList();
            store.dispatch(UpdateMyBusinessListLocal(myBusinessListLocal: myBusinessListLocal2));
          } else {
            store.dispatch(UpdateMyBusinessListLocal(myBusinessListLocal: myBusinessList));
          }
        }

      // on edit click open editBusinessModalForm in dialog
      Future editBusinessPopup(business) async {
        await Future.delayed(Duration.zero);

        showDialog(
          context: context,
          builder: (BuildContext context){
            return WidgetHelper.editBusinessModalForm(
              context, 
              business['_id'],
              business['FirstName'],
              business['LastName'],
              // BusinessCreditLimit as double
              business['BusinessCreditLimit'].toDouble(),
              
              business['Industry'],

              
              );
          }
        );
        
      }

      if (businessEditStatus == false && businessAddError.isNotEmpty && businessIsSuccess == 2) {
          store.dispatch(UpdateBusinessAddStatus(businessAddStatus: false));
          store.dispatch(BusinessIssuccessAction(isSuccess: 0));

          Future addBusinessErrorPopup () async {
            await Future.delayed(Duration.zero);
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Error'),
                  content: Text(businessAddError),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Close'),
                    ),
                  ],
                );
              },
            );
          }
          addBusinessErrorPopup();
        }


        if (businessEditStatus == true) {
          store.dispatch(UpdateBusinessEditStatus(businessEditStatus: false));
          store.dispatch(getMyBusinessList);

          // show success message
          Future<void> addBusinessSuccessPopup () async {
            await Future.delayed(Duration.zero);
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Success'),
                  content: const Text('Business updated successfully'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Close'),
                    ),
                  ],
                );
              },
            );
          }
          addBusinessSuccessPopup();

          // close the dialog if businessaddstatus is false

        }

    void onAddClickbusinessPage(){}

  

    return Scaffold(
      key: scaffoldKey,

      appBar: PreferredSize(
            preferredSize:  BoxConstraints.tightFor(height: AppConfig.size(context, 45)).smallest,
            child: WidgetHelper.getAppBar(context, 'My Business', openDrawer, customerCurrentScreen == 'Seller' ? Colors.orange : Colors.deepPurple.shade900, onAddClickbusinessPage),
          ),
      bottomNavigationBar: const BottomNavigation(),
    drawer: WidgetHelper.leftNavigationBar(context, screenIndex, customerData['ContactName'], customerData['Mobile'], customerCurrentScreen == 'Seller' ? Colors.orange : Colors.deepPurple.shade900),

      body:  Center(
        child: 
        businessLoading ?
        const CircularProgressIndicator() :
         myBusinessListLocal.isEmpty
                  ? const Text('No data found')
          :
        SingleChildScrollView(
          child: Column(
            children: <Widget>[
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: DropdownSearch<String>(
                  clearButtonProps: const ClearButtonProps(
                    isVisible: true,
                    color: Colors.orange,
                  ),
                  popupProps: PopupProps.menu(
                    showSelectedItems: true,
                    showSearchBox: true,
                    searchFieldProps: TextFieldProps(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search',
                        contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.orange),
                        ),
                        prefixIcon: const Icon(Icons.search, color: Colors.orange),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            searchController.clear();
                          },
                        ),
                      ),
                    )
                  ),
                  items: myBusinessList.map((e) => e['FirstName'].toString()).toList(),
                  onChanged: (value) {
                    print(value);
                    filterList(value);
                  },
                  dropdownDecoratorProps:  DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      hintText: 'Select Business',
                      contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.orange),
                      ),
                    ),
                    
                  ),
                  
                  
                ),
              ),
              
              
              const SizedBox(height: 20),
              Column(
                children: myBusinessListLocal.map((e) => 
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
                  child: Card(
                    elevation: 2,
                    clipBehavior: Clip.hardEdge,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: Row(
                            children: <Widget>[
                              Text(
                                '${e['FirstName']} ${e['LastName']}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              // edit icon
                              IconButton(
                                icon: const Icon(Icons.edit_square),
                                onPressed: () {
                                  editBusinessPopup(e);
                                },
                              ),
                            ],
                          ),
                          // show total credit limit
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: Text (
                              'Total Credit Limit: ₹ ${e['BusinessCreditLimit']}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ),
                        // show available credit limit
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: Text (
                              'Available Credit Limit: ₹ ${e['AvailableCreditLimit']}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ),
                        // show progress bar for credit limit
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: LinearProgressIndicator(
                            value: e['AvailableCreditLimit'] != 0 && e['BusinessCreditLimit'] != 0 ? e['AvailableCreditLimit'] / e['BusinessCreditLimit'] : 0,
                            backgroundColor: Colors.grey,
                          ),
                        ),
                        // show overdue, due today and upcoming in a row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            // overdue
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: Column(
                                children: <Widget>[
                                  const Text (
                                    'Overdue',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text (
                                    '₹ ${e['OverDueAmount']}',
                                    style:  TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.orange.shade800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // due today
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: Column(
                                children: <Widget>[
                                  const Text (
                                    'Due Today',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text (
                                    '₹ ${e['DueTodayAmount']}',
                                    style:  TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.orange.shade800
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // upcoming
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: Column(
                                children: <Widget>[
                                   Text (
                                    'Upcoming',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.green.shade800,
                                    ),
                                  ),
                                  Text (
                                    '₹ ${e['UpComingAmount']}',
                                    style:  TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green.shade800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                    
                  ),
                )).toList()
              )
            
            
            ],
          ),
        )
     
     
      ),
    );
      }
    );
  }
}

