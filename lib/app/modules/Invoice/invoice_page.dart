// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:math';

import 'package:aquila_hundi/app/helper_widgets/appbar.dart';
import 'package:aquila_hundi/app/helper_widgets/bottom_navigation.dart';
import 'package:aquila_hundi/app/helper_widgets/config.dart';
import 'package:aquila_hundi/app/modules/Dashboard/dashboard_page.dart';
import 'package:aquila_hundi/app/modules/InviteListPage/invitelist_page.dart';
import 'package:aquila_hundi/store/app.state.dart';
import 'package:aquila_hundi/store/business/business.action.dart';
import 'package:aquila_hundi/store/commonValues/commonvalues.action.dart';
import 'package:aquila_hundi/store/dashboard/dashboard.action.dart';
import 'package:aquila_hundi/store/invite/invite.action.dart';
import 'package:aquila_hundi/store/invoice/invoice.action.dart';
import 'package:aquila_hundi/store/invoice/invoice.reducer.dart';
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
import 'package:image_picker/image_picker.dart';
import 'package:flutter_emoji/flutter_emoji.dart';





class InvoicePage extends StatefulWidget {
  const InvoicePage({super.key});

  @override
  InvoicePageState createState() => InvoicePageState();
}

class InvoicePageState extends State<InvoicePage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int screenIndex = -1;
  bool startLoading = false;
  int selectedFilterIndex = 0;
  int selectedStatusFilter = 0;
  int selectedDateFilter = -1;
  String selectedFromDate = '';
  String selectedToDate = '';
  TextEditingController searchController = TextEditingController();
  String invoiceNumber = '';
  String invoiceAmount = '';
  String invoiceDate = '';
  String invoiceDescription = '';
  int pageNumber = 1;
  bool invoiceTypedUpdated = false;
  String filterBusiness = '';
  String filterBuyer = '';
  String filterBuyerBusiness = '';
  int filterBusinessCreditLimit = 0;
  String filterInvoiceNumber = '';
  String filterSeller = '';
  String filterStatusType = '';
  TextEditingController invoiceNumberController = TextEditingController();
  TextEditingController invoiceAmountController = TextEditingController();
  TextEditingController invoiceDescriptionController = TextEditingController();
  TextEditingController businessSearchController = TextEditingController();
  TextEditingController buyerSearchController = TextEditingController();
  TextEditingController buyerBusinessSearchController = TextEditingController();
  TextEditingController sellerSearchController = TextEditingController();
  TextEditingController remarksController = TextEditingController();
  TextEditingController paymentAmountController = TextEditingController();


  List buyerBusinessList = [];
  bool updateInvoiceSubmitted = false;


  // list builder controller
  ScrollController scrollController = ScrollController();
  
@override 
void initState () {
  super.initState();
  scrollController.addListener(() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      setState(() {
        pageNumber = pageNumber + 1;
      });
      StoreProvider.of<AppState>(context).dispatch(getInvoiceList(<String, dynamic>{
            "FilterQuery":
        {   "Business":filterBusiness,
            "Buyer":filterBuyer,
            "BuyerBusiness":filterBuyerBusiness,
            "CustomDateRange":
            {
                "From":selectedFromDate,
                "To":selectedToDate
                },
            "DateRange":"",
            "SearchKey":searchController.text,
            "Seller":filterSeller,
            "StatusType": selectedStatusFilter == 0 ? '' : selectedStatusFilter == 1 ? 'OverDue' : selectedStatusFilter == 2 ? 'DueToday' : selectedStatusFilter == 3 ? 'Upcoming' : ''
            },
            "InvoiceType": selectedFilterIndex == 0 ? 'Pending' : selectedFilterIndex == 1 ? 'Accept' : selectedFilterIndex == 2 ? 'Disputed' : '',
            "PageNumber": pageNumber
          }));
    }
  });
}


@override
void dispose() {
  scrollController.dispose();
  super.dispose();
}


  void openDrawer() {
    scaffoldKey.currentState!.openDrawer();
  }


  Future<void> selectFromDate(BuildContext context, setState) async {
    final DateTime? picked = (await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015, 8),
      // lastdate should be today
      lastDate: DateTime.now(),
    ));
    if (picked != null) {
    setState(() {

      // use only date
      selectedFromDate = picked.toString().substring(0, 10);
      // convert to MM
      print('selectedFromDate: $selectedFromDate');
    });
    }
    }

  Future<void> selectToDate(BuildContext context, setState) async {
    final DateTime? picked = (await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015, 8),
      // lastdate should be today
      lastDate: DateTime.now(),
    ));
    if (picked != null && selectedFromDate != '') {
    // find if the selected date is greater than the selectedFromDate
    if (picked.isBefore(DateTime.parse(selectedFromDate))) {
      showDialog(
        context: context, 
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('To date should be greater than from date'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ],
          );
        }
      );
      return;
    }

    }
    if (picked != null) {
    setState(() {
      // use only date
      selectedToDate = picked.toString().substring(0, 10);
    });
    }
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

    

  onSearchClicked () {
    setState(() {
      startLoading = true;
    });
  }

  Future<void> dateFilterPopup(customerCurrentScreen) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Search'),
          content: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) => 
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // searchbar
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by invoice number',
                      hintStyle: TextStyle(color: Colors.grey.shade600),
                      prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                  const Divider(),
                  Text('Filter by Status', style: TextStyle(color: Colors.grey.shade900, fontSize: AppConfig.size(context, 18)),),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 5,
                    children: <Widget>[
                      FilterChip(
                        label: const Text('All'),
                        labelStyle: TextStyle(color: selectedStatusFilter == 0 ? Colors.white : Colors.grey.shade600),
                        backgroundColor: selectedStatusFilter == 0 ? (customerCurrentScreen == 'Seller' ? Colors.orange.shade800 : Colors.blue.shade800)  : Colors.grey.shade300,
                        onSelected: (bool value) {
                          setState(() {
                            selectedStatusFilter = 0;
                          });
                        },
                      ),
                      FilterChip(
                        label: const Text('Overdue'),
                        labelStyle: TextStyle(color: selectedStatusFilter == 1 ? Colors.white : Colors.grey.shade600),
                        backgroundColor: selectedStatusFilter == 1 ? Colors.red.shade800 : Colors.grey.shade300,
                        onSelected: (bool value) {
                          setState(() {
                            selectedStatusFilter = 1;
                          });
                        },
                      ),
                      FilterChip(
                        label: const Text('Due Today'),
                        labelStyle: TextStyle(color: selectedStatusFilter == 2 ? Colors.white : Colors.grey.shade600),
                        backgroundColor: selectedStatusFilter == 2 ? Colors.orange.shade800 : Colors.grey.shade300,
                        onSelected: (bool value) {
                          setState(() {
                            selectedStatusFilter = 2;
                          });
                        },
                      ),
                      FilterChip(
                        label: const Text('Upcoming'),
                        labelStyle: TextStyle(color: selectedStatusFilter == 3 ? Colors.white : Colors.grey.shade600),
                        backgroundColor: selectedStatusFilter == 3 ? Colors.green.shade800 : Colors.grey.shade300,
                        onSelected: (bool value) {
                          setState(() {
                            selectedStatusFilter = 3;
                          });
                        },
                      ),
                    ],
                  ),
                  const Divider(),
                  Text('Filter by Date', style: TextStyle(color: Colors.grey.shade900, fontSize: AppConfig.size(context, 18)),),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 5,
                    children: <Widget>[
                      FilterChip(
                        label: const Text('Current Week'),
                        labelStyle: TextStyle(color: selectedDateFilter == 0 ? Colors.white : Colors.grey.shade600),
                        backgroundColor: selectedDateFilter == 0 ? Colors.orange.shade800 : Colors.grey.shade300,
                        onSelected: (bool value) {
                          setState(() {
                            selectedDateFilter = 0;
                          });
                        },
                      ),
                      FilterChip(
                        label: const Text('Last Week'),
                        labelStyle: TextStyle(color: selectedDateFilter == 1 ? Colors.white : Colors.grey.shade600),
                         backgroundColor: selectedDateFilter == 1 ? Colors.orange.shade800 : Colors.grey.shade300,
                        onSelected: (bool value) {
                          setState(() {
                            selectedDateFilter = 1;
                          });
                        },
                      ),
                      FilterChip(
                        label: const Text('Current Month'),
                        labelStyle: TextStyle(color: selectedDateFilter == 2 ? Colors.white : Colors.grey.shade600),
                         backgroundColor: selectedDateFilter == 2 ? Colors.orange.shade800 : Colors.grey.shade300,
                        onSelected: (bool value) {
                          setState(() {
                            selectedDateFilter = 2;
                          });
                        },
                      ),
                      FilterChip(
                        label: const Text('Last Month'),
                        labelStyle: TextStyle(color: selectedDateFilter == 3 ? Colors.white : Colors.grey.shade600),
                         backgroundColor: selectedDateFilter == 3 ? Colors.orange.shade800 : Colors.grey.shade300,
                        onSelected: (bool value) {
                          setState(() {
                            selectedDateFilter = 3;
                          });
                          
                        },
                      ),
                      FilterChip(
                        label: const Text('Custom'),
                        labelStyle: TextStyle(color: selectedDateFilter == 4 ? Colors.white : Colors.grey.shade600),
                        backgroundColor: selectedDateFilter == 4 ? (customerCurrentScreen == 'Seller' ? Colors.orange.shade800 : Colors.blue.shade800) : Colors.grey.shade300,
                        onSelected: (bool value) {
                          setState(() {
                            selectedDateFilter = 4;
                          });
                        },
                      ),
                    ],
              
                  ),
                  selectedDateFilter == 4 ? 
                  Wrap(
                    children: <Widget>[
                      // date picker
                      SizedBox(
                        child: OutlinedButton(
                          onPressed: () {
                            selectFromDate(context, setState);
                          },
                          child: Text(selectedFromDate != '' ? DateFormat('dd MMM, yyyy').format(DateTime.parse(selectedFromDate)) : 'From Date', style: TextStyle(color: Colors.orange.shade800, fontSize: AppConfig.size(context, 14)),),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // date picker
                      SizedBox(
                        child: OutlinedButton(
                          onPressed: () {
                            selectToDate(context, setState);
                          },
                          child: Text(selectedToDate != '' ? DateFormat('dd MMM, yyyy').format(DateTime.parse(selectedToDate)) : 'To Date', style: TextStyle(color: Colors.orange.shade800, fontSize: AppConfig.size(context, 14)),),
                        ),
                      ),
                    ],
                  ) : const SizedBox.shrink(),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      SizedBox(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedFromDate = '';
                              selectedToDate = '';
                              selectedDateFilter = -1;
                              selectedStatusFilter = 0;
                              searchController.clear();
                            });
                          },
                          child: Text('Clear', style: TextStyle(color: Colors.grey.shade600, fontSize: AppConfig.size(context, 16)),),
                        ),
                      ),
                      SizedBox(
                        child: ElevatedButton(
                          onPressed: () {
                            onSearchClicked();
                            Navigator.of(context).pop();
                          },
                          child: Text('Search', style: TextStyle(color: (customerCurrentScreen == 'Seller' ? Colors.orange.shade800 : Colors.blue.shade800), fontSize: AppConfig.size(context, 16)),),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
                        
                  
                
              ),
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
      },
    );
  }


  invoiceCard(BuildContext context, invoice, screenWidth) {
    // convert invoiceamount to lakh and crore if the digits are more than 4

    

    return Card(
      elevation: 5,
      surfaceTintColor: Colors.white,
      // give border color to left side only with thickness 3 using shape
      shape: RoundedRectangleBorder(
        side: BorderSide(color: (invoice['StatusType'] == 'Overdue' || invoice['InvoiceStatus'] == 'Disputed') ? Colors.red : (invoice['StatusType'] == 'Due Today') ? Colors.orange : (invoice['StatusType'] == 'Upcoming' || invoice['InvoiceStatus'] == 'Accept') ? Colors.green.shade700 : invoice['InvoiceStatus'] == 'Pending' ? Colors.red : Colors.grey.shade600, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),

      margin: EdgeInsets.all(AppConfig.size(context, 10)),
      child: Padding(
        padding: EdgeInsets.all(AppConfig.size(context, 10)),
        child: Row(
          children: <Widget>[
            // s
            Container(
              width: screenWidth / 4,
              height: AppConfig.size(context, 110),
              decoration: BoxDecoration(
                color: (invoice['StatusType'] == 'Overdue' || invoice['InvoiceStatus'] == 'Disputed') ? Colors.red : (invoice['StatusType'] == 'Due Today') ? Colors.orange : (invoice['StatusType'] == 'Upcoming' || invoice['InvoiceStatus'] == 'Accept') ? Colors.green.shade700 : invoice['InvoiceStatus'] == 'Pending' ? Colors.red : Colors.grey.shade600,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(children: <Widget>[
                const SizedBox(width: 5),
                SizedBox(
                width: screenWidth / 5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: screenWidth / 5,
                        child: Text(DateFormat('dd MMM').format(DateTime.parse(invoice['InvoiceDate'])), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),)),
                      SizedBox(
                        width: screenWidth / 5,
                        child: Text(DateFormat('yyyy').format(DateTime.parse(invoice['InvoiceDate'])), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),)),
                      const SizedBox(height: 5),
                      SizedBox(
                        width: screenWidth / 5,
                        child: Text('₹${convertAmount(invoice['InvoiceAmount'])}'.toString(), style:  TextStyle(color: Colors.white, fontSize: AppConfig.size(context, 16), fontWeight: FontWeight.bold),))
                    ],
                  ),
                ),

              ],),
            ),
            const SizedBox(width: 5),
                SizedBox(
                width: screenWidth / 2.5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(height: 5),
                      SizedBox(
                        width: screenWidth / 2.5,
                        child: Text(('# ${invoice['InvoiceNumber']}'), style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold),)),
                      const SizedBox(height: 5),
                      SizedBox(
                        width: screenWidth / 2.5,
                        child: Text(('From: ${invoice['Business']['FirstName']} ${invoice['Business']['LastName']}'), style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold),)),
                      SizedBox(
                        width: screenWidth / 2.5,
                        child: Text('To: ${invoice['BuyerBusiness']['FirstName']} ${invoice['BuyerBusiness']['LastName']}' , style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold),)),
                        const SizedBox(height: 5),
                        SizedBox(
                        width: screenWidth / 2.5,
                        child: Text('Paid Amount: ₹${convertAmount(invoice['PaidAmount'])}', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold),)),
                      const SizedBox(height: 5),
                    ],
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  width: screenWidth / 4.5,
                  height: AppConfig.size(context, 110),
                  decoration: BoxDecoration(
                    // if invoiceduedate is less than current date then show red else green
                    color: DateTime.parse(invoice['InvoiceDueDate']).isBefore(DateTime.now()) ? Colors.red : Colors.green.shade700,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(AppConfig.size(context, 5)),
                    child: Center(child: Text('Due Date: ${DateFormat('dd MMM yyyy').format(DateTime.parse(invoice['InvoiceDueDate']))}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),)))
                ),
                

            
          ],)
      ),
    );

  }


  onBusinessSelected (value) {
    setState(() {
      filterBusiness = value;
    });
    StoreProvider.of<AppState>(context).dispatch(getSellerBusinessCustomerList(<String, dynamic>{
      "FilterQuery":{
        "Business": value,
        "Buyer":"",
        "BuyerBusiness":"",
        "Seller": ""
      }
    }));
  }

    Future<void> acceptInvoicePopup (data) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Accept Invoice'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Are you sure you want to accept the invoice?', style: TextStyle(color: Colors.grey.shade800, fontSize: AppConfig.size(context, 16)),),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.green.shade800),
                      ),
                      onPressed:(){
                        // show dialog to confirm
                        StoreProvider.of<AppState>(context).dispatch(acceptInvoice(<String, dynamic>{
                          'InvoiceId': data['_id'],
                        }));
                        Navigator.of(context).pop();
                      }, 
                      child:const Text('Accept', style: TextStyle(color: Colors.white)),
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.red.shade800),
                      ),
                      onPressed:(){
                        // show dialog to confirm
                        Navigator.of(context).pop();
                      }, 
                      child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
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
      },
    );
  }

  Future<void> disputeInvoicePopup (data) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Dispute Invoice'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Are you sure you want to dispute the invoice?', style: TextStyle(color: Colors.grey.shade800, fontSize: AppConfig.size(context, 16)),),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.green.shade800),
                      ),
                      onPressed:(){
                        // show dialog to confirm
                        StoreProvider.of<AppState>(context).dispatch(disputeInvoice(<String, dynamic>{
                          "InvoiceId": data['_id'],
                        }));
                        Navigator.of(context).pop();
                      }, 
                      child:const Text('Dispute', style: TextStyle(color: Colors.white)),
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.red.shade800),
                      ),
                      onPressed:(){
                        // show dialog to confirm
                        Navigator.of(context).pop();
                      }, 
                      child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
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
      },
    );
  }


  Future<void> openInvoiceDetailsPopUp (Map data) {
    var screenWidth = MediaQuery.of(context).size.width;
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StoreConnector<AppState, Store<AppState>>(
                converter: (store) => store,
                builder: (BuildContext context, store) {
          final invoiceStatusUpdated = store.state.invoiceState.invoiceStatusUpdated;
          final invoiceStatusLoading = store.state.invoiceState.invoiceStatusLoading;
          final invoiceStatusDisputedUpdated = store.state.invoiceState.invoiceDisputedStatusUpdated;
        return AlertDialog(
          title: const Text('Invoice Details'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                    width: screenWidth / 3.1,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.orange.shade200,
                      ),
                    padding: EdgeInsets.all(AppConfig.size(context, 10)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Invoice #', style: TextStyle(color: Colors.grey.shade800, fontSize: AppConfig.size(context, 14)),),
                        Text('${data['InvoiceNumber']}', style: TextStyle(color: Colors.grey.shade800, fontSize: AppConfig.size(context, 14)),),
                        const SizedBox(height: 5),
                        // date
                        Text('Date: ', style: TextStyle(color: Colors.grey.shade800, fontSize: AppConfig.size(context, 14)),),
                        Text(DateFormat('dd MMM yyyy').format(DateTime.parse(data['InvoiceDate'])), style: TextStyle(color: Colors.grey.shade800, fontSize: AppConfig.size(context, 14)),),
                      ],
                    ),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    width: screenWidth / 3.1,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.orange.shade200,
                      ),
                    padding: EdgeInsets.all(AppConfig.size(context, 10)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Amount:', style: TextStyle(color: Colors.grey.shade800, fontSize: AppConfig.size(context, 14)),),
                        Text('₹${convertAmount(data['InvoiceAmount'])}', style: TextStyle(color: Colors.grey.shade800, fontSize: AppConfig.size(context, 14)),),
                        const SizedBox(height: 5),
                        // date
                        Text('Due Date: ', style: TextStyle(color: Colors.grey.shade800, fontSize: AppConfig.size(context, 14)),),
                        Text(DateFormat('dd MMM yyyy').format(DateTime.parse(data['InvoiceDueDate'])), style: TextStyle(color: Colors.grey.shade800, fontSize: AppConfig.size(context, 14)),),
                      ],
                    ),
                  ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: <Widget>[
                    Container(
                    // billed to and from
                    width: screenWidth / 3.1,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.orange.shade200,
                      ),
                    padding: EdgeInsets.all(AppConfig.size(context, 10)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Billed To:', style: TextStyle(color: Colors.grey.shade800, fontSize: AppConfig.size(context, 14)),),
                        Text('${data['BuyerBusiness']['FirstName']} ${data['BuyerBusiness']['LastName']}', style: TextStyle(color: Colors.grey.shade800, fontSize: AppConfig.size(context, 14)),),
                      ],
                    ),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    // billed to and from
                    width: screenWidth / 3.1,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.orange.shade200,
                      ),
                    padding: EdgeInsets.all(AppConfig.size(context, 10)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Billed From:', style: TextStyle(color: Colors.grey.shade800, fontSize: AppConfig.size(context, 14)),),
                        Text('${data['Business']['FirstName']} ${data['Business']['LastName']}', style: TextStyle(color: Colors.grey.shade800, fontSize: AppConfig.size(context, 14)),),
                      ],
                    ),
                  ),
                  ],
                ),

                const SizedBox(height: 5),
                Row(
                  children: <Widget>[
                    Container(
                    // billed to and from
                    width: screenWidth / 3.1,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.orange.shade200,
                      ),
                    padding: EdgeInsets.all(AppConfig.size(context, 10)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Paid Amount:', style: TextStyle(color: Colors.grey.shade800, fontSize: AppConfig.size(context, 14)),),
                        Text('₹${data['PaidAmount']}', style: TextStyle(color: Colors.grey.shade800, fontSize: AppConfig.size(context, 14)),),
                      ],
                    ),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    // billed to and from
                    width: screenWidth / 3.1,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.orange.shade200,
                      ),
                    padding: EdgeInsets.all(AppConfig.size(context, 10)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Available Limit:', style: TextStyle(color: Colors.grey.shade800, fontSize: AppConfig.size(context, 14)),),
                        Text('₹${data['CurrentCreditAmount'] - data['UsedCurrentCreditAmount']}', style: TextStyle(color: Colors.grey.shade800, fontSize: AppConfig.size(context, 14)),),
                      ],
                    ),
                  ),
                  ],
                ),
                const SizedBox(height: 5),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: (data['InvoiceStatus'] == 'Disputed' || data['StatusType'] == 'OverDue') ? Colors.red.shade800 : data['InvoiceStatus'] == 'Accept' ? Colors.green.shade800 : data['InvoiceStatus'] == 'Pending' ? Colors.red.shade600 : Colors.orange.shade200,
                    ),
                  padding: EdgeInsets.all(AppConfig.size(context, 10)),
                  child: Row(
                    children: <Widget>[
                      Text('Status: ', style: TextStyle(color: Colors.white, fontSize: AppConfig.size(context, 14)),),
                      Text('${data['StatusType'] + ' - ' + data['PaidORUnpaid'] + ' - ' + data['InvoiceStatus'] ?? ''}', style: TextStyle(color: Colors.white, fontSize: AppConfig.size(context, 14)),),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  width: screenWidth / 1.5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.orange.shade100,
                    ),
                  padding: EdgeInsets.all(AppConfig.size(context, 10)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Description:', style: TextStyle(color: Colors.grey.shade800, fontSize: AppConfig.size(context, 14)),),
                      Text('${data['Description'] ?? 'Not available.'}', style: TextStyle(color: Colors.grey.shade800, fontSize: AppConfig.size(context, 14)),),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  width: screenWidth / 1.5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.orange.shade100,
                    ),
                  padding: EdgeInsets.all(AppConfig.size(context, 10)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Attachments:', style: TextStyle(color: Colors.grey.shade800, fontSize: AppConfig.size(context, 14)),),
                      data['InvoiceAttachments'].isEmpty ? Text('No attachments available.', style: TextStyle(color: Colors.grey.shade800, fontSize: AppConfig.size(context, 14)),) : Column(
                        children: data['Attachments'].map<Widget>((e) => Text(e['FileName'], style: TextStyle(color: Colors.grey.shade800, fontSize: AppConfig.size(context, 14)),)).toList(),
                      ),
                      
                    ],
                  ),
                ),
                const SizedBox(height: 5),
              if (StoreProvider.of<AppState>(context).state.dashboardState.customerCurrentScreen == 'Buyer')
              if (data['InvoiceStatus'] == 'Pending' && invoiceStatusLoading == false && invoiceStatusUpdated == false && invoiceStatusDisputedUpdated == false)
              Row(
                children: <Widget>[ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.green),
                ),
                onPressed: () {
                    acceptInvoicePopup(data);
                }, 
                child: const Text('Accept', style: TextStyle(color: Colors.white),),
                ),
              const Spacer(),
              ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.red),
              ),
              onPressed: () {
                disputeInvoicePopup(data);
              }, 
              child: const Text('Dispute', style: TextStyle(color: Colors.white),),
              ),
                ]
              ),

              if (invoiceStatusLoading == true)
              const Center(child: CircularProgressIndicator()),
              if (invoiceStatusUpdated == true)
              const Column(children: <Widget>[
                Icon(Icons.check, color: Colors.green),
                Text('Invoice Accepted', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ]),
              if (invoiceStatusDisputedUpdated == true)
              const Column(children: <Widget>[
                Icon(Icons.check, color: Colors.red),
                Text('Invoice Disputed', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ]),
       
              ],
            ),
          ),
          actions: <Widget>[
            if (StoreProvider.of<AppState>(context).state.dashboardState.customerCurrentScreen == 'Seller')
            (data['InvoiceStatus'] == 'Pending' || data['InvoiceStatus'] == 'Disputed') ?
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.red),
              ),
              onPressed: () {
                openInvoiceEditPopUp(data);
                Navigator.of(context).pop();
              }, 
              child: const Text('Edit', style: TextStyle(color: Colors.white),),
              ) : const SizedBox.shrink(),
            if (StoreProvider.of<AppState>(context).state.dashboardState.customerCurrentScreen == 'Buyer')
            (data['InvoiceStatus'] == 'Accept') ?
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.green),
              ),
              onPressed: () {
                  makePaymentPopUp(data);
              }, 
              child: const Text('Make Payment', style: TextStyle(color: Colors.white),),
              ) : const SizedBox.shrink(),

            TextButton(
              onPressed: () {
                setState(() {
                  paymentAmountController.clear();
                  remarksController.clear();
                });
                StoreProvider.of<AppState>(context).dispatch(UpdatePaymentCreated(paymentCreated: false));
                store.dispatch(UpdateInvoiceStatusUpdated(invoiceStatusUpdated: false));
                store.dispatch(UpdateInvoiceDisputeStatusUpdated(invoiceDisputedStatusUpdated: false));
                store.dispatch(getInvoiceList(
                  <String, dynamic>{
                    "FilterQuery":
                    {   "Business":filterBusiness,
                        "Buyer":filterBuyer,
                        "BuyerBusiness":filterBuyerBusiness,
                        "CustomDateRange":
                        {
                            "From":selectedFromDate,
                            "To":selectedToDate
                            },
                        "DateRange":"",
                        "SearchKey":searchController.text,
                        "Seller":filterSeller,
                        "StatusType": selectedStatusFilter == 0 ? '' : selectedStatusFilter == 1 ? 'OverDue' : selectedStatusFilter == 2 ? 'DueToday' : selectedStatusFilter == 3 ? 'Upcoming' : ''
                        },
                        "InvoiceType": selectedFilterIndex == 0 ? 'Pending' : selectedFilterIndex == 1 ? 'Accept' : selectedFilterIndex == 2 ? 'Disputed' : '',
                        "PageNumber": pageNumber
                  }
                ));
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
      }
    );

  }

Future<void> attachImageFromGallery() async {
  final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
  if (pickedFile != null) {
    print('picked file ${pickedFile.path}');

    // Process the picked image
    // ...
  }
}


openInvoiceEditPopUp (invoice) {
  var screenWidth = MediaQuery.of(context).size.width;
  setState(() {
    invoiceAmountController.text = invoice['InvoiceAmount'].toString();
    invoiceDescriptionController.text = invoice['Description'] ?? '';
    selectedToDate = invoice['InvoiceDate'];
  });
  Future<void> openInvoiceEdit (invoice) async {
  final customerData = StoreProvider.of<AppState>(context).state.authState.customerData;
  await Future.delayed(Duration.zero);
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Edit Invoice'),
        content: SingleChildScrollView(
          child: 
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) =>
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                    width: screenWidth / 3.1,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.orange.shade200,
                      ),
                    padding: EdgeInsets.all(AppConfig.size(context, 10)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Invoice #', style: TextStyle(color: Colors.grey.shade800, fontSize: AppConfig.size(context, 14)),),
                        Text('${invoice['InvoiceNumber']}', style: TextStyle(color: Colors.grey.shade800, fontSize: AppConfig.size(context, 14)),),
                        const SizedBox(height: 5),
                        // date
                        Text('Date: ', style: TextStyle(color: Colors.grey.shade800, fontSize: AppConfig.size(context, 14)),),
                        Text(DateFormat('dd MMM yyyy').format(DateTime.parse(invoice['InvoiceDate'])), style: TextStyle(color: Colors.grey.shade800, fontSize: AppConfig.size(context, 14)),),
                      ],
                    ),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    width: screenWidth / 3.1,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.orange.shade200,
                      ),
                    padding: EdgeInsets.all(AppConfig.size(context, 10)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Amount:', style: TextStyle(color: Colors.grey.shade800, fontSize: AppConfig.size(context, 14)),),
                        Text('₹${convertAmount(invoice['InvoiceAmount'])}', style: TextStyle(color: Colors.grey.shade800, fontSize: AppConfig.size(context, 14)),),
                        const SizedBox(height: 5),
                        // date
                        Text('Due Date: ', style: TextStyle(color: Colors.grey.shade800, fontSize: AppConfig.size(context, 14)),),
                        Text(DateFormat('dd MMM yyyy').format(DateTime.parse(invoice['InvoiceDueDate'])), style: TextStyle(color: Colors.grey.shade800, fontSize: AppConfig.size(context, 14)),),
                      ],
                    ),
                  ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: <Widget>[
                    Container(
                    // billed to and from
                    width: screenWidth / 3.1,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.orange.shade200,
                      ),
                    padding: EdgeInsets.all(AppConfig.size(context, 10)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Billed To:', style: TextStyle(color: Colors.grey.shade800, fontSize: AppConfig.size(context, 14)),),
                        Text('${invoice['BuyerBusiness']['FirstName']} ${invoice['BuyerBusiness']['LastName']}', style: TextStyle(color: Colors.grey.shade800, fontSize: AppConfig.size(context, 14)),),
                      ],
                    ),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    // billed to and from
                    width: screenWidth / 3.1,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.orange.shade200,
                      ),
                    padding: EdgeInsets.all(AppConfig.size(context, 10)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Billed From:', style: TextStyle(color: Colors.grey.shade800, fontSize: AppConfig.size(context, 14)),),
                        Text('${invoice['Business']['FirstName']} ${invoice['Business']['LastName']}', style: TextStyle(color: Colors.grey.shade800, fontSize: AppConfig.size(context, 14)),),
                      ],
                    ),
                  ),
                  // option to edit invoice amount
                    
                  ],
                ),
                                const SizedBox(height: 5),
            
                Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.orange.shade200,
                      ),
                    padding: EdgeInsets.all(AppConfig.size(context, 10)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Edit Amount:', style: TextStyle(color: Colors.grey.shade800, fontSize: AppConfig.size(context, 14)),),
                        TextField(
                          controller: invoiceAmountController,
                          decoration: InputDecoration(
                            prefix: const Text('₹'),
                            hintText: 'Enter new amount',
                            hintStyle: TextStyle(color: Colors.grey.shade600),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // edit date
                  const SizedBox(height: 5),
                  Container(
                    width: screenWidth / 1.5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.orange.shade200,
                      ),
                    padding: EdgeInsets.all(AppConfig.size(context, 10)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Edit Invoice Date:', style: TextStyle(color: Colors.grey.shade800, fontSize: AppConfig.size(context, 14)),),
                        SizedBox(
                          child: OutlinedButton(
                            onPressed: () {
                              selectToDate(context, setState);
                            },
                            child: Text(selectedToDate != '' ? DateFormat('dd MMM yyyy').format(DateTime.parse(selectedToDate)) : 'Invoice Date', style: TextStyle(color: Colors.red.shade800, fontSize: AppConfig.size(context, 14)),),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // edit description
                  const SizedBox(height: 5),
                  Container(
                    width: screenWidth / 1.5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.orange.shade200,
                      ),
                    padding: EdgeInsets.all(AppConfig.size(context, 10)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Edit Description:', style: TextStyle(color: Colors.grey.shade800, fontSize: AppConfig.size(context, 14)),),
                        TextField(
                          controller: invoiceDescriptionController,
                          decoration: InputDecoration(
                            hintText: 'Enter new description',
                            hintStyle: TextStyle(color: Colors.grey.shade600),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ]
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.orange.shade800),
            ),
            onPressed: () {
              // update the invoice amount and date
              if (invoiceAmountController.text == '') {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Error'),
                      content: const Text('Invoice amount cannot be empty. Please enter a valid amount.'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Close'),
                        ),
                      ],
                    );
                  }
                );
                return;
              }
              // compare invoice controller amount with currencreditamount, if the amount is greater than currentcreditamount, show error
              if (double.parse(invoiceAmountController.text) > invoice['CurrentCreditAmount']) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Error'),
                      content:  Text('Invoice amount cannot be greater than available credit amount of ₹${invoice['CurrentCreditAmount']}.'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Close'),
                        ),
                      ],
                    );
                  }
                );
                return;
              } else {
              StoreProvider.of<AppState>(context).dispatch(editInvoice(<String, dynamic>{
                "Seller": customerData['_id'],
                "Business": invoice['Business']['_id'],
                "Buyer": invoice['Buyer']['_id'],
                "BuyerBusiness": invoice['BuyerBusiness']['_id'],
                "Invoice": invoice['_id'],
                "InvoiceNumber": invoice['InvoiceNumber'],
                "InvoiceStatus": invoice['InvoiceStatus'],
                "CurrentCreditAmount": invoice['CurrentCreditAmount'],
                "TemporaryCreditAmount": 1,
                "InvoiceDate": DateFormat('dd-MM-yyyy').format(DateTime.parse(selectedToDate)),
                "InvoiceAmount": (invoiceAmountController.text),
                "InvoiceDescription": invoiceDescriptionController.text,
                "InvoiceAttachments": []
                
              }));
              Navigator.of(context).pop();
              showLoadingUpdate();
              

              }

            },
            child: const Text('Update', style: TextStyle(color: Colors.white),),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      );
    }
  );
  }
  openInvoiceEdit(invoice);
}

Future<void> showLoadingUpdate () async {
    await Future.delayed(Duration.zero);
    var parser = EmojiParser();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return  StoreConnector<AppState, Store<AppState>>(
        converter: (store) => store,
        builder: (BuildContext context, store) {
          final invoiceCreateLoading = store.state.invoiceState.invoiceCreateLoading;
          return
                  AlertDialog(
                    title:  (invoiceCreateLoading ? const Text('Updating Invoice') : const Text('Invoice Updated Successfully')),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        if (invoiceCreateLoading)
                        const Text('Please wait while we update your invoice.'),
                        const SizedBox(height: 20),
                        if (invoiceCreateLoading)
                        const CircularProgressIndicator(),
                        if (!invoiceCreateLoading)
                        Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Text('Your invoice has been updated successfully!'),
                          const SizedBox(height: 20),
                          Text(parser.emojify(':tada: :tada: :tada:'), style: const TextStyle(fontSize: 30)),
                        ],
                      ),
                      ],
                    ),
                  );
        },
      );
      }
    );
  }

  Future<void> showCreateLoadingUpdate () async {
    await Future.delayed(Duration.zero);
    var parser = EmojiParser();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return  StoreConnector<AppState, Store<AppState>>(
        converter: (store) => store,
        builder: (BuildContext context, store) {
          final paymentcreateLoading = store.state.paymentsState.paymentCreateLoading;
          final paymentCreated = store.state.paymentsState.paymentCreated;

          return
                  AlertDialog(
                    title: paymentcreateLoading ? const Text('Making Payment') : paymentCreated ? const Text('Payment Made Successfully') : const Text('Payment Failed'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        if (paymentcreateLoading)
                        const Text('Please wait while we update your payment.'),
                        const SizedBox(height: 20),
                        if (paymentcreateLoading)
                        const CircularProgressIndicator(),
                        if (!paymentcreateLoading && paymentCreated)
                        Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Text('Your payment has been updated successfully!'),
                          const SizedBox(height: 20),
                          Text(parser.emojify(':tada: :tada: :tada:'), style: const TextStyle(fontSize: 30)),
                        ],
                      ),
                      if (!paymentcreateLoading && !paymentCreated)
                        Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Text('Your payment has failed!'),
                          const SizedBox(height: 20),
                         // emoji for error
                          Text(parser.emojify(':x: :x: :x:'), style: const TextStyle(fontSize: 30)),
                        ],
                      ),
                      ],
                    ),
                  );
        },
      );
      }
    );
  }

    Future<void> makePaymentPopUp (data) async {
      print('working at make payment popup');
      print('data $data');
    await Future.delayed(Duration.zero);
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Make Payment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // show paid amount
                Text('Invoice Amount: ₹${data['InvoiceAmount']}', style: TextStyle(color: Colors.grey.shade800, fontSize: AppConfig.size(context, 16)),),
                const SizedBox(height: 10),
                Text('Make Payment of ₹', style: TextStyle(color: Colors.grey.shade800, fontSize: AppConfig.size(context, 16)),),
                const SizedBox(height: 10),
                TextField(
                  controller: paymentAmountController,
                  // allow only numbers
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: 'Amount',
                    prefix: const Text('₹'),
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // field to enter remarks
                TextField(
                  controller: remarksController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Remarks',
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
                // show botton to attach images

                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.green.shade800),
                      ),
                      onPressed:(){
                        if (paymentAmountController.text == '') {
                          showDialog(
                            context: context, 
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Error'),
                                content: const Text('Please enter the amount'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Close'),
                                  ),
                                ],
                              );
                            }
                          );
                          return;
                        }
                        // paymentAmountcontroller.text must be less than data['InvoiceAmount]
                        if (double.parse(paymentAmountController.text) > data['InvoiceAmount']) {
                          showDialog(
                            context: context, 
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Error'),
                                content: const Text('Payment amount cannot be greater than invoice amount.'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Close'),
                                  ),
                                ],
                              );
                            }
                          );
                          return;
                        }
                        // show dialog to confirm
                        print('data $data');
                        StoreProvider.of<AppState>(context).dispatch(makePayment(<String, dynamic>{
                          'Seller': data['Seller']['_id'],
                          'Business': data['Business']['_id'],
                          'Buyer': data['Buyer']['_id'],
                          'BuyerBusiness': data['BuyerBusiness']['_id'],
                          'InvoiceDetails': [data],
                          'PaymentAmount': paymentAmountController.text,
                          'Remarks': remarksController.text,
                          'PaymentId': data['_id'],
                          'PaymentStatus': 'Disputed',
                          'PaymentMode': 'Cash',
                        }));
                        showCreateLoadingUpdate();
                        Navigator.of(context).pop();
                      }, 
                      child:const Text('Update', style: TextStyle(color: Colors.white)),
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.red.shade800),
                      ),
                      onPressed:(){
                        // show dialog to confir
                        Navigator.of(context).pop();
                      }, 
                      child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
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
      },
    );
  }
    

        

    

  




  @override
  Widget build(BuildContext context ) {
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
        final invoiceList = store.state.invoiceState.invoiceList;
        final invoiceListLocal = store.state.invoiceState.invoiceListLocal;
        final loading = store.state.invoiceState.loading;
        final invoiceListLoaded = store.state.invoiceState.invoiceListLoaded;
        final error = store.state.invoiceState.error;
        final invoiceListEndReached = store.state.invoiceState.invoiceListEndReached;
        final myBusinessList = store.state.businessState.myBusinessList;
        final invoiceStatusType = store.state.invoiceState.invoiceStatusType;
        final invoiceCreated = store.state.invoiceState.invoiceCreated;
        final invoiceCreateLoading = store.state.invoiceState.invoiceCreateLoading;
        final createSendButton = store.state.dashboardState.createSendButton;

       

        
        onBuyerSelected (filterBuyer){
          // filter the buyer list from sellerBusinessCustomerList
          setState(() {
            buyerBusinessList = store.state.businessState.sellerBusinessCustomerList.where((element) => element['_id'] == filterBuyer).toList();

          });
        }

        if (myBusinessList.isEmpty && store.state.businessState.businessListLoaded == 0) {
          store.dispatch(UpdateBusinessListLoaded(businessListLoaded: 1));
          store.dispatch(getMyBusinessList);
        }

        // if (invoiceCreated) {
        //   store.dispatch(UpdateInvoiceCreated(invoiceCreated: false));
        //   // alert pop up dialog invoice created successfully with attractive emoji animation
        //   Future<void> showSuccess () async {
        //     await Future.delayed(Duration.zero);
        //    var parser = EmojiParser();
        //     showDialog(
        //       context: context,
        //       builder: (BuildContext context) {
        //         return AlertDialog(
        //           title: const Text('Invoice Created Successfully'),
        //           content: Column(
        //             mainAxisSize: MainAxisSize.min,
        //             children: <Widget>[
        //               const Text('Your invoice has been created successfully!'),
        //               const SizedBox(height: 20),
        //               Text(parser.emojify(':tada: :tada: :tada:'), style: const TextStyle(fontSize: 30)),
        //             ],
        //           ),
        //           actions: <Widget>[
        //             ElevatedButton(
        //               child: const Text('OK'),
        //               onPressed: () {
        //                 Navigator.of(context).pop();
        //               },
        //             ),
        //           ],
        //         );
              
        //       }
    
        //     );
        //   }
        //   showSuccess();
        // }

          Future<void> showLoading () async {
            await Future.delayed(Duration.zero);
            var parser = EmojiParser();
            await showDialog(
              context: context,
              builder: (BuildContext context) {
                return  StoreConnector<AppState, Store<AppState>>(
                converter: (store) => store,
                builder: (BuildContext context, store) {
                  return
                          AlertDialog(
                            title: invoiceCreateLoading ? const Text('Creating Invoice') : const Text('Invoice Created Successfully'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                if (invoiceCreateLoading)
                                const Text('Please wait while we create your invoice.'),
                                const SizedBox(height: 20),
                                if (invoiceCreateLoading)
                                const CircularProgressIndicator(),
                                if (!invoiceCreateLoading)
                                Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  const Text('Your invoice has been created successfully!'),
                                  const SizedBox(height: 20),
                                  Text(parser.emojify(':tada: :tada: :tada:'), style: const TextStyle(fontSize: 30)),
                                ],
                              ),
                              if (error != '')
                              Text(error, style: const TextStyle(color: Colors.red),),
                              ],
                            ),
                          );
                },
              );
              }
            );
          }

    if (invoiceCreated) {
      filterBusiness = '';
      filterBuyer = '';
      filterBuyerBusiness = '';
      invoiceNumberController.text = '';
      invoiceAmountController.text = '';
      selectedStatusFilter = 0;
      selectedStatusFilter = 0;
      store.dispatch(UpdateInvoiceCreated(invoiceCreated: false));
      startLoading = true;
    }

    
    
          
        

    Future<void> businessSearchPopup() async {
      
    await showDialog(
      context: context,
      builder: (BuildContext context ) {
        return StoreConnector<AppState, Store<AppState>>(
      converter: (store) => store,
      builder: (BuildContext context, store) {
        final sellerBusinessCustomerList = store.state.businessState.sellerBusinessCustomerList;
        return
        AlertDialog(
          title: const Text('Search'),
          content: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) =>
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // searchbar
                  DropdownSearch(
                    popupProps: PopupProps.menu(
                      //showSelectedItems: true,
                      showSearchBox: true,
                      searchFieldProps: TextFieldProps(
                        controller: businessSearchController,
                        decoration: InputDecoration(
                          hintText: 'Search by business name',
                          hintStyle: TextStyle(color: Colors.grey.shade600),
                          prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    items: myBusinessList.map((e) => e['FirstName'].toString()).toList(),
                    onChanged: (value) => {
                      // find the business id from the list
                      onBusinessSelected(myBusinessList.firstWhere((element) => element['FirstName'] == value)['_id'])
                     
                    },
                    dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      hintText: 'Your Business',
                      contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.orange),
                      ),
                    ),
                    
                  ),
                  ),
                  const SizedBox(height: 10),
                  if (sellerBusinessCustomerList.isNotEmpty)
                  DropdownSearch(
                    popupProps: PopupProps.menu(
                      //showSelectedItems: true,
                      showSearchBox: true,
                      searchFieldProps: TextFieldProps(
                        decoration: InputDecoration(
                          hintText: 'Search by buyer name',
                          hintStyle: TextStyle(color: Colors.grey.shade600),
                          prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    items: sellerBusinessCustomerList.map((e) => '${e['Name']}').toList(),
                    onChanged: (value) => {
                      setState(() {
                        filterBuyer = sellerBusinessCustomerList.firstWhere((element) => element['Name'] == value)['_id'];
                        onBuyerSelected(filterBuyer);
                      }),
                    },
                    dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      hintText: 'Buyer',
                      contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.orange),
                      ),
                    ),
                    
                  ),
                  ),
                  const SizedBox(height: 10),
                  if (buyerBusinessList.isNotEmpty)
                  DropdownSearch(
                    popupProps: PopupProps.menu(
                      //showSelectedItems: true,
                      showSearchBox: true,
                      searchFieldProps: TextFieldProps(
                        decoration: InputDecoration(
                          hintText: 'Search by buyer business',
                          hintStyle: TextStyle(color: Colors.grey.shade600),
                          prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    items: buyerBusinessList.map((e) => '${e['FirstName']} ${e['LastName']}').toList(),
                    onChanged: (value) => {
                      setState(() {
                        filterBuyerBusiness = buyerBusinessList.firstWhere((element) => '${element['FirstName']} ${element['LastName']}' == value)['_id'];
                      }),
                    },
                    dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      hintText: 'Buyer Business',
                      contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.orange),
                      ),
                    ),
                    
                  ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      SizedBox(
                        child: ElevatedButton(
                          onPressed: () {
                            onSearchClicked();
                            Navigator.of(context).pop();
                          },
                          child: Text('Search', style: TextStyle(color: (customerCurrentScreen == 'Seller' ? Colors.orange.shade800 : Colors.blue.shade800), fontSize: AppConfig.size(context, 16)),),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // setState(() {
                //   filterBusiness = '';
                //   filterBuyer = '';
                //   filterBuyerBusiness = '';
                //   buyerBusinessList = [];
                // });
                // store.dispatch(UpdateSellerBusinsessCustomerList(sellerBusinessCustomerList: []));
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
    }
    );
  }


        if (error != '') {
          store.dispatch(InvoiceFailedAction(error: ''));
          Future<void> errorPopup () async {
            await Future.delayed(Duration.zero);
            await showDialog(
              context: context, 
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Error'),
                  content: Text(error),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Close'),
                    ),
                  ],
                );
              }
            );
          } 
          errorPopup();
        }
        

        if (invoiceList.isEmpty && invoiceListLoaded == 0 && invoiceStatusType.isEmpty) {
          store.dispatch(UpdateInvoiceListLoaded(invoiceListLoaded: 1));
          store.dispatch(getInvoiceList(<String, dynamic>{
            "FilterQuery":
        {   "Business":"",
            "Buyer":"",
            "BuyerBusiness":"",
            "CustomDateRange":
            {
                "From":"",
                "To":""
                },
            "DateRange":"",
            "SearchKey":"",
            "Seller":"",
            "StatusType":""
            },
            "InvoiceType":"",
            "PageNumber":1
          }));
        }

        if (invoiceList.isNotEmpty && invoiceTypedUpdated == false) {
          
          invoiceTypedUpdated = true;
          if (invoiceList['ActiveTab'] == 'Pending') {
            selectedFilterIndex = 0;
            store.dispatch(UpdateInvoiceListLocal(invoiceListLocal: 
            invoiceList['InvoiceList'].where((element) => element['InvoiceStatus'] == 'Pending').toList()
            ));
          } else if (invoiceList['ActiveTab'] == 'Accept') {
            selectedFilterIndex = 1;
            store.dispatch(UpdateInvoiceListLocal(invoiceListLocal:
            invoiceList['InvoiceList'].where((element) => element['InvoiceStatus'] == 'Accept').toList()
            ));
          } else if (invoiceList['ActiveTab'] == 'Disputed') {
            selectedFilterIndex = 2;
            store.dispatch(UpdateInvoiceListLocal(invoiceListLocal:
            invoiceList['InvoiceList'].where((element) => element['InvoiceStatus'] == 'Disputed').toList()
            ));
          } else{
            selectedFilterIndex = 1;
          }
        }
          

    
        if (invoiceStatusType.isNotEmpty) {
          store.dispatch(UpdateInvoiceListLoaded(invoiceListLoaded: 2));
          store.dispatch(UpdateInvoiceStatusType(invoiceStatusType: ''));
          store.dispatch(UpdateInvoiceList(invoiceList: {}));
          store.dispatch(UpdateInvoiceListLocal(invoiceListLocal: []));
          if (invoiceStatusType == 'Overdue') {
            selectedStatusFilter = 1;
          } else if (invoiceStatusType == 'Due Today') {
            selectedStatusFilter = 2;
          } else if (invoiceStatusType == 'Upcoming') {
            selectedStatusFilter = 3;
          } else if (invoiceStatusType == 'Disputed') {
            selectedFilterIndex = 2;
          } else {
            selectedStatusFilter = 0;
          }
          startLoading = true;

        }

      if (startLoading == true) {
        store.dispatch(UpdateInvoiceList(invoiceList: {}));
        store.dispatch(UpdateInvoiceListLocal(invoiceListLocal: []));

        startLoading = false;

      print('searchController.text ${searchController.text}');
        if (searchController.text != '') {
          selectedDateFilter = -1;
          selectedStatusFilter = 0;
          selectedFilterIndex = -1;
        }

        if (selectedDateFilter == 4){
          searchController.text = '';
          selectedStatusFilter = 0;
          selectedFilterIndex = -1;
        }

     
        StoreProvider.of<AppState>(context).dispatch(getInvoiceList(<String, dynamic>{
            "FilterQuery":
        {   "Business":filterBusiness,
            "Buyer":filterBuyer,
            "BuyerBusiness":filterBuyerBusiness,
            "CustomDateRange":
            {
                "From":selectedFromDate,
                "To":selectedToDate
                },
            "DateRange": selectedDateFilter == 0 ? 'CurrentWeek' : selectedDateFilter == 1 ? 'LastWeek' : selectedDateFilter == 2 ? 'CurrentMonth' : selectedDateFilter == 3 ? 'LastMonth' : selectedDateFilter == 4 ? 'Custom' : '',
            "SearchKey": searchController.text,
            "Seller":filterSeller,
            "StatusType": selectedStatusFilter == 0 ? '' : selectedStatusFilter == 1 ? 'OverDue' : selectedStatusFilter == 2 ? 'DueToday' : selectedStatusFilter == 3 ? 'Upcoming' : ''
            },
            "InvoiceType": (selectedStatusFilter != 0 || selectedDateFilter != -1) ? '' : selectedFilterIndex == 0 ? 'Pending' : selectedFilterIndex == 1 ? 'Accept' : selectedFilterIndex == 2 ? 'Disputed' : '',
            "PageNumber":1
          }));
               
          if (selectedStatusFilter != 0){
            selectedFilterIndex = 1;
          }
    
            filterBusiness = '';
            filterBuyer = '';
            filterBuyerBusiness = '';
            buyerBusinessList = [];

          store.dispatch(UpdateSellerBusinsessCustomerList(sellerBusinessCustomerList: []));
      }

        createInvoiceClicked () {
          final sellerBusinessCustomerList = store.state.businessState.sellerBusinessCustomerList;
          // alert if invoicenumber is empty
            store.dispatch(createInvoice(<String, dynamic>{
              "Seller": customerData['_id'],
              "Business": filterBusiness,
              "Buyer": filterBuyer,
              "BuyerBusiness": filterBuyerBusiness,
              "InvoiceNumber": invoiceNumberController.text,
              "InvoiceAmount": invoiceAmountController.text,
              "Description": invoiceDescriptionController.text,
              "CurrentCreditAmount": sellerBusinessCustomerList.firstWhere((element) => element['_id'] == filterBuyer)['AvailableCreditLimit'],
              "TemporaryCreditAmount": '0',
              "InvoiceDate": DateTime.now().toString(),
              
            }));
            showLoading();
        }


        Future<void> onAddClickInvoicePage() async {
          await  Future.delayed(Duration.zero);
          await showDialog(
            context: context, 
            builder: (BuildContext context) {
              return StoreConnector<AppState, Store<AppState>>(
              converter: (store) => store,
              builder: (BuildContext context, store) {
              final sellerBusinessCustomerList = store.state.businessState.sellerBusinessCustomerList;
              return
              AlertDialog(
                title: const Text('Create Invoice'),
                content: SingleChildScrollView(
                  child: StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) =>
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // searchbar
                        DropdownSearch(
                          popupProps: PopupProps.menu(
                                                      
                            showSearchBox: true,
                            searchFieldProps: TextFieldProps(
                              
                              controller: businessSearchController,
                              decoration: InputDecoration(
                                hintText: 'Search by business name',
                                hintStyle: TextStyle(color: Colors.grey.shade600),
                                prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                          items: myBusinessList.map((e) => e['FirstName'].toString()).toList(),
                          onChanged: (value) => {
                            // find the business id from the list
                            onBusinessSelected(myBusinessList.firstWhere((element) => element['FirstName'] == value)['_id'])
                          },
                          dropdownDecoratorProps: DropDownDecoratorProps(
                            
                          dropdownSearchDecoration: InputDecoration(
                            
                            hintText: 'Your Business',
                            contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:  BorderSide(color: customerCurrentScreen == 'Seller' ? Colors.orange : Colors.blue),
                            ),
                          ),
                          
                        ),
                        ),
                        const SizedBox(height: 10),
                        if (sellerBusinessCustomerList.isNotEmpty)
                        DropdownSearch(
                          popupProps: PopupProps.menu(
                            //showSelectedItems: true,
                            showSearchBox: true,
                            searchFieldProps: TextFieldProps(
                              decoration: InputDecoration(
                                hintText: 'Search by buyer name',
                                hintStyle: TextStyle(color: Colors.grey.shade600),
                                prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                          items: sellerBusinessCustomerList.map((e) => '${e['Name']}').toList(),
                          onChanged: (value) => {
                            setState(() {
                              filterBuyer = sellerBusinessCustomerList.firstWhere((element) => element['Name'] == value)['_id'];
                              onBuyerSelected(filterBuyer);
                            }),
                          },
                          dropdownDecoratorProps: DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            hintText: 'Buyer',
                            contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:  BorderSide(color: customerCurrentScreen == 'Seller' ? Colors.orange : Colors.blue),
                            ),
                          ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (buyerBusinessList.isNotEmpty)
                        DropdownSearch(
                          popupProps: PopupProps.menu(
                            //showSelectedItems: true,
                            showSearchBox: true,
                            searchFieldProps: TextFieldProps(
                              decoration: InputDecoration(
                                hintText: 'Search by buyer business',
                                hintStyle: TextStyle(color: Colors.grey.shade600),
                                prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                          items: buyerBusinessList.map((e) => '${e['FirstName']} ${e['LastName']}').toList(),
                          onChanged: (value) => {
                            // get buyerbusiness id

                            setState(() {
                              filterBuyerBusiness = buyerBusinessList.firstWhere((element) => '${element['FirstName']} ${element['LastName']}' == value)['inviteData']['BuyerBusiness']['_id'];
                              filterBusinessCreditLimit = buyerBusinessList.firstWhere((element) => '${element['FirstName']} ${element['LastName']}' == value)['AvailableCreditLimit'];
                              print('filterbusinesslimit $filterBusinessCreditLimit');

                            }),
                          },
                          dropdownDecoratorProps: DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            hintText: 'Buyer Business',
                            contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:  BorderSide(color: customerCurrentScreen == 'Seller' ? Colors.orange : Colors.blue),
                            ),
                          ),
                          
                        ),
                        ),
                        if (filterBusiness != '' && filterBuyer != '' && filterBuyerBusiness != '' )
                        Column(
                          children: <Widget>[
                        const SizedBox(height: 10),
                        
                        TextField(
                          controller: invoiceNumberController,
                          //allow only caps
                          inputFormatters: [UpperCaseTextFormatter()],
                          decoration: InputDecoration(
                            hintText: 'Invoice Number',
                            hintStyle: TextStyle(color: Colors.grey.shade600),
                            prefixIcon: Icon(Icons.receipt, color: Colors.grey.shade600),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: invoiceAmountController,
                          // allow only numbers and decimal
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                          decoration: InputDecoration(
                            hintText: 'Invoice Amount',
                            hintStyle: TextStyle(color: Colors.grey.shade600),
                            
                            prefixIcon: Icon(Icons.money, color: Colors.grey.shade600),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                          ),
                        ),
                        // show available credit limit in the bottom of the invoice amount text field
                        Text('Available Credit Limit: ₹$filterBusinessCreditLimit', style: TextStyle(color: Colors.grey.shade600, fontSize: AppConfig.size(context, 14)),),
                        // const SizedBox(height: 10),
                        // SizedBox(
                        //   width: double.infinity,
                        //   child: OutlinedButton.icon(
                        //     icon: Icon(Icons.calendar_today, color: Colors.grey.shade600),
                        //     label: Text(selectedFromDate != '' ? DateFormat('MMM dd, yyyy').format(DateTime.parse(selectedFromDate)) : 'Invoice Date', style: TextStyle(color: Colors.grey.shade600, fontSize: AppConfig.size(context, 14)),),
                        //     style: ButtonStyle(
                        //       shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        //         RoundedRectangleBorder(
                        //           borderRadius: BorderRadius.circular(10),
                        //         ),
                        //       ),
                        //       alignment: Alignment.centerLeft,
                        //     ),
                        //     onPressed: () {
                        //       print('date picker');
                        //       selectFromDate(context, setState);
                        //     }, 
                        //     ),
                        // ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: invoiceDescriptionController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText: 'Invoice Description',
                            hintStyle: TextStyle(color: Colors.grey.shade600),
                            prefixIcon: Icon(Icons.description, color: Colors.grey.shade600),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // allow to attach files or image from gallery
                    TextButton(
                      onPressed: () {
                        // Code to open gallery and select files or images
                      },
                      child: const Text('Attach image from gallery or take photo'),
                    ),
                    ],
                    ),
                  if (filterBusiness != '' && filterBuyer != '' && filterBuyerBusiness != '')
                  ElevatedButton(
                    onPressed: () {
                      if (invoiceNumberController.text == '') {
                        Future<void> alertPopup () async {
                          await showDialog(
                            context: context, 
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Error'),
                                content: const Text('Invoice number cannot be empty.'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Close'),
                                  ),
                                ],
                              );
                            }
                          );
                        }
                        alertPopup();
                      } else if (invoiceAmountController.text == '') {
                        Future<void> alertPopup () async {
                          await showDialog(
                            context: context, 
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Error'),
                                content: const Text('Invoice amount cannot be empty.'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Close'),
                                  ),
                                ],
                              );
                            }
                          );
                        }
                        alertPopup();
                      } // compare whether invoiceamountcontroller.text is greater than filterbusinesscreditlimit
                      else if (int.parse(invoiceAmountController.text) > filterBusinessCreditLimit) {
                        Future<void> alertPopup () async {
                          await showDialog(
                            context: context, 
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Error'),
                                content: const Text('Invoice amount cannot be greater than available credit limit.'),
                                actions: <Widget>[
                                  ElevatedButton(
                                    onPressed: (){
                                      store.dispatch(getInviteList);
                                      store.dispatch(UpdateEditRequestFromInvoice(editRequestFromInvoice: true));
                                      store.dispatch(UpdateEditRequestBuyerId(editRequestBuyerId: filterBuyerBusiness));
                                      store.dispatch(UpdateSelectedBottomNavIndexAction(1));
                                      // navigate to invitelist page
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => const InviteListPage()));

                                    }, 
                                    child: const Text('Edit Credit Limit'),
                                    ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Close'),
                                  ),
                                ],
                              );
                            }
                          );
                        }
                        alertPopup();
                      }
                      else 
                       {
                        createInvoiceClicked();
                        Navigator.pop(context);
                      }
                      // listen to invoice number controller

                      //Navigator.of(context).pop();
                      
                    },
                    child: Text('Create Invoice', style: TextStyle(color: customerCurrentScreen == 'Seller' ? Colors.orange.shade800 : Colors.blue.shade800, fontSize: AppConfig.size(context, 16)),),
                  ),
                      ],
                    ),
                  ),
                ),
                actions: <Widget>[
                  
                  TextButton(
                    onPressed: () {
                      setState(() {
                        filterBusiness = '';
                        filterBuyer = '';
                        filterBuyerBusiness = '';
                        buyerBusinessList = [];
                        invoiceAmountController.clear();
                        invoiceNumberController.clear();
                        invoiceDescriptionController.clear();

                      });
                      store.dispatch(UpdateSellerBusinsessCustomerList(sellerBusinessCustomerList: []));
                      Navigator.of(context).pop();
                    },
                    child: const Text('Close'),
                  ),
                ],
              );
              },
              );
            },
          );
        }

         if (createSendButton == 'Create Invoice') {
          store.dispatch(UpdateCreateSendButton(''));
          onAddClickInvoicePage();

        }




        return Scaffold(
          key: scaffoldKey,
          appBar: PreferredSize(
            preferredSize:  BoxConstraints.tightFor(height: AppConfig.size(context, 45)).smallest,
            child: WidgetHelper.getAppBar(context, 'Invoices', openDrawer, customerCurrentScreen == 'Seller' ? Colors.orange : Colors.deepPurple.shade900, onAddClickInvoicePage),
          ),
      bottomNavigationBar: const BottomNavigation(),
    drawer: WidgetHelper.leftNavigationBar(context, screenIndex, customerData['ContactName'], customerData['Mobile'], customerCurrentScreen == 'Seller' ? Colors.orange : Colors.deepPurple.shade900),
    body: Center(
      child: 
      loading ?
      const CircularProgressIndicator() :
      Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                color: selectedFilterIndex == 0 ? (customerCurrentScreen == 'Seller' ? Colors.orange.shade800 : Colors.blue.shade800) : Colors.grey.shade600,
                width: screenWidth/3,
                height: AppConfig.size(context, 40),
                child: Padding(
                  padding: EdgeInsets.all(AppConfig.size(context, 1)),
                  child: Center(
                    child: TextButton(
                      onPressed: () {
                        if (selectedStatusFilter == 0) {
                        setState(() {
                          selectedFilterIndex = 0;
                          //startLoading = true;
                        });
                        // dispatch invoicelistlocal with pending
                        store.dispatch(UpdateInvoiceListLocal(invoiceListLocal: invoiceList['InvoiceList'].where((element) => element['InvoiceStatus'] == 'Pending').toList()));
                        }
                      },
                      child: FittedBox(child: Text('Open (${invoiceList['OpenCount']})', style: TextStyle(color: Colors.white, fontSize: AppConfig.size(context, 14)),)),
                    ),
                  ),
                ),
              ),
              Container(
                color: selectedFilterIndex == 1 ? (customerCurrentScreen == 'Seller' ? Colors.orange.shade800 : Colors.blue.shade800)  : Colors.grey.shade600,
                width: screenWidth/3,
                height: AppConfig.size(context, 40),
                child: Padding(
                  padding: EdgeInsets.all(AppConfig.size(context, 1)),
                  child: Center(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          selectedFilterIndex = 1;
                          //startLoading = true;
                        });
                        // dispatch invoicelistlocal with accept
                        store.dispatch(UpdateInvoiceListLocal(invoiceListLocal: invoiceList['InvoiceList'].where((element) => element['InvoiceStatus'] == 'Accept').toList()));
                      },
                      child: FittedBox(
                        child: Text('Accepted (${invoiceList['AcceptCount']})', style: const TextStyle(color: Colors.white),
                        maxLines: 2,
                        softWrap: true,
                        )
                        ),
                    ),
                  ),
                ),
              ),
              Container(
                color: selectedFilterIndex == 2 ? (customerCurrentScreen == 'Seller' ? Colors.orange.shade800 : Colors.blue.shade800)  : Colors.grey.shade600,
                width: screenWidth/3,
                height: AppConfig.size(context, 40),
                child: Padding(
                  padding: EdgeInsets.all(AppConfig.size(context, 1)),
                  child: Center(
                    child: TextButton(
                      onPressed: () {
                        if (selectedStatusFilter == 0) {
                            setState(() {
                          selectedFilterIndex = 2;
                          //startLoading = true;
                        });
                        }
                        // dispatch invoicelistlocal with disputed
                        store.dispatch(UpdateInvoiceListLocal(invoiceListLocal: invoiceList['InvoiceList'].where((element) => element['InvoiceStatus'] == 'Disputed').toList()));
                      },
                      child: FittedBox(child: Text('Disputed (${invoiceList['DisputeCount']})', style: TextStyle(color: Colors.white, fontSize: AppConfig.size(context, 14)),)),
                    ),
                  ),
                ),
              ),
              
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // add icon in the left for date filter and icon in the right for business filter
              Padding(
                padding: EdgeInsets.only(top: AppConfig.size(context, 3)),
                child: Container(
                  //color: Colors.orange,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(topRight: Radius.circular(15), bottomRight: Radius.circular(15)),
                    color: (customerCurrentScreen == 'Seller' ? Colors.orange.shade800 : Colors.blue.shade800),
                  ),
                  child: IconButton(
                    onPressed: () {
                      dateFilterPopup(customerCurrentScreen);
                    }, 
                    icon: Icon(Icons.manage_search, color: Colors.white, size: AppConfig.size(context, 30),),
                    ),
                ),
              ),
              SizedBox(
                width: screenWidth/4,
                child: Text('Filter by date & status', style: TextStyle(color: (customerCurrentScreen == 'Seller' ? Colors.orange.shade800 : Colors.blue.shade800), fontSize: AppConfig.size(context, 14)),)),
              SizedBox(width: AppConfig.size(context, 10)),
              // add iconbutton with clear icon
               IconButton(
                    onPressed: () {
                      setState(() {
                        selectedFromDate = '';
                        selectedToDate = '';
                        selectedDateFilter = -1;
                        selectedStatusFilter = 0;
                        searchController.clear();
                        filterBusiness = '';
                        filterBuyer = '';
                        filterBuyerBusiness = '';
                        buyerBusinessList = [];
                        startLoading = true;

                      });
                    }, 
                    icon: Icon(Icons.refresh_rounded, color: (customerCurrentScreen == 'Seller' ? Colors.orange.shade800 : Colors.blue.shade800), size: AppConfig.size(context, 30),),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                SizedBox(
                  width: screenWidth/4,
                  child: Text('Filter by business', style: TextStyle(color: (customerCurrentScreen == 'Seller' ? Colors.orange.shade800 : Colors.blue.shade800), fontSize: AppConfig.size(context, 14)))),
              
              Padding(
                padding: EdgeInsets.only(top: AppConfig.size(context, 3)),
                child: Container(
                  //color: Colors.orange,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), bottomLeft: Radius.circular(15)),
                    color: (customerCurrentScreen == 'Seller' ? Colors.orange.shade800 : Colors.blue.shade800),
                  ),
                  child: IconButton(
                    onPressed: () {
                      businessSearchPopup();
                      
                    }, 
                    icon: Icon(Icons.business, color: Colors.white, size: AppConfig.size(context, 30),),
                    ),
                ),
              ),
                ],
              ),

            ],),
            invoiceListLocal.isNotEmpty ?
            Expanded(
              child: ListView.builder(
                controller: invoiceListEndReached ? null : scrollController,
                itemCount: invoiceListLocal.length,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, index) {
                  //return invoiceCard(context, invoiceListLocal[index], screenWidth);
                  if (index != invoiceListLocal.length) {
                    return 
                    InkWell(
                      onTap: () {
                        openInvoiceDetailsPopUp(invoiceListLocal[index]);
                      },
                      child: invoiceCard(context, invoiceListLocal[index], screenWidth),
                    );
                  } else {
                    return  Center(child: 
                    invoiceListEndReached ?
                    Text('End of the list', style: TextStyle(color: Colors.grey.shade600, fontSize: 16),) :
                    const CircularProgressIndicator(),
                    );

                  }
                },
              ),
            ) : 
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(Icons.receipt, size: 100, color: Colors.grey),
                  const SizedBox(height: 10),
                  Text('No Data', style: TextStyle(color: Colors.grey.shade600, fontSize: AppConfig.size(context, 16)),),
                  const SizedBox(height: 10),
                  // button with refresh option which cleas all filters
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedFromDate = '';
                        selectedToDate = '';
                        selectedDateFilter = -1;
                        selectedStatusFilter = 0;
                        searchController.clear();
                        filterBusiness = '';
                        filterBuyer = '';
                        filterBuyerBusiness = '';
                        buyerBusinessList = [];
                        startLoading = true;

                      });
                    },
                    child: Text('Refresh', style: TextStyle(color: (customerCurrentScreen == 'Seller' ? Colors.orange.shade800 : Colors.blue) , fontSize: AppConfig.size(context, 16)),),
                  ),
                ],
              ),
            ),
        ],
      ),
    ),
  );
}
);
}

}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}