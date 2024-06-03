// ignore_for_file: use_build_context_synchronously

import 'dart:math';

import 'package:aquila_hundi/app/helper_widgets/appbar.dart';
import 'package:aquila_hundi/app/helper_widgets/bottom_navigation.dart';
import 'package:aquila_hundi/app/helper_widgets/config.dart';
import 'package:aquila_hundi/app/modules/Dashboard/dashboard_page.dart';
import 'package:aquila_hundi/store/app.state.dart';
import 'package:aquila_hundi/store/business/business.action.dart';
import 'package:aquila_hundi/store/dashboard/dashboard.action.dart';
import 'package:aquila_hundi/store/invite/invite.action.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';


class InviteHistoryPage extends StatefulWidget {
  const InviteHistoryPage({super.key});

  @override
  InviteHistoryPageState createState() => InviteHistoryPageState();
}

class InviteHistoryPageState extends State<InviteHistoryPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController buyerContactNameController = TextEditingController();
  TextEditingController buyerMobileNumberController = TextEditingController();
  TextEditingController allowedCreditLimitController = TextEditingController();
  TextEditingController paymentCycleDaysController = TextEditingController();

  int screenIndex = -1;
  int selectedScreenIndex = 1;
  String sellerBusiness = '';
  String paymentType = '';
  bool startLoading = true;
  List inviteHistoryListLocal = [];
  String buyerBusiness = '';



  @override
  void initState() {
    super.initState();
    buyerMobileNumberController.addListener(() {
      if (buyerMobileNumberController.text.length == 10) {
        StoreProvider.of<AppState>(context).dispatch(getCustomerFromMobileNumber({
          'Mobile': int.parse(buyerMobileNumberController.text),
          'CustomerCategory': StoreProvider.of<AppState>(context).state.dashboardState.customerCurrentScreen == 'Seller' ? 'Buyer' : 'Seller',
        }));
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    buyerContactNameController.dispose();
  }

  void openDrawer() {
    print('openDrawer');
    scaffoldKey.currentState!.openDrawer();
  }


  convertAmount(amount) {
      if (amount.toString().length > 5 && amount.toString().length < 8) {
        var value = amount / 100000;
        value = value.toStringAsFixed(3);
        return '$value L';
      } else  if (amount.toString().length > 7) {
        var value = amount / 10000000;
        value = value.toStringAsFixed(3);
        return '$value Cr';
      } else
      {
        return amount;
      }
    }

  customerCard(invoiceHistoryListLocal, screenWidth) {
    return  Card(
      color: invoiceHistoryListLocal['Invite_Status'] == 'Pending' ? Colors.orange.shade100 : invoiceHistoryListLocal['Invite_Status'] == 'Pending_Approval' ? Colors.red.shade200: invoiceHistoryListLocal['Invite_Status'] == 'Reject' ? Colors.red.shade200:  Colors.green.shade100,
      child: 
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>
        [
           ListTile(
            title: Text(invoiceHistoryListLocal['ContactName'].toUpperCase()),
            subtitle: Text(invoiceHistoryListLocal['Mobile'].toString()),
          ),
          Row (
          children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('To: ${(invoiceHistoryListLocal['BuyerBusiness']['FirstName'] + ' ' + invoiceHistoryListLocal['BuyerBusiness']['LastName']).toUpperCase()}'),
                        Text('From: ${(invoiceHistoryListLocal['Business']['FirstName'] + ' ' + invoiceHistoryListLocal['BuyerBusiness']['LastName']).toUpperCase()}'),
                        Text('Request Date: ${DateFormat('dd MMM yyyy').format(DateTime.parse(invoiceHistoryListLocal['createdAt']))}'),
                      ],
                    ),
                  
                ),
              ),
            
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Credit Limit: ₹${convertAmount(invoiceHistoryListLocal['BuyerCreditLimit'])}'),
                    Text('Credit Type: ${invoiceHistoryListLocal['BuyerPaymentType']}'),
                    Text('Payment Cycle: ${invoiceHistoryListLocal['BuyerPaymentCycle']} Days'),
                  ],
                ),
              ),
            ),
            
          ],
        ),
        ],
      ),
    );
      
      
      // ListTile(
      //   title: const Text('Customer Name - Invite Status'),
      //   subtitle: const Text('Mobile Number'),
      //   leading: SizedBox(
      //     width: screenWidth * 0.3,
      //     child: const Column(
      //       children: <Widget>[
      //         Text('To: Buyer Business Name'),
      //         Text('Your Business Name'),
      //         Text('Request Date'),
      //       ],
          
      //     ),
      //   ),
      //   trailing: const Column(
      //     children: <Widget>[
      //       Text('Credit Limit'),
      //       Text('Credit Type'),
      //       Text('Payment Cycle'),
      //     ],
      //   ),
        
      // ),
    //);
  }

     Future openAddBuyerPopUp() async {
          await Future.delayed(const Duration(milliseconds: 100));
          showDialog(
            context: context, 
            builder: (BuildContext context) {
              return StoreConnector<AppState, Store<AppState>>(
                converter: (store) => store,
                builder: (BuildContext context, store) {
              final myBusinessList = store.state.businessState.myBusinessList;
              final customerData = store.state.authState.customerData;
              final customerFromMobileNumber = store.state.inviteState.customerFromMobileNumber;
              final customerBusinessList = store.state.businessState.customerBusinessList;
              final customerCurrentScreen = store.state.dashboardState.customerCurrentScreen;

              return 
              AlertDialog(
                title: customerCurrentScreen == 'Seller' ? const Text('Invite Buyer') : const Text('Invite Seller'),
                content:  Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        DropdownButtonFormField(
                          decoration: InputDecoration(
                            hintText: 'Select Business',
                            contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.orange),
                            ),
                          ),
                          items: myBusinessList.map((e) {
                            return DropdownMenuItem(
                              value: e['_id'],
                              child: Text(e['FirstName'].toString()),
                            );
                          }).toList(),
                          onChanged: (value) {
                            print('value: $value');
                            if (customerCurrentScreen == 'Seller') {
                            setState(() {
                              sellerBusiness = value.toString();
                            });
                            } else {
                              setState(() {
                                buyerBusiness = value.toString();
                              });
                            }
                            // store.dispatch(UpdateInviteData(inviteData: e));
                          },
                          validator: (value) => value == null ? 'Please select Business' : null,
                        ),
                        const SizedBox(height: 10),

                        TextFormField(
                          controller: buyerMobileNumberController,
                          // allow only numbers
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: customerCurrentScreen == 'Seller' ? 'Buyer Mobile Number' : 'Seller Mobile Number',
                            contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.orange),
                            ),
                          ),
                          validator: (value) => value!.isEmpty ?(customerCurrentScreen == 'Seller' ? 'Please enter Buyer Mobile Number' : 'Please enter Seller Mobile Number') : null,
                        ),
                        const SizedBox(height: 10),
                         TextFormField(
                          controller: buyerContactNameController,
                          // if customerFromMobileNumber is not empty then disable editing
                          enabled: customerFromMobileNumber.isNotEmpty ? false : true,
                          decoration: InputDecoration(
                            hintText: customerFromMobileNumber.isNotEmpty ? (customerFromMobileNumber['ContactName']).toUpperCase() : (customerCurrentScreen == 'Seller' ? 'Buyer Name' : 'Seller Name'),
                            contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.orange),
                            ),
                          ),
                          validator: (value) => customerFromMobileNumber.isEmpty && value!.isEmpty ? (customerCurrentScreen == 'Seller' ? 'Please enter Buyer Name' : 'Please enter Seller Name') : null,
                        ),
                        const SizedBox(height: 10),
                        if (customerBusinessList.isNotEmpty)
                        // dropdown with buyer business name
                        DropdownButtonFormField(
                          decoration: InputDecoration(
                            hintText: customerCurrentScreen == 'Seller' ?  'Select Buyer Business' : 'Select Seller Business',
                            contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.orange),
                            ),
                          ),
                          items: customerBusinessList.map((e) {
                            return DropdownMenuItem(
                              value: e['_id'],
                              child: Text(e['FirstName'].toString()),
                            );
                          }).toList(),
                          onChanged: (value) {
                            print('value: $value');
                            if (customerCurrentScreen == 'Seller') {
                            setState(() {
                              buyerBusiness = value.toString();
                            });
                            } else {
                              setState(() {
                                sellerBusiness = value.toString();
                              });
                            }
                            // store.dispatch(UpdateInviteData(inviteData: e));
                          },
                          validator: (value) => value == null ? (customerCurrentScreen == 'Seller' ? 'Please select Buyer Business' : 'Please select Seller Business') : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: allowedCreditLimitController,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            prefix: const Text('₹'),
                            hintText: 'Allowed Credit Limit',
                            contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.orange),
                            ),
                          ),
                          validator: (value) => value!.isEmpty ? 'Please enter Credit Limit' : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: paymentCycleDaysController,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Payment Cycle',
                            suffix: const Text('Days'),
                            contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.orange),
                            ),
                          ),
                          validator: (value) => value!.isEmpty ? 'Please enter Payment Cycle Days' : null,
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField(
                          decoration: InputDecoration(
                            hintText: 'Select Credit Type',
                            contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.orange),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Cash',
                              child: Text('Cash'),
                            ),
                            DropdownMenuItem(
                              value: 'Cheque',
                              child: Text('Cheque'),
                            ),
                            DropdownMenuItem(
                              value: 'Online',
                              child: Text('Online'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              paymentType = value.toString();
                            });
                          },
                          validator: (value) => value == null ? 'Please select Credit Type' : null,
                        )
                      ],
                    ),
                  ),
                ),
                actions: <Widget>[
                ElevatedButton(
                    onPressed:
                      () {
                        if (formKey.currentState!.validate()) {
                          formKey.currentState!.save();
                          if (customerCurrentScreen == 'Seller') {
                          store.dispatch(inviteBuyer({
                            'InviteCategory': 'Buyer',
                            'Seller': customerData['_id'],
                            'InviteType': customerFromMobileNumber.isNotEmpty ? 'Existing' : 'New',
                            'Mobile': int.parse(buyerMobileNumberController.text),
                            'BuyerCreditLimit': double.parse(allowedCreditLimitController.text),
                            'BuyerPaymentCycle': int.parse(paymentCycleDaysController.text),
                            'BuyerPaymentType': paymentType,
                            'Business': sellerBusiness,
                            'ContactName': customerFromMobileNumber.isNotEmpty ? customerFromMobileNumber['ContactName'] : buyerContactNameController.text,
                            'Buyer': customerFromMobileNumber.isNotEmpty ? customerFromMobileNumber['_id'] : '',
                            'BuyerBusiness': buyerBusiness != '' ? buyerBusiness : '',

                          }));
                          } else {
                            // same action function for both seller and buyer invite
                            store.dispatch(inviteBuyer({
                              'InviteCategory': 'Seller',
                              'Buyer': customerData['_id'],
                              'InviteType': customerFromMobileNumber.isNotEmpty ? 'Existing' : 'New',
                              'Mobile': int.parse(buyerMobileNumberController.text),
                              'BuyerCreditLimit': double.parse(allowedCreditLimitController.text),
                              'BuyerPaymentCycle': int.parse(paymentCycleDaysController.text),
                              'BuyerPaymentType': paymentType,
                              'Business': sellerBusiness != '' ? sellerBusiness : '',
                              'ContactName': customerFromMobileNumber.isNotEmpty ? customerFromMobileNumber['ContactName'] : buyerContactNameController.text,
                              'Seller': customerFromMobileNumber.isNotEmpty ? customerFromMobileNumber['_id'] : '',
                              'BuyerBusiness': buyerBusiness != '' ? buyerBusiness : '',
                            }));
                          }
                          Navigator.pop(context);

                        }
                      },
                    child: const Text('Invite'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
      
                ],
              );
            
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
        final screenWidth = MediaQuery.of(context).size.width;

        final creditLimitError = store.state.inviteState.editCreditError;
        final creditLimitSuccess = store.state.inviteState.editCreditSuccess;
        final myBusinessList = store.state.businessState.myBusinessList;
        final businessListLoaded = store.state.businessState.businessListLoaded;
        final bool inviteBuyerSuccess = store.state.inviteState.inviteBuyerSuccess;
        final String inviteBuyerError = store.state.inviteState.error;
        final inviteHistoryList = store.state.inviteState.inviteHistoryList;
        final loading = store.state.inviteState.loading;
        final inviteHistoryListLoaded = store.state.inviteState.inviteHistoryListLoaded;
        final mobileNumberVerified = store.state.inviteState.mobileNumberVerified;

        final customerFromMobileNumber = store.state.inviteState.customerFromMobileNumber;
        final customerBusinessList = store.state.businessState.customerBusinessList;


        if (customerFromMobileNumber.isNotEmpty && customerBusinessList.isEmpty && mobileNumberVerified) {
          store.dispatch(UpdateMobileNumberVerified(mobileNumberVerified: false));
          store.dispatch(getCustomerBusinessList(customerFromMobileNumber['_id'], 'Buyer'));
        }




        if (inviteHistoryList.isEmpty && startLoading) {
          startLoading = false;
          store.dispatch(getInviteHistoryList);
        }

        if (myBusinessList.isEmpty && businessListLoaded == 0) {
          store.dispatch(UpdateBusinessListLoaded(businessListLoaded: 2));
          store.dispatch(getMyBusinessList);
        }


        if (inviteHistoryList.isNotEmpty && inviteHistoryListLocal.isEmpty && selectedScreenIndex == 1) {
          inviteHistoryListLocal = inviteHistoryList.where((element) => element['Invite_Status'] == 'Pending_Approval').toList();;
        }




      if (inviteBuyerSuccess == true) {
        store.dispatch(UpdateInviteBuyerSuccess(inviteBuyerSuccess: false));
        Future inviteBuyerSuccessPopup() async {
          await Future.delayed(const Duration(milliseconds: 100));
          showDialog(
            context: context, 
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Success'),
                content: const Text('Buyer Invited Successfully'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      store.dispatch(getInviteHistoryList);
                      store.dispatch(getInviteList);
                      Navigator.pop(context);
                    },
                    child: const Text('Ok'),
                  ),
                ],
              );
            },
          );
        }
        inviteBuyerSuccessPopup();
      }



      // if (inviteBuyerSuccess == true) {
      //   store.dispatch(UpdateInviteBuyerSuccess(inviteBuyerSuccess: false));
      //   Fluttertoast.showToast(
      //     msg: '🎉 Buyer Invited Successfully 🎉',
      //     toastLength: Toast.LENGTH_SHORT,
      //     gravity: ToastGravity.CENTER,
      //     timeInSecForIosWeb: 1,
      //     backgroundColor: Colors.green,
      //     textColor: Colors.white,
      //     fontSize: 16.0,
      //   );
      // }

      if (inviteBuyerError != '') {
        store.dispatch(InviteFailedAction(error: ''));
        Future inviteBuyerErrorPopup() async {
          await Future.delayed(const Duration(milliseconds: 100));
          showDialog(
            context: context, 
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Message!'),
                content: Text(inviteBuyerError),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Ok'),
                  ),
                ],
              );
            },
          );
        }
        inviteBuyerErrorPopup();
      }

        void openAddSellerPopUp() {
        }



        return Scaffold(
          key: scaffoldKey,
          appBar: PreferredSize(
            preferredSize: BoxConstraints.tightFor(height: AppConfig.size(context, 45)).smallest,
            child: WidgetHelper.getAppBar(context, 'Invite History', openDrawer, customerCurrentScreen == 'Seller' ? Colors.orange : Colors.deepPurple.shade900, openAddBuyerPopUp),
          ),
          bottomNavigationBar: const BottomNavigation(),
          drawer: WidgetHelper.leftNavigationBar(context, screenIndex, customerData['ContactName'], customerData['Mobile'], customerCurrentScreen == 'Seller' ? Colors.orange : Colors.deepPurple.shade900),
          body: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    color: selectedScreenIndex == 1 ? (customerCurrentScreen == 'Seller' ? Colors.orange.shade800 : Colors.blue.shade800) : Colors.grey.shade600,
                    width: screenWidth/4,
                    height: AppConfig.size(context, 70),
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Center(child: 
                      TextButton(
                        onPressed: () {
                            setState(() {
                            selectedScreenIndex = 1;
                            inviteHistoryListLocal = inviteHistoryList.where((element) => element['Invite_Status'] == 'Pending_Approval').toList();
                          });
                        },
                        child: const FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Column(children: 
                          <Widget>[
                            Text('Pending', style: TextStyle(color: Colors.white)),
                            Text('Approval', style: TextStyle(color: Colors.white))
                            ]
                            )
                            )
                      )
                      )
                      )
                    ),
                    Container(
                    color: selectedScreenIndex == 2 ? (customerCurrentScreen == 'Seller' ? Colors.orange.shade800 : Colors.blue.shade800) : Colors.grey.shade600,
                    width: screenWidth/4,
                    height: AppConfig.size(context, 70),
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Center(child: 
                      TextButton(
                        onPressed: () {
                          setState(() {
                            selectedScreenIndex = 2;
                            inviteHistoryListLocal = (inviteHistoryList.where((element) => element['Invite_Status'] == 'Pending').toList());
                          });
                          
                        },
                        child: const FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Column(children: 
                          <Widget>[
                            Text('Pending', style: TextStyle(color: Colors.white)),
                            Text('Installation', style: TextStyle(color: Colors.white))
                            ]
                            )
                            )
                      )
                      )
                      )
                    ),
                    Container(
                    color: selectedScreenIndex == 3 ? (customerCurrentScreen == 'Seller' ? Colors.orange.shade800 : Colors.blue.shade800) : Colors.grey.shade600,
                    width: screenWidth/4,
                    height: AppConfig.size(context, 70),
                    child:  Padding(
                      padding: const EdgeInsets.all(5),
                      child: Center(child: 
                      TextButton(
                        child: const FittedBox(child: Text('Accepted', style: TextStyle(color: Colors.white))),
                        onPressed: () {
                          setState(() {
                            selectedScreenIndex = 3;
                            inviteHistoryListLocal = inviteHistoryList.where((element) => element['Invite_Status'] == 'Accept').toList();
                          });
                        },
                      )
                      ))
                    ),
                    Container(
                    color: selectedScreenIndex == 4 ? (customerCurrentScreen == 'Seller' ? Colors.orange.shade800 : Colors.blue.shade800) : Colors.grey.shade600,
                    width: screenWidth/4,
                    height: AppConfig.size(context, 70),
                    child:  Padding(
                      padding: const EdgeInsets.all(5),
                      child: Center(
                        child: 
                        TextButton(
                          onPressed: () {
            
                            setState(() {
                              selectedScreenIndex = 4;
                              inviteHistoryListLocal = inviteHistoryList.where((element) => element['Invite_Status'] == 'Reject').toList();
                            });
                          },
                          child: const FittedBox(child: Text('Rejected', style: TextStyle(color: Colors.white)))
                        )
                        )
                      )
                    ),
                ],
              ),
              if (loading) const Center(child: CircularProgressIndicator()) 
              else if (inviteHistoryListLoaded  && inviteHistoryListLocal.isNotEmpty)
              Expanded(
                child:ListView.builder(
                  itemCount: inviteHistoryListLocal.length,
                  itemBuilder: (BuildContext context, index) {
                      if (index != inviteHistoryListLocal.length){
                        return customerCard(inviteHistoryListLocal[index], screenWidth);
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),

                        );
                      }
                    },
                   ),
                  ) 
                  else if (inviteHistoryListLoaded && inviteHistoryListLocal.isEmpty)
                  // no data with any icon
                  const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.error, size: 50, color: Colors.grey),
                        Text('No Data Found', style: TextStyle(color: Colors.grey, fontSize: 20)),
                      ],
                    ),
                  ),

            ],
          ),
        );
      },  
    );
  }
}

