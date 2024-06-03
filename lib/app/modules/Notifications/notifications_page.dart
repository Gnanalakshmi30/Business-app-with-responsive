// ignore_for_file: use_build_context_synchronously

import 'dart:math';

import 'package:aquila_hundi/app/helper_widgets/appbar.dart';
import 'package:aquila_hundi/app/helper_widgets/bottom_navigation.dart';
import 'package:aquila_hundi/app/helper_widgets/config.dart';
import 'package:aquila_hundi/app/modules/Dashboard/dashboard_page.dart';
import 'package:aquila_hundi/store/app.state.dart';
import 'package:aquila_hundi/store/business/business.action.dart';
import 'package:aquila_hundi/store/commonValues/commonvalues.action.dart';
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

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});
  @override
  NotificationsPageState createState() => NotificationsPageState();
}

class NotificationsPageState extends State<NotificationsPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController scrollController = ScrollController();
  int screenIndex = 2;
  TextEditingController supportTitleController = TextEditingController();
  TextEditingController supportQueryController = TextEditingController();

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

  void onAddButtonClick() {}

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
          final customerCurrentScreen =
              store.state.dashboardState.customerCurrentScreen;
          final customerData = store.state.authState.customerData;
          final screenWidth = MediaQuery.of(context).size.width;
          final notificationsList =
              store.state.commonValuesState.notificationsList;
          final notificationsListLoaded =
              store.state.commonValuesState.notificationsListLoaded;

          final loading = store.state.commonValuesState.loading;
          final error = store.state.commonValuesState.error;

          if (notificationsListLoaded == false && notificationsList.isEmpty) {
            store.dispatch(UpdateNotificationsListLoadedAction(true));
            store.dispatch(getNotificationsList);
          }

          return Scaffold(
              key: scaffoldKey,
              appBar: PreferredSize(
                preferredSize:
                    BoxConstraints.tightFor(height: AppConfig.size(context, 45))
                        .smallest,
                child: WidgetHelper.getAppBar(
                    context,
                    'Notifications',
                    openDrawer,
                    customerCurrentScreen == 'Seller'
                        ? Colors.orange
                        : Colors.deepPurple.shade900,
                    onAddButtonClick),
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
              body: loading == true
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            customerCurrentScreen == 'Seller'
                                ? Colors.orange
                                : Colors.deepPurple.shade900),
                      ),
                    )
                  : notificationsList.isEmpty
                      ? Center(
                          child: Text(
                            'No Notifications Found',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: AppConfig.size(context, 16),
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: notificationsList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                              margin: EdgeInsets.only(
                                  left: screenWidth * 0.05,
                                  right: screenWidth * 0.05,
                                  top: screenWidth * 0.02,
                                  bottom: screenWidth * 0.02),
                              padding: EdgeInsets.all(screenWidth * 0.05),
                              decoration: BoxDecoration(
                                color: notificationsList[index]
                                            ['Message_Viewed'] ==
                                        false
                                    ? Colors.white
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        notificationsList[index]
                                            ['Notification_Type'],
                                        style: TextStyle(
                                          color: notificationsList[index]
                                                      ['Message_Viewed'] ==
                                                  false
                                              ? Colors.black
                                              : Colors.grey.shade700,
                                          fontSize: AppConfig.size(context, 16),
                                          fontWeight: notificationsList[index]
                                                      ['Message_Viewed'] ==
                                                  false
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                      IconButton(
                                          onPressed: () {
                                            deleteConfirmationDialog(
                                                customerCurrentScreen,
                                                store,
                                                notificationsList[index]);
                                          },
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ))
                                    ],
                                  ),
                                  SizedBox(height: screenWidth * 0.02),
                                  Text(
                                    notificationsList[index]['Message'],
                                    style: TextStyle(
                                      color: notificationsList[index]
                                                  ['Message_Viewed'] ==
                                              false
                                          ? Colors.black
                                          : Colors.grey.shade700,
                                      fontSize: AppConfig.size(context, 14),
                                    ),
                                  ),
                                  SizedBox(height: screenWidth * 0.02),
                                  Text(
                                    DateFormat('DD MMM yyyy').format(
                                        DateTime.parse(notificationsList[index]
                                            ['createdAt'])),
                                    style: TextStyle(
                                      color: notificationsList[index]
                                                  ['Message_Viewed'] ==
                                              false
                                          ? Colors.black
                                          : Colors.grey.shade700,
                                      fontSize: AppConfig.size(context, 14),
                                    ),
                                  ),
                                  SizedBox(height: screenWidth * 0.02),
                                  notificationsList[index]['Message_Viewed'] ==
                                          false
                                      ? InkWell(
                                          onTap: () {
                                            store.dispatch(
                                                markNotificationRead({
                                              'NotificationId':
                                                  notificationsList[index]
                                                      ['_id']
                                            }));
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(
                                                screenWidth * 0.02),
                                            decoration: BoxDecoration(
                                              color: customerCurrentScreen ==
                                                      'Seller'
                                                  ? Colors.orange
                                                  : Colors.deepPurple.shade900,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Text(
                                              'Mark as Read',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize:
                                                    AppConfig.size(context, 14),
                                              ),
                                            ),
                                          ),
                                        )
                                      : Container(),
                                ],
                              ),
                            );
                          },
                        ));
        });
  }

  deleteConfirmationDialog(
      String customerCurrentScreen, Store<AppState> store, Map data) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            actionsAlignment: MainAxisAlignment.end,
            title: Text(
              "Delete confirmation",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: AppConfig.size(context, 20)),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                      child: Text(
                    "Are you sure, want to delete?",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: AppConfig.size(context, 15)),
                  )),
                ],
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);

                  store.dispatch(deleteNotification(data['_id']));
                },
                child: Container(
                    padding: EdgeInsets.only(
                        left: AppConfig.size(context, 15),
                        right: AppConfig.size(context, 15),
                        bottom: AppConfig.size(context, 10),
                        top: AppConfig.size(context, 10)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: customerCurrentScreen == 'Seller'
                          ? Colors.orange
                          : Colors.deepPurple.shade900,
                    ),
                    child: const Text(
                      'Ok',
                      style: TextStyle(color: Colors.white),
                    )),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                    padding: EdgeInsets.only(
                        left: AppConfig.size(context, 15),
                        right: AppConfig.size(context, 15),
                        bottom: AppConfig.size(context, 10),
                        top: AppConfig.size(context, 10)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: customerCurrentScreen == 'Seller'
                          ? Colors.orange
                          : Colors.deepPurple.shade900,
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white),
                    )),
              ),
            ],
          );
        });
  }
}
