// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:math';

import 'package:aquila_hundi/app/helper_widgets/appbar.dart';
import 'package:aquila_hundi/app/helper_widgets/bottom_navigation.dart';
import 'package:aquila_hundi/app/helper_widgets/config.dart';
import 'package:aquila_hundi/app/modules/Dashboard/dashboard_page.dart';
import 'package:aquila_hundi/app/modules/Invoice/invoice_page.dart';
import 'package:aquila_hundi/store/app.state.dart';
import 'package:aquila_hundi/store/business/business.action.dart';
import 'package:aquila_hundi/store/commonValues/commonvalues.action.dart';
import 'package:aquila_hundi/store/dashboard/dashboard.action.dart';
import 'package:aquila_hundi/store/invoice/invoice.action.dart';
import 'package:aquila_hundi/store/invoice/invoice.reducer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:date_picker_plus/date_picker_plus.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:cell_calendar/cell_calendar.dart';



class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});
  @override
  CalendarPageState createState() => CalendarPageState();
}

class CalendarPageState extends State<CalendarPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final List<String> days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  int screenIndex = 2;
  final DateTime DateTime1 = DateTime(2024, 05, 05);
  final DateTime DateTime2 = DateTime(2024, 5, 2);
  bool startLoading = true;

  @override
  void initState() {
    super.initState();
  }

  void openDrawer() {
    scaffoldKey.currentState!.openDrawer();
  }

  void onAddSomething() {
    print('Add something');
  }

  // find current month from datetime
  String todayDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
  String startDayofMonth = DateFormat('dd-MM-yyyy').format(DateTime(DateTime.now().year, DateTime.now().month, 1));

  // convert ontapped date to string and 



fetchInitialData() {
  StoreProvider.of<AppState>(context).dispatch(UpdateInvoiceList(invoiceList: {}));
  StoreProvider.of<AppState>(context).dispatch(UpdateInvoiceListLocal(invoiceListLocal: []));
  StoreProvider.of<AppState>(context).dispatch(UpdateInvoiceListLoaded(invoiceListLoaded: 2));
  StoreProvider.of<AppState>(context).dispatch(getInvoiceList(<String, dynamic>{
    "FilterQuery":
    {   "Business":'',
        "Buyer":'',
        "BuyerBusiness":'',
        "CustomDateRange":
        {
            "From":startDayofMonth,
            "To":todayDate
            },
        "DateRange": 'Custom',
        "SearchKey":'',
        "Seller":'',
        "StatusType": '',
        },
        "InvoiceType": '',
        "PageNumber":1
  }));
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
        final customerData = store.state.dashboardState.dashboardData;
        final cellCalendarPageController = CellCalendarPageController();
        final selectedDate = store.state.invoiceState.selectedDate;
        final invoiceListLocal = store.state.invoiceState.invoiceListLocal;

        Future navigateToInvoicePage ( date1, date2) async {
          // convert date to dd-mm-yyyy
          date1 = DateFormat('dd-MM-yyyy').format(date1);
          date2 = DateFormat('dd-MM-yyyy').format(date2);

          store.dispatch(UpdateSelectedBottomNavIndexAction(3));
          store.dispatch(UpdateInvoiceList(invoiceList: {}));
          store.dispatch(UpdateInvoiceListLocal(invoiceListLocal: []));
          store.dispatch(UpdateInvoiceListLoaded(invoiceListLoaded: 2));
          await Future.delayed(const Duration(milliseconds: 500));
          store.dispatch(getInvoiceList(<String, dynamic>{
            "FilterQuery":
        {   "Business":'',
            "Buyer":'',
            "BuyerBusiness":'',
            "CustomDateRange":
            {
                "From":date1,
                "To":date2
                },
            "DateRange": 'Custom',
            "SearchKey":'',
            "Seller":'',
            "StatusType": '',
            },
            "InvoiceType": '',
            "PageNumber":1
          }));

          // navigate to invoice page
        Navigator.push(context, 
        MaterialPageRoute(builder: (context) => const InvoicePage())
        );
        }

        Future fetchMonthlyData (date1, date2) async {
          // convert date to dd-mm-yyyy
          date1 = DateFormat('dd-MM-yyyy').format(date1);
          date2 = DateFormat('dd-MM-yyyy').format(date2);

          store.dispatch(UpdateInvoiceList(invoiceList: {}));
          store.dispatch(UpdateInvoiceListLocal(invoiceListLocal: []));
          store.dispatch(UpdateInvoiceListLoaded(invoiceListLoaded: 2));
          await Future.delayed(const Duration(milliseconds: 500));
          store.dispatch(getInvoiceList(<String, dynamic>{
            "FilterQuery":
        {   "Business":'',
            "Buyer":'',
            "BuyerBusiness":'',
            "CustomDateRange":
            {
                "From":date1,
                "To":date2
                },
            "DateRange": 'Custom',
            "SearchKey":'',
            "Seller":'',
            "StatusType": '',
            },
            "InvoiceType": '',
            "PageNumber":1
          }));
        }

        if (startLoading) {
          fetchInitialData();
          startLoading = false;
        }

        var events = [];



        if (invoiceListLocal.isNotEmpty) {
          // for loop
          for (var i=0; i<invoiceListLocal.length; i++) {
            var invoiceDate = invoiceListLocal[i]['InvoiceDueDate'];            
            var invoiceDate1 = DateTime.parse(invoiceDate);
            var invoiceDate2 = DateTime(invoiceDate1.year, invoiceDate1.month, invoiceDate1.day);
            events.add(CalendarEvent(
              eventName: '₹${convertAmount(invoiceListLocal[i]['InvoiceAmount'])}',
              eventDate: invoiceDate2,
              eventBackgroundColor: invoiceListLocal[i]['StatusType'] == 'OverDue' ? Colors.red : invoiceListLocal[i]['InvoiceStatus'] == 'Pending' ? Colors.orange : Colors.green,
              eventTextStyle: const TextStyle(fontSize: 10, color: Colors.white),
            ));
          }
        }

        



        return Scaffold(
          key: scaffoldKey,
          appBar: PreferredSize(
            preferredSize:  BoxConstraints.tightFor(height: AppConfig.size(context, 45)).smallest,
            child: WidgetHelper.getAppBar(context, 'Calendar', openDrawer, customerCurrentScreen == 'Seller' ? Colors.orange : Colors.deepPurple.shade900, onAddSomething),
          ),
      bottomNavigationBar: const BottomNavigation(),
    drawer: WidgetHelper.leftNavigationBar(context, screenIndex, customerData['ContactName'], customerData['Mobile'], customerCurrentScreen == 'Seller' ? Colors.orange : Colors.deepPurple.shade900),
    body: Center(
      child: Column(
        children: <Widget>[
          Expanded(
            child: CellCalendar(
              cellCalendarPageController: cellCalendarPageController,
              onCellTapped: (date) {
                navigateToInvoicePage(date, date);
              },
              events: events.isNotEmpty ? events.cast<CalendarEvent>() : [
                CalendarEvent(
                  eventName: '  ',
                  eventDate: DateTime1,
                  eventTextStyle: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              ],
              onPageChanged: (firstDate, lastDate) => {
                print('First Date: $firstDate'),
                print('Last Date: $lastDate'),
                fetchMonthlyData(firstDate, lastDate),
              },
            ),
          ),
        ],
      )
    ),
  );

      },
    );
  }
}