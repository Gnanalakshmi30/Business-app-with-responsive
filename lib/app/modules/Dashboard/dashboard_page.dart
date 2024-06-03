// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:ffi';

import 'package:aquila_hundi/app/helper_widgets/appbar.dart';
import 'package:aquila_hundi/app/helper_widgets/bottom_navigation.dart';
import 'package:aquila_hundi/app/helper_widgets/config.dart';
import 'package:aquila_hundi/app/modules/Calendar/calendar_page.dart';
import 'package:aquila_hundi/app/modules/InviteHistory/invite_history_page.dart';
import 'package:aquila_hundi/app/modules/InviteListPage/invitelist_page.dart';
import 'package:aquila_hundi/app/modules/Invoice/invoice_page.dart';
import 'package:aquila_hundi/app/modules/Login/deviceotp_page.dart';
import 'package:aquila_hundi/app/modules/MyBusiness/mybusiness_page.dart';
import 'package:aquila_hundi/app/modules/Payments/payments_page.dart';
import 'package:aquila_hundi/store/app.state.dart';
import 'package:aquila_hundi/store/auth/auth.action.dart';
import 'package:aquila_hundi/store/business/business.action.dart';
import 'package:aquila_hundi/store/commonValues/commonvalues.action.dart';
import 'package:aquila_hundi/store/dashboard/dashboard.action.dart';
import 'package:aquila_hundi/store/invite/invite.action.dart';
import 'package:aquila_hundi/store/invite/invite.reducer.dart';
import 'package:aquila_hundi/store/invoice/invoice.action.dart';
import 'package:aquila_hundi/store/payments/payments.action.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:aquila_hundi/app/helper_widgets/style.dart';
import 'package:redux/redux.dart';
import 'package:aquila_hundi/app/helper_widgets/circular_loading_overlay.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:aquila_hundi/app/helper_widgets/navigation_drawer.dart';

enum UserTypes { buyer, seller }

class DashBaordPage extends StatefulWidget {
  const DashBaordPage({super.key});

  @override
  DashBaordPageState createState() => DashBaordPageState();
}

class DashBaordPageState extends State<DashBaordPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  UserTypes selectedUserType = UserTypes.seller;
  double overDueValue = 40.00;
  double dueTodayValue = 30.00;
  double upcomingValue = 30.00;

  @override
  void initState() {
    getDashboardData();
    super.initState();
  }

  // function to get createsendoptions
  List<DropdownMenuItem> getCreateSendOptions(customerCurrentScreen) {
    return [
      // default value
      const DropdownMenuItem(
        value: '1',
        child: Text('Create / Send '),
      ),
      DropdownMenuItem(
        value: '2',
        child: customerCurrentScreen == 'Seller'
            ? const Text('Invite Buyer')
            : const Text('Invite Seller'),
      ),
      const DropdownMenuItem(
        value: '3',
        child: Text('Create Invoice'),
      ),
      const DropdownMenuItem(
        value: '4',
        child: Text('Create User'),
      ),
      const DropdownMenuItem(
        value: '5',
        child: Text('Create Business'),
      ),
    ];
  }

  Future getDashboardData() async {
    // get dashboard data
    await Future.delayed(Duration.zero, () {
      StoreProvider.of<AppState>(context).dispatch(getDashboardDataAction);
    });
  }

  void openDrawer() {
    scaffoldKey.currentState!.openDrawer();
  }

  // get value from form key
  // print formkey values

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

    return StoreConnector<AppState, Store<AppState>>(
      converter: (store) => store,
      builder: (BuildContext context, store) {
        int screenIndex = -1;

        final double screenWidth = MediaQuery.of(context).size.width;
        final double screenHeight = MediaQuery.of(context).size.height;
        final Map<String, dynamic> customerData =
            store.state.authState.customerData;
        final String customerCurrentScreen =
            store.state.dashboardState.customerCurrentScreen;
        final bool loading = store.state.dashboardState.loading;
        final Map<String, dynamic> dashboardData =
            store.state.dashboardState.dashboardData;
        final bool businessAddStatus =
            store.state.businessState.businessAddStatus;
        final bool businessAddLoading = store.state.businessState.loading;
        final businessAddError = store.state.businessState.error;
        final int businessIsSuccess = store.state.businessState.isSuccess;

        final bool newBusiness = StoreProvider.of<AppState>(context)
            .state
            .dashboardState
            .newBusiness;


        Future onAddBusinessPopup() async {
          await Future.delayed(Duration.zero);
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return WidgetHelper.addBusinessModalForm(
                context,
                'Add Business',
              );
            },
          );
        }

        // change selectedusertype based on customerCurrentScreen
        if (customerCurrentScreen == 'Seller') {
          selectedUserType = UserTypes.seller;
        } else if (customerCurrentScreen == 'Buyer') {
          selectedUserType = UserTypes.buyer;
        }

        if (newBusiness == true) {
          store.dispatch(UpdateNewBusinessStatus(false));
          // show new business dialog
          // find if already a alertdialog is open

          Future<void> addNewBusinessPopup() async {
            await Future.delayed(Duration.zero);
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  // congratulation message for registering, now add new business
                  title: const Text('Woo Hooh! Congratulations!'),
                  content: const Text(
                      'You have successfully registered. Please add your business to continue.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        // close dialog
                        Navigator.of(context).pop();
                      },
                      child: const Text('Close'),
                    ),
                    TextButton(
                      onPressed: () {
                        // add new business
                        Navigator.of(context).pop();
                        onAddBusinessPopup();
                      },
                      child: const Text('Add Business'),
                    ),
                  ],
                );
              },
            );
          }

          addNewBusinessPopup();
        }

        if (customerData.isNotEmpty &&
            customerData['CustomerCategory'].isNotEmpty) {
          if (customerData['CustomerCategory'] == 'Buyer' &&
              customerCurrentScreen != 'Buyer') {
            store.dispatch(DashboardLoadingAction(loading: true));
            store.dispatch(DashboardDataAction(dashboardData: {}));
            store.dispatch(UpdateCustomerCurrentScreen('Buyer'));
            store.dispatch(getDashboardDataAction);
          }
        }

        // if (businessAddLoading == true){
        //   // circular loading
        //   Future<void> addBusinessLoadingPopup () async {
        //     await Future.delayed(Duration.zero);
        //     showDialog(
        //       context: context,
        //       builder: (BuildContext context) {
        //         return const CircularLoadingOverlay();
        //       },
        //     );
        //   }
        //   addBusinessLoadingPopup();

        // }

        if (businessAddStatus == false &&
            businessAddError.isNotEmpty &&
            businessIsSuccess == 2) {
          store.dispatch(UpdateBusinessAddStatus(businessAddStatus: false));
          store.dispatch(BusinessIssuccessAction(isSuccess: 0));

          Future addBusinessErrorPopup() async {
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
                        onAddBusinessPopup();
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

        if (businessAddStatus == true) {
          print('working here');
          store.dispatch(UpdateBusinessAddStatus(businessAddStatus: false));
          store.dispatch(getMyBusinessList);
          // show success message
          Future<void> addBusinessSuccessPopup() async {
            await Future.delayed(Duration.zero);
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Success'),
                  content: const Text('Business added successfully'),
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

        void handleScreenChanged(int selectedScreen) {
          print('selectedScreen: $selectedScreen');
          setState(() {
            screenIndex = selectedScreen;
          });

          if (selectedScreen == 0) {
            store.dispatch(UpdateSelectedBottomNavIndexAction(0));
            // navigate to my business
            Future.delayed(Duration.zero, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyBusinessPage(),
                ),
              );
            });
          }
        }

        if (dashboardData.isNotEmpty) {
          if (dashboardData['OverDueAmount'] != null &&
              dashboardData['DueTodayAmount'] != null &&
              dashboardData['UpComingAmount'] != null) {
            // calculate percentage
            final totalValue = dashboardData['OverDueAmount'] +
                dashboardData['DueTodayAmount'] +
                dashboardData['UpComingAmount'];
            if (totalValue != 0) {
              if (dashboardData['overDueAmount'] != 0) {
                final overDueValue1 =
                    (dashboardData['OverDueAmount'] / totalValue) * 100;
                overDueValue = double.parse(overDueValue1.toStringAsFixed(8));
              } else {
                overDueValue = 0;
              }
              if (dashboardData['DueTodayAmount'] != 0) {
                final dueTodayValue1 =
                    (dashboardData['DueTodayAmount'] / totalValue) * 100;
                dueTodayValue = double.parse(dueTodayValue1.toStringAsFixed(0));
              } else {
                dueTodayValue = 0;
              }
              if (dashboardData['UpComingAmount'] != 0) {
                final upcomingValue1 =
                    (dashboardData['UpComingAmount'] / totalValue) * 100;
                upcomingValue = double.parse(upcomingValue1.toStringAsFixed(0));
              } else {
                upcomingValue = 0;
              }
            }
          }
        }

        void handleCreateSendOptionChange(String value) {
          print('value: $value');
          if (value == '5') {
            // create user
            onAddBusinessPopup();
          }
          if (value == '3') {
            // navigate to invoice page
            store.dispatch(UpdateCreateSendButton('Create Invoice'));
            store.dispatch(UpdateInvoiceStatusType(invoiceStatusType: 'All'));
            store.dispatch(UpdateSelectedBottomNavIndexAction(3));
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const InvoicePage()));
          }

          if (value == '2') {
            // navigate to invite page
            store.dispatch(UpdateCreateSendButton('Invite Buyer'));
            store.dispatch(UpdateSelectedBottomNavIndexAction(1));
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const InviteListPage()));
          }
        }

        void onAddClickDashboardPage() {
          // add business
        }

        // if menu clicked open navigation drawer
        return Scaffold(
          key: scaffoldKey,
          appBar: PreferredSize(
            preferredSize:
                BoxConstraints.tightFor(height: AppConfig.size(context, 45))
                    .smallest,
            child: WidgetHelper.getAppBar(
                context,
                'Dashboard',
                openDrawer,
                selectedUserType == UserTypes.seller
                    ? Colors.orange
                    : Colors.deepPurple.shade900,
                onAddClickDashboardPage,
                notificationCount: dashboardData['NotificationCount'] ?? 0),
          ),
          bottomNavigationBar: const BottomNavigation(),
          drawer: WidgetHelper.leftNavigationBar(
              context,
              screenIndex,
              customerData['ContactName'],
              customerData['Mobile'],
              selectedUserType == UserTypes.seller
                  ? Colors.orange
                  : Colors.deepPurple.shade900),
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: selectedUserType == UserTypes.buyer
                    ? const AssetImage('assets/images/ic_dashboardbg_buyer.png')
                    : const AssetImage(
                        'assets/images/ic_dashboardbg_seller.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: loading || businessAddLoading
                ? const CircularLoadingOverlay()
                : ListView(
                    children: <Widget>[
                      SizedBox(
                        height: AppConfig.isPortrait(context)
                            ? AppConfig.size(context, 10)
                            : AppConfig.size(context, 30),
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Container(
                                padding:
                                    const EdgeInsets.only(left: 10, right: 10),
                                child: SegmentedButton(
                                  style: SegmentedButton.styleFrom(
                                    backgroundColor: selectedUserType ==
                                            UserTypes.seller
                                        ? Colors.blue
                                        : Colors
                                            .orange, // change color with customertype
                                    foregroundColor: Colors.white,
                                    selectedForegroundColor: Colors.white,
                                    selectedBackgroundColor:
                                        selectedUserType == UserTypes.seller
                                            ? Colors.orange.shade600
                                            : Colors.deepPurple.shade900,
                                    surfaceTintColor: Colors.white,
                                    side: const BorderSide(color: Colors.white),
                                    // change color with customertype
                                  ),
                                  segments: const <ButtonSegment<UserTypes>>[
                                    ButtonSegment<UserTypes>(
                                      label: Text('Seller'),
                                      value: UserTypes.seller,
                                    ),
                                    ButtonSegment<UserTypes>(
                                      label: Text('Buyer'),
                                      value: UserTypes.buyer,
                                    ),
                                  ],
                                  selected: <UserTypes>{selectedUserType},
                                  onSelectionChanged: ((
                                    // change selectedusertype
                                    Set<UserTypes> newSelection,
                                  ) {
                                    if (newSelection
                                        .contains(UserTypes.seller)) {
                                      if (customerCurrentScreen != 'Seller') {
                                        setState(() {
                                          selectedUserType = UserTypes.seller;
                                        });
                                        store.dispatch(DashboardLoadingAction(
                                            loading: true));
                                        store.dispatch(BusinessIssuccessAction(
                                            isSuccess: 0));
                                        store.dispatch(DashboardDataAction(
                                            dashboardData: {}));
                                        store.dispatch(
                                            UpdateCustomerCurrentScreen(
                                                'Seller'));
                                        store.dispatch(getDashboardDataAction);
                                        store.dispatch(UpdateMyBusinessList(
                                            myBusinessList: []));
                                        store.dispatch(UpdateAcceptedList(
                                            acceptedList: []));
                                        store.dispatch(UpdateBusinessListLoaded(
                                            businessListLoaded: 0));
                                        store.dispatch(UpdateInviteListLocal(
                                            inviteListLocal: []));
                                        store.dispatch(UpdateInviteListLoaded(
                                            inviteListLoaded: false));
                                        store.dispatch(
                                            UpdateInvoiceList(invoiceList: {}));
                                        store.dispatch(UpdateInvoiceListLocal(
                                            invoiceListLocal: []));
                                        store.dispatch(UpdateInvoiceListLoaded(
                                            invoiceListLoaded: 0));
                                        store.dispatch(UpdateInvoiceStatusType(
                                            invoiceStatusType: 'All'));
                                        store.dispatch(UpdatePaymentsList(
                                            paymentList: {}));
                                        store.dispatch(UpdatePaymentsListLocal(
                                            paymentListLocal: []));
                                        store.dispatch(UpdatePaymentsListLoaded(
                                            paymentListLoaded: 0));
                                        store.dispatch(UpdateInviteHistoryList(
                                            inviteHistoryList: []));
                                        store.dispatch(UpdateUserList([]));
                                        store.dispatch(
                                            UpdateUserListLoaded(false));
                                      }
                                      // seller selected
                                    } else if (newSelection
                                        .contains(UserTypes.buyer)) {
                                      if (customerCurrentScreen != 'Buyer') {
                                        setState(() {
                                          selectedUserType = UserTypes.buyer;
                                        });
                                        store.dispatch(DashboardLoadingAction(
                                            loading: true));
                                        store.dispatch(BusinessIssuccessAction(
                                            isSuccess: 0));
                                        store.dispatch(DashboardDataAction(
                                            dashboardData: {}));
                                        store.dispatch(
                                            UpdateCustomerCurrentScreen(
                                                'Buyer'));
                                        store.dispatch(getDashboardDataAction);
                                        store.dispatch(UpdateMyBusinessList(
                                            myBusinessList: []));
                                        store.dispatch(UpdateAcceptedList(
                                            acceptedList: []));
                                        store.dispatch(UpdateBusinessListLoaded(
                                            businessListLoaded: 0));
                                        store.dispatch(UpdateInviteListLocal(
                                            inviteListLocal: []));
                                        store.dispatch(UpdateInviteListLoaded(
                                            inviteListLoaded: false));
                                        store.dispatch(UpdateInvoiceListLoaded(
                                            invoiceListLoaded: 0));
                                        store.dispatch(UpdateInvoiceStatusType(
                                            invoiceStatusType: 'All'));
                                        store.dispatch(
                                            UpdateInvoiceList(invoiceList: {}));
                                        store.dispatch(UpdateInvoiceListLocal(
                                            invoiceListLocal: []));
                                        store.dispatch(UpdatePaymentsList(
                                            paymentList: {}));
                                        store.dispatch(UpdatePaymentsListLoaded(
                                            paymentListLoaded: 0));
                                        store.dispatch(UpdatePaymentsListLocal(
                                            paymentListLocal: []));
                                        store.dispatch(UpdateInviteHistoryList(
                                            inviteHistoryList: []));
                                        store.dispatch(UpdateUserList([]));
                                        store.dispatch(
                                            UpdateUserListLoaded(false));
                                      }
                                      // buyer selected
                                    }
                                  }),
                                )),
                            Container(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: DropdownButton(
                                items:
                                    getCreateSendOptions(customerCurrentScreen),
                                onChanged: (value) {
                                  // on change value
                                  handleCreateSendOptionChange(value);
                                },
                                value: '1',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: AppConfig.size(context, 17),
                                  fontWeight: FontWeight.w600,
                                ),
                                dropdownColor: Colors.white,
                              ),
                            ),
                          ]),
                      SizedBox(
                        height: AppConfig.isPortrait(context)
                            ? AppConfig.size(context, 20)
                            : AppConfig.size(context, 30),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.5),
                              width: 1,
                            ),
                            //drop shadow
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          width: screenWidth - 20,
                          height: screenHeight / 4,
                          child: Row(
                            children: <Widget>[
                              SizedBox(
                                width: AppConfig.isPortrait(context)
                                    ? screenWidth * 0.45
                                    : AppConfig.size(context, 30),
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: overDueValue == 0 &&
                                          dueTodayValue == 0 &&
                                          upcomingValue == 0
                                      ? const Center(
                                          child: Text('No Data Available'))
                                      : PieChart(
                                          PieChartData(
                                            sections: [
                                              PieChartSectionData(
                                                color: Colors.red,
                                                value: overDueValue,
                                                title: '$overDueValue%',
                                                titleStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontSize:
                                                      AppConfig.isPortrait(
                                                              context)
                                                          ? AppConfig.size(
                                                              context, 12)
                                                          : AppConfig.size(
                                                              context, 14),
                                                ),
                                                radius: 50,
                                              ),
                                              PieChartSectionData(
                                                color: Colors.orange,
                                                value: dueTodayValue,
                                                title: '$dueTodayValue%',
                                                titleStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontSize:
                                                      AppConfig.isPortrait(
                                                              context)
                                                          ? AppConfig.size(
                                                              context, 12)
                                                          : AppConfig.size(
                                                              context, 14),
                                                ),
                                                radius: 50,
                                              ),
                                              PieChartSectionData(
                                                color: const Color.fromARGB(
                                                    255, 1, 90, 4),
                                                value: upcomingValue,
                                                title: '$upcomingValue%',
                                                titleStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontSize:
                                                      AppConfig.isPortrait(
                                                              context)
                                                          ? AppConfig.size(
                                                              context, 12)
                                                          : AppConfig.size(
                                                              context, 14),
                                                ),
                                                radius: 50,
                                              ),
                                            ],
                                          ),
                                        ),
                                ),
                              ),
                              SizedBox(
                                width: AppConfig.isPortrait(context)
                                    ? AppConfig.size(context, 10)
                                    : AppConfig.size(context, 30),
                              ),
                              SizedBox(
                                width: AppConfig.isPortrait(context)
                                    ? screenWidth * 0.40
                                    : AppConfig.size(context, 30),
                                child: SizedBox(
                                  child: InkWell(
                                    onTap: () => {
                                      store.dispatch(UpdateInvoiceStatusType(
                                          invoiceStatusType: 'Overdue')),
                                      store.dispatch(
                                          UpdateSelectedBottomNavIndexAction(
                                              3)),
                                      // navigate to invoice page
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const InvoicePage())),
                                    },
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            const SizedBox(width: 10),
                                            const Icon(Icons.rectangle,
                                                color: Colors.red),
                                            const SizedBox(width: 10),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  'Overdue',
                                                  style: TextStyle(
                                                    fontSize:
                                                        AppConfig.isPortrait(
                                                                context)
                                                            ? AppConfig.size(
                                                                context, 12)
                                                            : AppConfig.size(
                                                                context, 14),
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                                Text(
                                                  dashboardData[
                                                              'OverDueAmount'] !=
                                                          null
                                                      ? '₹ ${dashboardData['OverDueAmount']}'
                                                      : '₹ 0',
                                                  style: TextStyle(
                                                    fontSize:
                                                        AppConfig.isPortrait(
                                                                context)
                                                            ? AppConfig.size(
                                                                context, 12)
                                                            : AppConfig.size(
                                                                context, 14),
                                                    color: Colors.red,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: <Widget>[
                                            const SizedBox(width: 10),
                                            const Icon(Icons.rectangle,
                                                color: Colors.orange),
                                            const SizedBox(width: 10),
                                            InkWell(
                                              onTap: () => {
                                                store.dispatch(
                                                    UpdateInvoiceStatusType(
                                                        invoiceStatusType:
                                                            'Due Today')),
                                                store.dispatch(
                                                    UpdateSelectedBottomNavIndexAction(
                                                        3)),
                                                // navigate to invoice page
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            const InvoicePage())),
                                              },
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    'Due Today',
                                                    style: TextStyle(
                                                      fontSize:
                                                          AppConfig.isPortrait(
                                                                  context)
                                                              ? AppConfig.size(
                                                                  context, 12)
                                                              : AppConfig.size(
                                                                  context, 14),
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Colors
                                                          .orange.shade800,
                                                    ),
                                                  ),
                                                  Text(
                                                    dashboardData[
                                                                'DueTodayAmount'] !=
                                                            null
                                                        ? '₹ ${dashboardData['DueTodayAmount']}'
                                                        : '₹ 0',
                                                    style: TextStyle(
                                                      fontSize:
                                                          AppConfig.isPortrait(
                                                                  context)
                                                              ? AppConfig.size(
                                                                  context, 12)
                                                              : AppConfig.size(
                                                                  context, 14),
                                                      color: Colors
                                                          .orange.shade800,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: <Widget>[
                                            const SizedBox(width: 10),
                                            const Icon(Icons.rectangle,
                                                color: Color.fromARGB(
                                                    255, 1, 90, 4)),
                                            const SizedBox(width: 10),
                                            InkWell(
                                              onTap: () => {
                                                store.dispatch(
                                                    UpdateInvoiceStatusType(
                                                        invoiceStatusType:
                                                            'Upcoming')),
                                                store.dispatch(
                                                    UpdateSelectedBottomNavIndexAction(
                                                        3)),
                                                // navigate to invoice page
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            const InvoicePage())),
                                              },
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    'Upcoming',
                                                    style: TextStyle(
                                                      fontSize:
                                                          AppConfig.isPortrait(
                                                                  context)
                                                              ? AppConfig.size(
                                                                  context, 12)
                                                              : AppConfig.size(
                                                                  context, 14),
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color:
                                                          const Color.fromARGB(
                                                              255, 1, 90, 4),
                                                    ),
                                                  ),
                                                  Text(
                                                    dashboardData[
                                                                'UpcomingAmount'] !=
                                                            null
                                                        ? '₹ ${dashboardData['UpcomingAmount']}'
                                                        : '₹ 0',
                                                    style: TextStyle(
                                                      fontSize:
                                                          AppConfig.isPortrait(
                                                                  context)
                                                              ? AppConfig.size(
                                                                  context, 12)
                                                              : AppConfig.size(
                                                                  context, 14),
                                                      color:
                                                          const Color.fromARGB(
                                                              255, 1, 90, 4),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: AppConfig.isPortrait(context)
                            ? AppConfig.size(context, 20)
                            : AppConfig.size(context, 30),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          SizedBox(
                            width: AppConfig.isPortrait(context) ? 10 : 20,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: (customerCurrentScreen == 'Seller'
                                  ? Colors.orange.shade100
                                  : Colors.blue.shade100),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.5),
                                width: 1,
                              ),
                              //drop shadow
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            width: AppConfig.isPortrait(context)
                                ? (screenWidth - 40) * 0.33
                                : AppConfig.size(context, 30),
                            height: AppConfig.isPortrait(context)
                                ? screenHeight / 12
                                : AppConfig.size(context, 60),
                            child: Stack(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(3),
                                  child: InkWell(
                                    onTap: () => {
                                      // navigate to invoice page
                                      if (customerCurrentScreen == 'Seller')
                                        {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const PaymentsPage()))
                                        }
                                      else
                                        {
                                          store.dispatch(
                                              UpdateInvoiceStatusType(
                                                  invoiceStatusType: 'All')),
                                          store.dispatch(
                                              UpdateSelectedBottomNavIndexAction(
                                                  3)),
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const InvoicePage())),
                                        }
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Text(
                                              customerCurrentScreen == 'Seller'
                                                  ? 'Payment'
                                                  : 'Payment Invoice',
                                              style: TextStyle(
                                                fontSize: AppConfig.isPortrait(
                                                        context)
                                                    ? AppConfig.size(
                                                        context, 12)
                                                    : AppConfig.size(
                                                        context, 14),
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            Text(
                                              customerCurrentScreen == 'Seller'
                                                  ? 'Acknowledgement'
                                                  : 'Acceptance',
                                              style: TextStyle(
                                                fontSize: AppConfig.isPortrait(
                                                        context)
                                                    ? AppConfig.size(
                                                        context, 11)
                                                    : AppConfig.size(
                                                        context, 14),
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(1),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 20,
                                      minHeight: 20,
                                    ),
                                    child: Text(
                                      customerCurrentScreen == 'Seller'
                                          ? dashboardData[
                                                      'PaymentAcknowledgement'] !=
                                                  null
                                              ? '${dashboardData['PaymentAcknowledgement']}'
                                              : '0'
                                          : dashboardData['InvoiceCount'] !=
                                                  null
                                              ? '${dashboardData['InvoiceCount']}'
                                              : '0',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: AppConfig.isPortrait(context)
                                            ? AppConfig.size(context, 12)
                                            : AppConfig.size(context, 12),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: AppConfig.isPortrait(context) ? 10 : 20,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: (customerCurrentScreen == 'Seller'
                                  ? Colors.orange.shade100
                                  : Colors.blue.shade100),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.5),
                                width: 1,
                              ),
                              //drop shadow
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            width: AppConfig.isPortrait(context)
                                ? (screenWidth - 40) * 0.33
                                : AppConfig.size(context, 30),
                            height: AppConfig.isPortrait(context)
                                ? screenHeight / 12
                                : AppConfig.size(context, 60),
                            child: Stack(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(3),
                                  child: InkWell(
                                    onTap: () => {
                                      store.dispatch(
                                          UpdateSelectedBottomNavIndexAction(
                                              3)),
                                      store.dispatch(UpdateInvoiceStatusType(
                                          invoiceStatusType: 'Disputed')),

                                      // navigate to invoice page
                                      if (customerCurrentScreen == 'Seller')
                                        {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const InvoicePage()))
                                        }
                                      else
                                        {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const InviteHistoryPage()))
                                        }
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Text(
                                              customerCurrentScreen == 'Seller'
                                                  ? 'Disputed'
                                                  : 'Seller',
                                              style: TextStyle(
                                                fontSize: AppConfig.isPortrait(
                                                        context)
                                                    ? AppConfig.size(
                                                        context, 12)
                                                    : AppConfig.size(
                                                        context, 14),
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            Text(
                                              customerCurrentScreen == 'Seller'
                                                  ? 'Invoices'
                                                  : 'Requests',
                                              style: TextStyle(
                                                fontSize: AppConfig.isPortrait(
                                                        context)
                                                    ? AppConfig.size(
                                                        context, 12)
                                                    : AppConfig.size(
                                                        context, 14),
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(1),
                                    decoration: BoxDecoration(
                                      color: customerCurrentScreen == 'Seller'
                                          ? Colors.red
                                          : Colors.green,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 20,
                                      minHeight: 20,
                                    ),
                                    child: Text(
                                      customerCurrentScreen == 'Seller'
                                          ? dashboardData['DisputedInvoice'] !=
                                                  null
                                              ? '${dashboardData['DisputedInvoice']}'
                                              : '0'
                                          : dashboardData['CustomerRequest'] !=
                                                  null
                                              ? '${dashboardData['CustomerRequest']}'
                                              : '0',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: AppConfig.isPortrait(context)
                                            ? AppConfig.size(context, 12)
                                            : AppConfig.size(context, 12),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: AppConfig.isPortrait(context) ? 10 : 20,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: (customerCurrentScreen == 'Seller'
                                  ? Colors.orange.shade100
                                  : Colors.blue.shade100),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.5),
                                width: 1,
                              ),
                              //drop shadow
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            width: AppConfig.isPortrait(context)
                                ? (screenWidth - 40) * 0.33
                                : AppConfig.size(context, 30),
                            height: AppConfig.isPortrait(context)
                                ? screenHeight / 12
                                : AppConfig.size(context, 60),
                            child: Stack(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(3),
                                  child: InkWell(
                                    onTap: () => {
                                      if (customerCurrentScreen == 'Seller')
                                        {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const InviteHistoryPage()))
                                        }
                                      else
                                        {
                                          store.dispatch(
                                              UpdateSelectedBottomNavIndexAction(
                                                  4)),
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const PaymentsPage()))
                                        }
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Text(
                                              customerCurrentScreen == 'Seller'
                                                  ? 'Buyer'
                                                  : 'Payment',
                                              style: TextStyle(
                                                fontSize: AppConfig.isPortrait(
                                                        context)
                                                    ? AppConfig.size(
                                                        context, 12)
                                                    : AppConfig.size(
                                                        context, 14),
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            Text(
                                              customerCurrentScreen == 'Seller'
                                                  ? 'Requests'
                                                  : 'Dispute',
                                              style: TextStyle(
                                                fontSize: AppConfig.isPortrait(
                                                        context)
                                                    ? AppConfig.size(
                                                        context, 12)
                                                    : AppConfig.size(
                                                        context, 14),
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(1),
                                    decoration: BoxDecoration(
                                      color: customerCurrentScreen == 'Seller'
                                          ? Colors.green
                                          : Colors.red,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 20,
                                      minHeight: 20,
                                    ),
                                    child: Text(
                                      customerCurrentScreen == 'Seller'
                                          ? dashboardData['CustomerRequest'] !=
                                                  null
                                              ? '${dashboardData['CustomerRequest']}'
                                              : '0'
                                          : dashboardData['PaymentDisputed'] !=
                                                  null
                                              ? '${dashboardData['PaymentDisputed']}'
                                              : '0',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: AppConfig.isPortrait(context)
                                            ? AppConfig.size(context, 12)
                                            : AppConfig.size(context, 12),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: AppConfig.isPortrait(context) ? 10 : 20,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: AppConfig.isPortrait(context)
                            ? AppConfig.size(context, 20)
                            : AppConfig.size(context, 30),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.5),
                                width: 1,
                              ),
                              //drop shadow
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            width: screenWidth - 20,
                            height: screenHeight / 8,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Text(
                                      'Credit Limit Assigned: ₹${dashboardData['CreditLimit']}',
                                      style: TextStyle(
                                        fontSize: AppConfig.size(context, 16),
                                        color:
                                            selectedUserType == UserTypes.seller
                                                ? Colors.orange
                                                : Colors.deepPurple.shade900,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                        padding:
                                            const EdgeInsets.only(left: 20),
                                        child: Text(
                                          'Credit Limit Utilized: ₹${(dashboardData['AvailableCreditLimit'] != null) ? dashboardData['AvailableCreditLimit'] : 0}',
                                          style: TextStyle(
                                            fontSize:
                                                AppConfig.size(context, 16),
                                            color: Colors.black,
                                          ),
                                        )),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20, right: 20),
                                      child: LinearProgressIndicator(
                                        value: (dashboardData['CreditLimit'] !=
                                                    null &&
                                                dashboardData['CreditLimit'] !=
                                                    0 &&
                                                dashboardData[
                                                        'AvailableCreditLimit'] !=
                                                    null)
                                            ? (dashboardData[
                                                    'AvailableCreditLimit']) /
                                                dashboardData['CreditLimit']
                                            : 0,
                                        backgroundColor: Colors.grey,
                                        valueColor: AlwaysStoppedAnimation<
                                                Color>(
                                            selectedUserType == UserTypes.seller
                                                ? Colors.orange
                                                : Colors.deepPurple.shade900),
                                        minHeight: 8,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    )
                                  ],
                                )
                              ],
                            )),
                      ),
                      SizedBox(
                        height: AppConfig.isPortrait(context)
                            ? AppConfig.size(context, 20)
                            : AppConfig.size(context, 30),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                          ),
                          onPressed: () {
                            // navigate to calendar page
                            store.dispatch(
                                UpdateSelectedBottomNavIndexAction(2));
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const CalendarPage()));
                          },
                          child: Text(
                            'Monthly Invoice Calendar',
                            style: TextStyle(
                              fontSize: AppConfig.size(context, 16),
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
