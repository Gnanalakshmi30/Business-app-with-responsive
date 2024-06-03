// ignore_for_file: use_build_context_synchronously

import 'dart:math';

import 'package:aquila_hundi/app/helper_widgets/appbar.dart';
import 'package:aquila_hundi/app/helper_widgets/bottom_navigation.dart';
import 'package:aquila_hundi/app/helper_widgets/config.dart';
import 'package:aquila_hundi/app/modules/Dashboard/dashboard_page.dart';
import 'package:aquila_hundi/app/modules/InviteHistory/invite_history_page.dart';
import 'package:aquila_hundi/store/app.state.dart';
import 'package:aquila_hundi/store/business/business.action.dart';
import 'package:aquila_hundi/store/dashboard/dashboard.action.dart';
import 'package:aquila_hundi/store/invite/invite.action.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';


class InviteListPage extends StatefulWidget {
  const InviteListPage({super.key});

  @override
  InviteListPageState createState() => InviteListPageState();
}

class InviteListPageState extends State<InviteListPage> {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    String paymentType = 'Cash';
    String sellerBusiness = '';
    int screenIndex = -1;
    int selectedScreenIndex = 1;
    bool startLoading = true;
    List inviteHistoryListLocal = [];
    String buyerBusiness = '';

    TextEditingController buyerContactNameController = TextEditingController();
    TextEditingController buyerMobileNumberController = TextEditingController();
    TextEditingController allowedCreditLimitController = TextEditingController();
    TextEditingController paymentCycleDaysController = TextEditingController();

    



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

    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return StoreConnector<AppState, Store<AppState>>(
      converter: (store) => store,
      builder: (BuildContext context, store) {
        int screenIndex = -1;
        final TextEditingController searchController = TextEditingController();

        final TextEditingController creditLimitController = TextEditingController();
        final TextEditingController paymentCycleController = TextEditingController();

          double overDueValue = 40.00;
          double dueTodayValue = 30.00;
          double upcomingValue = 30.00 ;



        final loading = store.state.inviteState.loading;
        final inviteList = store.state.inviteState.acceptedList;
        final String customerCurrentScreen = store.state.dashboardState.customerCurrentScreen;
        final inviteListLocal = store.state.inviteState.inviteListLocal;
        final bool inviteListLoaded = store.state.inviteState.inviteListLoaded;
        final customerData = store.state.authState.customerData;

        final creditLimitError = store.state.inviteState.editCreditError;
        final creditLimitSuccess = store.state.inviteState.editCreditSuccess;
        final myBusinessList = store.state.businessState.myBusinessList;
        final businessListLoaded = store.state.businessState.businessListLoaded;
        final bool inviteBuyerSuccess = store.state.inviteState.inviteBuyerSuccess;
        final String inviteBuyerError = store.state.inviteState.error;
        final createSendButton = store.state.dashboardState.createSendButton;
        final customerFromMobileNumber = store.state.inviteState.customerFromMobileNumber;
        final customerBusinessList = store.state.businessState.customerBusinessList;
        final mobileNumberVerified = store.state.inviteState.mobileNumberVerified;
        final editRequestFromInvoice = store.state.inviteState.editRequestFromInvoice;
        final editRequestBusinessId = store.state.inviteState.editRequestBuyerId;


        if (customerFromMobileNumber.isNotEmpty && customerBusinessList.isEmpty && mobileNumberVerified) {
          store.dispatch(UpdateMobileNumberVerified(mobileNumberVerified: false));
          store.dispatch(getCustomerBusinessList(customerFromMobileNumber['_id'], customerCurrentScreen == 'Seller' ? 'Buyer' : 'Seller'));
        }
        print('customerbusinesslist: $customerBusinessList');

        if (inviteList.isEmpty && inviteListLoaded == false) {
          store.dispatch(UpdateInviteListLoaded(inviteListLoaded: true));
          store.dispatch(getInviteList);
        }



        if (myBusinessList.isEmpty && businessListLoaded == 0) {
          store.dispatch(UpdateBusinessListLoaded(businessListLoaded: 2));
          store.dispatch(getMyBusinessList);
        }


        if (inviteList.isNotEmpty && inviteListLocal.isEmpty) {
          store.dispatch(UpdateInviteListLocal(inviteListLocal: inviteList));
        }


        void filterList(value) {
          if (value != null && value != '') {
            var inviteListLocal2 = inviteList.where((element) => element['Name'].toString().contains(value)).toList();
            store.dispatch(UpdateInviteListLocal(inviteListLocal: inviteListLocal2));
          } else {
            store.dispatch(UpdateInviteListLocal(inviteListLocal: inviteList));
          }
        }

       
        Future callDirectly() async {
          // if (await canLaunchUrlString('tel:1234567890')) {
          //   await launchUrlString('tel:1234567890');
          // } else {
          //   throw 'Could not launch tel:1234567890';
          // }
        }

        if (creditLimitSuccess) {
          // show pop up
          store.dispatch(UpdateEditCreditSuccess(editCreditSuccess: false));
          // show pop up success message
          Future creditLimitSuccessPopup() async {
          await Future.delayed(const Duration(milliseconds: 100));
          showDialog(
            context: context, 
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Success'),
                content: const Text('Credit Limit Updated Successfully'),
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
          creditLimitSuccessPopup();
        }

        if (creditLimitError != '') {
          // show pop up
          store.dispatch(UpdateEditCreditError(editCreditError: ''));
          // show pop up success message
          Future creditLimitErrorPopup() async {
          await Future.delayed(const Duration(milliseconds: 100));
          showDialog(
            context: context, 
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Error'),
                content: Text(creditLimitError),
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
          creditLimitErrorPopup();
        }

   
     


        Future editCreditLimitPopup(business) async {
          creditLimitController.text = business['TotalCreditLimit'].toString();
          paymentCycleController.text = business['inviteData']['BuyerPaymentCycle'].toString();

          void handleOnPaymentTypeChanged(value) {
            setState(() {
              paymentType = value;
            });
          }

          // store.dispatch(UpdateInviteData(inviteData: e));
          await Future.delayed(const Duration(milliseconds: 100));
          showDialog(
            context: context, 
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Edit Credit Limit'),
                content:  SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(business['Name'].toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      const Text('Current Credit Limit'),
                      TextField(
                        controller: creditLimitController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          prefix: const Text('₹'),
                          hintText: 'Enter Credit Limit',
                          contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.orange),
                          ),
                          // allow only numbers
                          
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text('Payment Cycle Days'),
                      TextField(
                        controller: paymentCycleController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Enter Payment Cycle Days',
                          contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.orange),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text('Payment Type'),
                      DropdownSearch<String>(
                        selectedItem: business['inviteData']['BuyerPaymentType'].toString(),
                        popupProps:  const PopupProps.menu(
                          showSelectedItems: true,
                        ),
                        items: const ['Cash', 'Cheque', 'Online'],
                        dropdownDecoratorProps: DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            hintText: 'Select Payment Type',
                            contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.orange),
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          handleOnPaymentTypeChanged(value);
                        },
                      )
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      store.dispatch(UpdateEditCreditLoading(editCreditLoading: true));
                      store.dispatch(editBusinessCreditLimit({
                        'InviteId': business['inviteData']['InviteId'],
                        'BuyerCreditLimit': double.parse(creditLimitController.text),
                        'BuyerPaymentCycle': int.parse(paymentCycleController.text),
                        'BuyerPaymentType': paymentType,
                        'CustomerId': customerData['_id'],
                        'Business': business['inviteData']['Business']['_id'],
                        'BuyerBusiness': business['inviteData']['BuyerBusiness']['_id'],
                      }));
                     Navigator.pop(context);
                    },
                    child: const Text('Save'),
                  ),
                ],
              );
            },
          );
        }

      if (createSendButton == 'Invite Buyer' || createSendButton == 'Invite Seller') {
        store.dispatch(UpdateCreateSendButton(''));
        openAddBuyerPopUp();   
      }

        if (editRequestFromInvoice && editRequestBusinessId != '') {
          print('inviteListLocal: $inviteListLocal');
          if (inviteListLocal.isEmpty) {
            store.dispatch(getInviteList);
          }
          if (inviteListLocal.isNotEmpty) {
          store.dispatch(UpdateEditRequestFromInvoice(editRequestFromInvoice: false));
          // find buseiness from inviteListlocal
          final editBusiness = inviteListLocal.firstWhere((element) => element['inviteData']['BuyerBusiness']['_id'] == editRequestBusinessId);
          editCreditLimitPopup(editBusiness);
          }
    

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
                content: Text( customerCurrentScreen == 'Seller' ? 'Buyer Invited Successfully' : 'Seller Invited Successfully'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      store.dispatch(getInviteHistoryList);
                      store.dispatch(getInviteList);
                      // navigate to invite history
                      Navigator.push(context, 
                      MaterialPageRoute(builder: (context) => const InviteHistoryPage()));
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

      if (inviteBuyerError != '') {
        store.dispatch(InviteFailedAction(error: ''));
        Future inviteBuyerErrorPopup() async {
          await Future.delayed(const Duration(milliseconds: 100));
          showDialog(
            context: context, 
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Message'),
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

      calculatePercentage(data, type) {
        final  total = data['OverDueAmount'] + data['UpComingAmount'] + data['DueTodayAmount'];
        if (total == 0) {
          return 0;
        }
        if (type == 'OverDue' && data['OverDueAmount'] != 0) {
          return (data['OverDueAmount'] / total) * 100;
        } else if (type == 'DueToday' && data['DueTodayAmount'] != 0) {
          return (data['DueTodayAmount'] / total) * 100;
        } else if (type == 'Upcoming' && data['UpComingAmount'] != 0) {
          return (data['UpComingAmount'] / total) * 100;
        } else {
          return 0;
        }
      }


        return Scaffold(
          key: scaffoldKey,
          appBar: PreferredSize(
            preferredSize:  BoxConstraints.tightFor(height: AppConfig.size(context, 45)).smallest,
            child: WidgetHelper.getAppBar(context, customerCurrentScreen == 'Seller' ? 'Buyer\'s List' : 'Seller\'s List', openDrawer, customerCurrentScreen == 'Seller' ? Colors.orange : Colors.deepPurple.shade900, openAddBuyerPopUp),
          ),
          drawer: WidgetHelper.leftNavigationBar(context, screenIndex, customerData['ContactName'], customerData['Mobile'], customerCurrentScreen == 'Seller' ? Colors.orange : Colors.deepPurple.shade900),
          body: Center(
            child: loading
                ? const CircularProgressIndicator()
                : inviteListLocal.isEmpty
                    ? const Text('No data found')
                    : 
            ListView(
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
                items: inviteList.map((e) => e['Name'].toString()).toList(),
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
              children: inviteListLocal.map((e) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: Card(
                    color: const Color.fromARGB(255, 239, 239, 239),
                    surfaceTintColor: Colors.black,
                    shadowColor: Colors.black,
                    elevation: 2,
                    clipBehavior: Clip.hardEdge,
                    child: Column(
                      children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                            child: Row(
                              children: <Widget>[
                                CircleAvatar(
                                  backgroundColor: Colors.primaries[Random().nextInt(Colors.primaries.length)],
                                  child: Text(e['Name'].toString().substring(0, 1).toUpperCase()),
                                ),
                                const SizedBox(width: 5),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(
                                      width: AppConfig.size(context, 150),
                                      child: Text(e['Name'].toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                                    SizedBox(
                                      width: AppConfig.size(context, 150),
                                      child: Text('Total Credit Limit:  ₹${e['TotalCreditLimit']}')),
                                  ],
                                ),
                                const Spacer(),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    SizedBox(
                                      width: AppConfig.size(context, 150),
                                      child: Text('Available Credit :  ₹${e['AvailableCreditLimit']}')),
                                    SizedBox(
                                      width: AppConfig.size(context, 150),
                                      child: Text('Payment Cycle : ${e['inviteData']['BuyerPaymentCycle']} Days')),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        const Divider(),
                        Row(
                          children: <Widget>[
                            SizedBox(width: AppConfig.isPortrait(context) ? screenWidth * 0.45 : AppConfig.size(context, 30),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: 
                              (e['OverDueAmount'] == null || e['OverDueAmount'] == 0) && (e['UpComingAmount'] == null || e['UpComingAmount'] == 0) && (e['DueTodayAmount'] == null || e['DueTodayAmount'] == 0) ?
                              const Center(child: Text('No Due', style: TextStyle(color: Colors.black, fontSize: 16))) :
                              PieChart(
                                PieChartData(
                                  sections: [
                                    PieChartSectionData(
                                    color: Colors.red,
                                    value: calculatePercentage(e, 'OverDue'),
                                    title: calculatePercentage(e, 'OverDue') + '%',
                                    titleStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: AppConfig.isPortrait(context) ? AppConfig.size(context, 12) : AppConfig.size(context, 14),
                                    ),
                                    radius: 50,
                                  ),
                                  PieChartSectionData(
                                    color: Colors.orange,
                                    value: calculatePercentage(e, 'DueToday'),
                                    title: calculatePercentage(e, 'DueToday') + '%',
                                    titleStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: AppConfig.isPortrait(context) ? AppConfig.size(context, 12) : AppConfig.size(context, 14),
                                    ),
                                    radius: 50,
                                  ),
                                  PieChartSectionData(
                                    color: const Color.fromARGB(255, 1, 90, 4),
                                    value: calculatePercentage(e, 'Upcoming'),
                                    title: calculatePercentage(e, 'Upcoming') + '%',
                                    titleStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: AppConfig.isPortrait(context) ? AppConfig.size(context, 12) : AppConfig.size(context, 14),
                                    ),
                                      radius: 50,
                                    ),
                                  ],
                                ),
                              )
                            ),
                            ),
                            const Spacer(),
                            SizedBox(
                              width: AppConfig.isPortrait(context) ? AppConfig.size(context, 10) : AppConfig.size(context, 30),
                            ),
                            SizedBox(
                              width: AppConfig.isPortrait(context) ? screenWidth * 0.45 : AppConfig.size(context, 30),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      const Icon(Icons.rectangle, color: Colors.red),
                                      const SizedBox(width: 10),
                                      Text('Over Due :  ₹${e['OverDueAmount'] ?? 0}', style: const TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      const Icon(Icons.rectangle, color: Colors.orange),
                                      const SizedBox(width: 10),
                                      Text('Upcoming :  ₹${e['UpComingAmount'] ?? 0}', style: const TextStyle(color: Colors.orange)),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      const Icon(Icons.rectangle, color:  Color.fromARGB(255, 1, 90, 4),),
                                      const SizedBox(width: 10),
                                      Text('Due Today :  ₹${e['DueTodayAmount'] ?? 0}', style: const TextStyle(color:  Color.fromARGB(255, 1, 90, 4),)),
                                    ],
                                  ),
                                ],
              
                            ),
                            )
                            
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            // button to edit credit limit
                            if (customerCurrentScreen == 'Seller')
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange.shade700,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                //store.dispatch(UpdateInviteData(inviteData: e));
                                editCreditLimitPopup(e);
                              },
                              child: const Text('Edit Credit Limit'),
                            ),
                              IconButton(
                              icon: const Icon(Icons.message),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(Icons.call),
                              onPressed: () {
                                callDirectly();
                              },
                            ),
                          

                          ],
                        ),
                        SizedBox(
                          height: AppConfig.size(context, 10),
                        ),
                      ],
                    ),
                  ),
                  
                );
              }).toList(),
            ),
             ],
          ),
          ),
          bottomNavigationBar: const BottomNavigation(),
        );
      },
    );
  }
}
