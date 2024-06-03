// ignore_for_file: use_build_context_synchronously

import 'dart:math';

import 'package:aquila_hundi/app/helper_widgets/appbar.dart';
import 'package:aquila_hundi/app/helper_widgets/bottom_navigation.dart';
import 'package:aquila_hundi/app/helper_widgets/config.dart';
import 'package:aquila_hundi/app/modules/Dashboard/dashboard_page.dart';
import 'package:aquila_hundi/store/app.state.dart';
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



class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  PaymentsPageState createState() => PaymentsPageState();
}

class PaymentsPageState extends State<PaymentsPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int screenIndex = -1;
  int selectedFilterIndex = 1;
  int selectedStatusFilter = 0;
  int selectedDateFilter = -1;
  String selectedFromDate = '';
  String selectedToDate = '';
  String filterBusiness = '';
  String filterBuyer = '';
  String filterBuyerBusiness = '';
  String filterInvoiceNumber = '';
  String filterSeller = '';
  String filterStatusType = 'All';
  TextEditingController searchController = TextEditingController();
  String invoiceAmount = '0';
  TextEditingController invoiceAmountController = TextEditingController();
  String paymentMode = 'Cash';
  TextEditingController remarksController = TextEditingController();
  TextEditingController businessSearchController = TextEditingController();
  int pageNumber = 1;
  bool updatePaymentSubmitted = false;
  ScrollController scrollController = ScrollController();
  bool startLoading = false;
  List buyerBusinessList = [];

@override 
void initState () {
  super.initState();
  scrollController.addListener(() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      setState(() {
        pageNumber = pageNumber + 1;
      });
      StoreProvider.of<AppState>(context).dispatch(getPaymentsList(<String, dynamic>{
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
            "StatusType": selectedStatusFilter == 0 ? 'All' : selectedStatusFilter == 1 ? 'OverDue' : selectedStatusFilter == 2 ? 'DueToday' : selectedStatusFilter == 3 ? 'Upcoming' : 'All'
            },
            "PaymentType": selectedFilterIndex == 0 ? 'Pending' : selectedFilterIndex == 1 ? 'Accept' : selectedFilterIndex == 2 ? 'Disputed' : '',
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

  

  Future<void> dateFilterPopup(customerCurrentScreen) async {
    print('date filter');
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
                      hintText: 'Search by payment number',
                      hintStyle: TextStyle(color: Colors.grey.shade600),
                      prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                    ),
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
                        backgroundColor: selectedDateFilter == 0 ? (customerCurrentScreen == 'Seller' ? Colors.orange.shade800 : Colors.blue.shade800) : Colors.grey.shade300,
                        onSelected: (bool value) {
                          setState(() {
                            selectedDateFilter = 0;
                          });
                        },
                      ),
                      FilterChip(
                        label: const Text('Last Week'),
                        labelStyle: TextStyle(color: selectedDateFilter == 1 ? Colors.white : Colors.grey.shade600),
                         backgroundColor: selectedDateFilter == 1 ? (customerCurrentScreen == 'Seller' ? Colors.orange.shade800 : Colors.blue.shade800) : Colors.grey.shade300,
                        onSelected: (bool value) {
                          setState(() {
                            selectedDateFilter = 1;
                          });
                        },
                      ),
                      FilterChip(
                        label: const Text('Current Month'),
                        labelStyle: TextStyle(color: selectedDateFilter == 2 ? Colors.white : Colors.grey.shade600),
                         backgroundColor: selectedDateFilter == 2 ? (customerCurrentScreen == 'Seller' ? Colors.orange.shade800 : Colors.blue.shade800) : Colors.grey.shade300,
                        onSelected: (bool value) {
                          setState(() {
                            selectedDateFilter = 2;
                          });
                        },
                      ),
                      FilterChip(
                        label: const Text('Last Month'),
                        labelStyle: TextStyle(color: selectedDateFilter == 3 ? Colors.white : Colors.grey.shade600),
                         backgroundColor: selectedDateFilter == 3 ? (customerCurrentScreen == 'Seller' ? Colors.orange.shade800 : Colors.blue.shade800) : Colors.grey.shade300,
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
                          child: Text(selectedFromDate != '' ? DateFormat('dd MMM, yyyy').format(DateTime.parse(selectedFromDate)) : 'From Date', style: TextStyle(color: (customerCurrentScreen == 'Seller' ? Colors.orange.shade800 : Colors.blue.shade800), fontSize: AppConfig.size(context, 14)),),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // date picker
                      SizedBox(
                        child: OutlinedButton(
                          onPressed: () {
                            selectToDate(context, setState);
                          },
                          child: Text(selectedToDate != '' ? DateFormat('dd MMM, yyyy').format(DateTime.parse(selectedToDate)) : 'To Date', style: TextStyle(color: (customerCurrentScreen == 'Seller' ? Colors.orange.shade800 : Colors.blue.shade800), fontSize: AppConfig.size(context, 14)),),
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
                            print('clear');
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

  void openDrawer() {
    scaffoldKey.currentState!.openDrawer();
  }

  onSearchClicked () {
    setState(() {
      startLoading = true;
    });
  }



paymentCard(BuildContext context, payment, screenWidth) {
    return Card(
      elevation: 5,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: (payment['PaymentType'] == 'Disputed') ? Colors.red : payment['PaymentType'] == 'Pending' ? Colors.red : Colors.green.shade800, width: 1),
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
                color: (payment['Payment_Status'] == 'Disputed') ? Colors.red : payment['Payment_Status'] == 'Pending' ? Colors.red : Colors.green.shade800,
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
                        child: Text(DateFormat('dd MMM').format(DateTime.parse(payment['PaymentDate'])), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),)),
                      SizedBox(
                        width: screenWidth / 5,
                        child: Text(DateFormat('yyyy').format(DateTime.parse(payment['PaymentDate'])), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),)),
                      const SizedBox(height: 5),
                      SizedBox(
                        width: screenWidth / 5,
                        child: Text('Paid ₹${convertAmount(payment['PaymentAmount'])}'.toString(), style:  TextStyle(color: Colors.white, fontSize: AppConfig.size(context, 16), fontWeight: FontWeight.bold),))
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
                        child: Text(('# ${payment['InvoiceDetails'][0]['InvoiceNumber'] ?? ''}'), style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold),)),
                      const SizedBox(height: 5),
                      SizedBox(
                        width: screenWidth / 2.5,
                        child: Text(('From: ${payment['Business']['FirstName']} ${payment['Business']['LastName']}'), style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold),)),
                      SizedBox(
                        width: screenWidth / 2.5,
                        child: Text('To: ${payment['BuyerBusiness']['FirstName']} ${payment['BuyerBusiness']['LastName']}' , style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold),)),
                        const SizedBox(height: 5),
                        SizedBox(
                        width: screenWidth / 2.5,
                        child: Text('Invoice Amount: ₹${convertAmount(payment['InvoiceDetails'][0]['InvoiceAmount'])}', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold),)),
                      const SizedBox(height: 5),
                    ],
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  width: screenWidth / 4.5,
                  height: AppConfig.size(context, 110),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade600,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(AppConfig.size(context, 5)),
                    child: Center(child: Text('Due Date: ${DateFormat('dd MMM yyyy').format(DateTime.parse(payment['PaymentDueDate']))}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),)))
                ),
                

            
          ],)
      ),
    );

  }

  Future<void> acceptPaymentPopup (data) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Accept Payment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Are you sure you want to accept the payment?', style: TextStyle(color: Colors.grey.shade800, fontSize: AppConfig.size(context, 16)),),
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
                        StoreProvider.of<AppState>(context).dispatch(acceptBuyerPayment(<String, dynamic>{
                          "PaymentId": data['_id'],
                          "PaymentStatus": 'Accept',
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

  Future<void> disputePaymentPopup (data) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Dispute Payment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Are you sure you want to dispute the payment?', style: TextStyle(color: Colors.grey.shade800, fontSize: AppConfig.size(context, 16)),),
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
                        StoreProvider.of<AppState>(context).dispatch(updateDisputeStatus(<String, dynamic>{
                          "PaymentId": data['_id'],
                          "PaymentStatus": 'Dispute',
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

  Future<void> editPaidAmount (data) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Paid Amount'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // show paid amount
                Text('Paid Amount: ₹${data['PaymentAmount']}', style: TextStyle(color: Colors.grey.shade800, fontSize: AppConfig.size(context, 16)),),
                const SizedBox(height: 10),
                Text('Change paid amount', style: TextStyle(color: Colors.grey.shade800, fontSize: AppConfig.size(context, 16)),),
                const SizedBox(height: 10),
                TextField(
                  controller: invoiceAmountController,
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
                        if (invoiceAmountController.text == '') {
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
                        // show dialog to confirm
                        print('data $data');
                        StoreProvider.of<AppState>(context).dispatch(updatePaymentDetails(<String, dynamic>{
                          'Seller': data['Seller']['_id'],
                          'Business': data['Business']['_id'],
                          'Buyer': data['Buyer']['_id'],
                          'BuyerBusiness': data['BuyerBusiness']['_id'],
                          'InvoiceDetails': data['InvoiceDetails'],
                          'PaymentAmount': invoiceAmountController.text,
                          'Remarks': remarksController.text,
                          'PaymentId': data['_id'],
                          'PaymentStatus': 'Disputed',
                          'PaymentMode': data['PaymentMode'],
                        }));
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
    


    Future<void> openPaymentDetailsPopUp (Map data) {
    var screenWidth = MediaQuery.of(context).size.width;
    return showDialog(
      // cancellable false
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StoreConnector<AppState, Store<AppState>>(
                converter: (store) => store,
                builder: (BuildContext context, store) {
        final paymentsStatusLoading = store.state.paymentsState.paymentsStatusLoading;
        final paymentStatusUpdated = store.state.paymentsState.paymentStatusUpdated;
        final disputeStatusUpdated = store.state.paymentsState.disputeStatusUpdated;
        final editPaymentSuccess = store.state.paymentsState.editPaymentSuccess;
        return AlertDialog(
          title: const Text('Payment Details'),
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
                        Text('${data['InvoiceDetails'][0]['InvoiceNumber']}', style: TextStyle(color: Colors.grey.shade800, fontSize: AppConfig.size(context, 14)),),
                        const SizedBox(height: 5),
                        // date
                        Text('Date: ', style: TextStyle(color: Colors.grey.shade800, fontSize: AppConfig.size(context, 14)),),
                        Text(data['InvoiceDetails'][0]['InvoiceDate'], style: TextStyle(color: Colors.grey.shade800, fontSize: AppConfig.size(context, 14)),),
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
                        Text('₹${convertAmount(data['InvoiceDetails'][0]['InvoiceAmount'])}', style: TextStyle(color: Colors.grey.shade800, fontSize: AppConfig.size(context, 14)),),
                        const SizedBox(height: 5),
                        // date
                        Text('Due Date: ', style: TextStyle(color: Colors.grey.shade800, fontSize: AppConfig.size(context, 14)),),
                        Text(DateFormat('dd MMM yyyy').format(DateTime.parse(data['PaymentDueDate'])), style: TextStyle(color: Colors.grey.shade800, fontSize: AppConfig.size(context, 14)),),
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
                      color: Colors.orange.shade400,
                      ),
                    padding: EdgeInsets.all(AppConfig.size(context, 10)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Paid Amount:', style: TextStyle(color: Colors.black, fontSize: AppConfig.size(context, 14)),),
                        Text('₹${data['PaymentAmount']}', style: TextStyle(color: Colors.black, fontSize: AppConfig.size(context, 14)),),
                      ],
                    ),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    // billed to and from
                    width: screenWidth / 3.1,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.orange.shade400,
                      ),
                    padding: EdgeInsets.all(AppConfig.size(context, 10)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Payment Mode:', style: TextStyle(color: Colors.black, fontSize: AppConfig.size(context, 14)),),
                        Text(data['PaymentMode'] ?? '', style: TextStyle(color: Colors.black, fontSize: AppConfig.size(context, 14)),),
                      ],
                    ),
                  ),
                  ],
                ),
                const SizedBox(height: 5),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.orange.shade400 ,
                    ),
                  padding: EdgeInsets.all(AppConfig.size(context, 10)),
                  child: Row(
                    children: <Widget>[
                      Text('Payment Date: ', style: TextStyle(color: Colors.black, fontSize: AppConfig.size(context, 14)),),
                      Text(DateFormat('dd MMM yyyy').format(DateTime.parse(data['PaymentDate'])), style: TextStyle(color: Colors.black, fontSize: AppConfig.size(context, 14)),),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: data['Payment_Status'] == 'Accept' ? Colors.green.shade800 : Colors.red.shade800 ,
                    ),
                  padding: EdgeInsets.all(AppConfig.size(context, 10)),
                  child: Row(
                    children: <Widget>[
                      Text('Status: ', style: TextStyle(color: Colors.white, fontSize: AppConfig.size(context, 14)),),
                      Text('${data['Payment_Status'] ?? 'Not available.'}', style: TextStyle(color: Colors.white, fontSize: AppConfig.size(context, 14)),),
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
                      data['PaymentAttachments'].isEmpty ? Text('No attachments available.', style: TextStyle(color: Colors.grey.shade800, fontSize: AppConfig.size(context, 14)),) : Column(
                        children: data['Attachments'].map<Widget>((e) => Text(e['FileName'], style: TextStyle(color: Colors.grey.shade800, fontSize: AppConfig.size(context, 14)),)).toList(),
                      ),
                      
                    ],
                  ),
                ),
                const SizedBox(height: 5),
            if (StoreProvider.of<AppState>(context).state.dashboardState.customerCurrentScreen == 'Seller')
            if (data['Payment_Status'] == 'Pending' && paymentsStatusLoading == false && paymentStatusUpdated == false && disputeStatusUpdated == false)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.green.shade800),
                ),
                onPressed:(){
                  // show dialog to confirm
                  acceptPaymentPopup(data);
                }, 
                child:const Text('Accept', style: TextStyle(color: Colors.white)),
              ),
              
            
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.red.shade800),
                ),
                onPressed:(){
                  // show dialog to confirm
                  disputePaymentPopup(data);
                }, 
                child: const Text('Dispute', style: TextStyle(color: Colors.white)),
            ),
              ]
            ),
            if (paymentsStatusLoading == true)
              const CircularProgressIndicator(),
              if (paymentStatusUpdated == true)
              const Column(children: <Widget>[
                Icon(Icons.check, color: Colors.green),
                Text('Payment Accepted', style: TextStyle(color: Colors.green)),
                ]),
              if (disputeStatusUpdated == true)
              const Column(children: <Widget>[
                Icon(Icons.check, color: Colors.red),
                Text('Payment Disputed', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ]),
              if (editPaymentSuccess == true)
              const Column(children: <Widget>[
                Icon(Icons.check, color: Colors.green),
                Text('Payment Updated', style: TextStyle(color: Colors.green)),
                ]),
              if (store.state.dashboardState.customerCurrentScreen == 'Buyer')
              if (data['Payment_Status'] == 'Disputed' && paymentsStatusLoading == false && paymentStatusUpdated == false && disputeStatusUpdated == false)
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blue.shade800),
                ),
                onPressed:(){
                  // show dialog to confirm
                  editPaidAmount(data);
                }, 
                child: const Text('Edit', style: TextStyle(color: Colors.white)),
              ),
              ],
            ),
            
          ),
          actions: <Widget>[
      

            TextButton(
              onPressed: () {
                store.dispatch(UpdatePaymentStatusUpdated(paymentStatusUpdated: false));
                store.dispatch(UpdateDisputeStatusUpdated(disputeStatusUpdated: false));
                store.dispatch(UpdateEditPaymentSuccess(editPaymentSuccess: false));
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
        final paymentList = store.state.paymentsState.paymentList;
        final paymentListLoaded = store.state.paymentsState.paymentListLoaded;
        final paymentListLocal = store.state.paymentsState.paymentListLocal;
        final paymentListEndReached = store.state.paymentsState.paymentListEndReached;
        final paymentCreateLoading = store.state.paymentsState.paymentCreateLoading;
        final paymentCreated = store.state.paymentsState.paymentCreated;
        final loading = store.state.paymentsState.loading;
        final error = store.state.paymentsState.error;
        final myBusinessList = store.state.businessState.myBusinessList;


        void onAddClickInvoicePage() {}

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

        if (error != '') {
          store.dispatch(PaymentsFailedAction(error: ''));
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

        if (paymentList.isEmpty && paymentListLoaded == 0) {
          store.dispatch(UpdatePaymentsListLoaded(paymentListLoaded: 1));
          store.dispatch(getPaymentsList(<String, dynamic>{
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
            },
            "PaymentType":"",
            "PageNumber":1
          }));

  
        }

        if (paymentList.isNotEmpty && paymentListLoaded == 1) {
          store.dispatch(UpdatePaymentsListLoaded(paymentListLoaded: 2));
          if (paymentList['ActiveTab'] == 'Pending'){
            selectedFilterIndex = 0;
          } else if (paymentList['ActiveTab'] == 'Accept'){
            selectedFilterIndex = 1;
          } else if (paymentList['ActiveTab'] == 'Disputed'){
            selectedFilterIndex = 2;
          }
        }

  



        if (startLoading == true) {
          startLoading = false;
          if (searchController.text != '') {
            selectedDateFilter = -1;
          }
          store.dispatch(UpdatePaymentsList(paymentList: {}));
          store.dispatch(UpdatePaymentsListLocal(paymentListLocal: []));
          store.dispatch(getPaymentsList(<String, dynamic>{
            "FilterQuery":
        {   "Business":filterBusiness,
            "Buyer":filterBuyer,
            "BuyerBusiness":filterBuyerBusiness,
            "CustomDateRange":
            {
                "From":selectedFromDate,
                "To":selectedToDate
                },
            "DateRange":selectedDateFilter == 0 ? 'CurrentWeek' : selectedDateFilter == 1 ? 'LastWeek' : selectedDateFilter == 2 ? 'CurrentMonth' : selectedDateFilter == 3 ? 'LastMonth' : '',
            "SearchKey":searchController.text,
            "Seller":filterSeller,
            },
            "PaymentType":selectedFilterIndex == 0 ? 'Pending' : selectedFilterIndex == 1 ? 'Accept' : selectedFilterIndex == 2 ? 'Disputed' : '',
            "PageNumber":1
          }));
           filterBusiness = '';
            filterBuyer = '';
            filterBuyerBusiness = '';
            buyerBusinessList = [];

          store.dispatch(UpdateSellerBusinsessCustomerList(sellerBusinessCustomerList: []));
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




    




        return Scaffold(
          key: scaffoldKey,
          appBar: PreferredSize(
            preferredSize:  BoxConstraints.tightFor(height: AppConfig.size(context, 45)).smallest,
            child: WidgetHelper.getAppBar(context, 'Payments', openDrawer, customerCurrentScreen == 'Seller' ? Colors.orange : Colors.deepPurple.shade900, onAddClickInvoicePage),
          ),
      bottomNavigationBar: const BottomNavigation(),
    drawer: WidgetHelper.leftNavigationBar(context, screenIndex, customerData['ContactName'], customerData['Mobile'], customerCurrentScreen == 'Seller' ? Colors.orange : Colors.deepPurple.shade900),
    body: Center(
      child: loading ? const CircularProgressIndicator() :
      Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                color: selectedFilterIndex == 0 ? (customerCurrentScreen == 'Seller' ? (customerCurrentScreen == 'Seller' ? Colors.orange.shade800 : Colors.blue.shade800) : Colors.blue.shade800) : Colors.grey.shade600,
                width: screenWidth/3,
                height: AppConfig.size(context, 40),
                child: Padding(
                  padding: EdgeInsets.all(AppConfig.size(context, 1)),
                  child: Center(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          selectedFilterIndex = 0;
                          startLoading = true;
                        });
                      },
                      child: FittedBox(child: Text('Open (${paymentList['OpenCount']})', style: TextStyle(color: Colors.white, fontSize: AppConfig.size(context, 14)),)),
                    ),
                  ),
                ),
              ),
              Container(
                color: selectedFilterIndex == 1 ? (customerCurrentScreen == 'Seller' ? (customerCurrentScreen == 'Seller' ? (customerCurrentScreen == 'Seller' ? (customerCurrentScreen == 'Seller' ? (customerCurrentScreen == 'Seller' ? (customerCurrentScreen == 'Seller' ? (customerCurrentScreen == 'Seller' ? Colors.orange.shade800 : Colors.blue.shade800) : Colors.blue.shade800) : Colors.blue.shade800) : Colors.blue.shade800) : Colors.blue.shade800) : Colors.blue.shade800) : Colors.blue.shade800) : Colors.grey.shade600,
                width: screenWidth/3,
                height: AppConfig.size(context, 40),
                child: Padding(
                  padding: EdgeInsets.all(AppConfig.size(context, 1)),
                  child: Center(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          selectedFilterIndex = 1;
                          startLoading = true;
                        });
                      },
                      child: FittedBox(child: Text('Accepted (${paymentList['AcceptCount']})', style: TextStyle(color: Colors.white, fontSize: AppConfig.size(context, 14)),)),
                    ),
                  ),
                ),
              ),
              Container(
                color: selectedFilterIndex == 2 ? (customerCurrentScreen == 'Seller' ? (customerCurrentScreen == 'Seller' ? Colors.orange.shade800 : Colors.blue.shade800) : Colors.blue.shade800) : Colors.grey.shade600,
                width: screenWidth/3,
                height: AppConfig.size(context, 40),
                child: Padding(
                  padding: EdgeInsets.all(AppConfig.size(context, 1)),
                  child: Center(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          selectedFilterIndex = 2;
                          startLoading = true;
                        });
                      },
                      child: FittedBox(child: Text('Disputed (${paymentList['DisputeCount']})', style: TextStyle(color: Colors.white, fontSize: AppConfig.size(context, 14)),)),
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
              SizedBox(width: AppConfig.size(context, 10)),
              SizedBox(
                width: screenWidth/3,
                child: Text('Filter by date & status', style: TextStyle(color: (customerCurrentScreen == 'Seller' ? Colors.orange.shade800 : Colors.blue.shade800), fontSize: AppConfig.size(context, 14)),)),
              SizedBox(width: AppConfig.size(context, 10)),
              SizedBox(
                width: screenWidth/3.5,
                child: Text('Filter by business', style: TextStyle(color: (customerCurrentScreen == 'Seller' ? Colors.orange.shade800 : Colors.blue.shade800), fontSize: AppConfig.size(context, 14)))),
              SizedBox(width: AppConfig.size(context, 10)),
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
                      print('business filter');
                      businessSearchPopup();
                      
                    }, 
                    icon: Icon(Icons.business, color: Colors.white, size: AppConfig.size(context, 30),),
                    ),
                ),
              ),

            ],),
            paymentListLocal.isNotEmpty ? Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: paymentListLocal.length,
                itemBuilder: (BuildContext context, index) {
                  return GestureDetector(
                    onTap: () {
                      openPaymentDetailsPopUp(paymentListLocal[index]);
                    },
                    child: paymentCard(context, paymentListLocal[index], screenWidth),
                  );
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
                    child: Text('Refresh', style: TextStyle(color: (customerCurrentScreen == 'Seller' ? Colors.orange.shade800 : Colors.blue.shade800), fontSize: AppConfig.size(context, 16)),),
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