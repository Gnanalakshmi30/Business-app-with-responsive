

import 'package:aquila_hundi/app/helper_widgets/config.dart';
import 'package:aquila_hundi/store/invoice/invoice.action.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:aquila_hundi/store/app.state.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;


class PaymentsAction {

	@override
	String toString() {
	return 'PaymentsAction { }';
	}
}


class PaymentsFailedAction {
	final String error;

	PaymentsFailedAction({required this.error});

	@override
	String toString() {
	return 'PaymentsFailedAction { error: $error }';
	}
}

class PaymentsLoadingAction {
  final bool loading;

  PaymentsLoadingAction({required this.loading});

  @override
  String toString() {
  return 'PaymentsLoadingAction { loading: $loading }';
  }
}

class UpdatePaymentsList {
  final Map paymentList;

  UpdatePaymentsList({required this.paymentList});

  @override
  String toString() {
  return 'PaymentsDataAction { paymentList: $paymentList }';
  }
}

class UpdatePaymentsListLoaded {
  final int paymentListLoaded;

  UpdatePaymentsListLoaded({required this.paymentListLoaded});

  @override
  String toString() {
  return 'PaymentsDataAction { paymentListLoaded: $paymentListLoaded }';
  }
}

class UpdatePaymentsListLocal {
  final List paymentListLocal;

  UpdatePaymentsListLocal({required this.paymentListLocal});

  @override
  String toString() {
  return 'PaymentsDataAction { paymentListLocal: $paymentListLocal }';
  }
}

class UpdatePaymentsListEndReached {
  final bool paymentListEndReached;

  UpdatePaymentsListEndReached({required this.paymentListEndReached});

  @override
  String toString() {
  return 'PaymentsDataAction { paymentListEndReached: $paymentListEndReached }';
  }
}

class UpdatePaymentStatusType {
  final String paymentStatusType;

  UpdatePaymentStatusType({required this.paymentStatusType});

  @override
  String toString() {
  return 'PaymentsDataAction { paymentStatusType: $paymentStatusType }';
  }
}

class UpdatePaymentCreated {
  final bool paymentCreated;

  UpdatePaymentCreated({required this.paymentCreated});

  @override
  String toString() {
  return 'PaymentsDataAction { paymentCreated: $paymentCreated }';
  }
}

class UpdatePaymentCreateLoading {
  final bool paymentCreateLoading;

  UpdatePaymentCreateLoading({required this.paymentCreateLoading});

  @override
  String toString() {
  return 'PaymentsDataAction { paymentCreateLoading: $paymentCreateLoading }';
  }
}

ThunkAction<AppState> getPaymentsList (Map data) {
  return (Store<AppState> store) async {
    if (data['pageNumber'] == 1){
      store.dispatch(PaymentsLoadingAction(loading: true));
      store.dispatch(UpdatePaymentsListEndReached(paymentListEndReached: false));
    }
    try {
      var response = await http.post(
        Uri.parse('${AppConfig.rootUrl}/APP_API/PaymentManagement/CompletePaymentList'), 
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${store.state.authState.firebaseToken}'
        },
        body: convert.jsonEncode({
          'CustomerId': store.state.authState.customerData['_id'],
          'CustomerCategory': store.state.dashboardState.customerCurrentScreen,
          'FilterQuery' : data['FilterQuery'],
          'PaymentType' : data['PaymentType'],
          'PageNumber' : data['PageNumber'],
        })
        );
      var jsonResponse = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        store.dispatch(UpdatePaymentsList(paymentList: jsonResponse['Response']));
        store.dispatch(PaymentsLoadingAction(loading: false));
        store.dispatch(UpdatePaymentsListLoaded(paymentListLoaded: 1));
        if (data['PageNumber'] == 1) {
          store.dispatch(UpdatePaymentsListLocal(paymentListLocal: jsonResponse['Response']['PaymentList']));
          if (jsonResponse['Response']['PaymentList'].length < 25) {
            store.dispatch(UpdatePaymentsListEndReached(paymentListEndReached: true));
          }
        } else {
          final List paymentListLocal = store.state.paymentsState.paymentListLocal;
          var updatedPaymentListLocal = paymentListLocal;
          // check duplicate and add
          if (paymentListLocal.isNotEmpty){
          for (var i = 0; i < jsonResponse['Response']['PaymentList'].length; i++) {
            var isDuplicate = false;
            for (var j = 0; j < paymentListLocal.length; j++) {
              if (jsonResponse['Response']['PaymentList'][i]['_id'] == paymentListLocal[j]['_id']) {
                isDuplicate = true;
              }
            }
            if (!isDuplicate) {
              updatedPaymentListLocal.add(jsonResponse['Response']['PaymentList'][i]);
            }
          }
          store.dispatch(UpdatePaymentsListLocal(paymentListLocal: updatedPaymentListLocal));
          if (jsonResponse['Response']['PaymentList'].length < 25) {
            store.dispatch(UpdatePaymentsListEndReached(paymentListEndReached: true));
          }
        } else {
          store.dispatch(UpdatePaymentsListEndReached(paymentListEndReached: true));
        }  
        
      } 
      } else {
        store.dispatch(PaymentsFailedAction(error: jsonResponse['Message']));
        store.dispatch(PaymentsLoadingAction(loading: false));
      }
      
    } catch (e) {
      store.dispatch(PaymentsFailedAction(error: e.toString()));
      store.dispatch(PaymentsLoadingAction(loading: false));
    }
  };
}

class UpdatePaymentStatusUpdated {
  final bool paymentStatusUpdated;

  UpdatePaymentStatusUpdated({required this.paymentStatusUpdated});

  @override
  String toString() {
  return 'PaymentsDataAction { paymentStatusUpdated: $paymentStatusUpdated }';
  }
}

class UpdatePaymentStatusLoading {
  final bool paymentStatusLoading;

  UpdatePaymentStatusLoading({required this.paymentStatusLoading});

  @override
  String toString() {
  return 'PaymentsDataAction { paymentStatusLoading: $paymentStatusLoading }';
  }
}

ThunkAction<AppState> acceptBuyerPayment (Map data) {
  return (Store<AppState> store) async {
    store.dispatch(UpdatePaymentStatusLoading(paymentStatusLoading: true));
    try {
      var response = await http.post(
        Uri.parse('${AppConfig.rootUrl}/APP_API/PaymentManagement/BuyerPayment_Approve'), 
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${store.state.authState.firebaseToken}'
        },
        body: convert.jsonEncode({
          'CustomerId': store.state.authState.customerData['_id'],
          'PaymentId': data['PaymentId'],
          'Payment_Status': data['PaymentStatus'],
        })
        );
      var jsonResponse = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        store.dispatch(UpdatePaymentStatusUpdated(paymentStatusUpdated: true));
        store.dispatch(UpdatePaymentStatusLoading(paymentStatusLoading: false));
        // getpaymentslist
        store.dispatch(getPaymentsList({
          'PageNumber': 1,
          'FilterQuery': {   
            "Business":"",
            "Buyer":"",
            "BuyerBusiness":"",
            "CustomDateRange":
            {
                "From":"",
                "To":""
                },
            "DateRange":"",
            "SearchKey":"",
            "Seller":""
            },
          'PaymentType': '',
        }));
      } else {
        store.dispatch(PaymentsFailedAction(error: jsonResponse['Message']));
        store.dispatch(UpdatePaymentStatusLoading(paymentStatusLoading: false));
      }
      
    } catch (e) {
      store.dispatch(PaymentsFailedAction(error: e.toString()));
      store.dispatch(UpdatePaymentStatusLoading(paymentStatusLoading: false));
    }
  };
}

class UpdateDisputeStatusUpdated {
  final bool disputeStatusUpdated;

  UpdateDisputeStatusUpdated({required this.disputeStatusUpdated});

  @override
  String toString() {
  return 'PaymentsDataAction { disputeStatusUpdated: $disputeStatusUpdated }';
  }
}

class UpdateEditPaymentSuccess {
  final bool editPaymentSuccess;

  UpdateEditPaymentSuccess({required this.editPaymentSuccess});

  @override
  String toString() {
  return 'PaymentsDataAction { editPaymentSuccess: $editPaymentSuccess }';
  }
}

ThunkAction<AppState> updateDisputeStatus (Map data) {
  return (Store<AppState> store) async {
    store.dispatch(UpdatePaymentStatusLoading(paymentStatusLoading: true));
    try {
      var response = await http.post(
        Uri.parse('${AppConfig.rootUrl}/APP_API/PaymentManagement/BuyerPayment_Disputed'), 
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${store.state.authState.firebaseToken}'
        },
        body: convert.jsonEncode({
          'CustomerId': store.state.authState.customerData['_id'],
          'PaymentId': data['PaymentId'],
          'Payment_Status': data['PaymentStatus'],
        })
        );
      var jsonResponse = convert.jsonDecode(response.body);
      print('updateDisputeStatus jsonResponse $jsonResponse');
      if (response.statusCode == 200) {
        store.dispatch(UpdateDisputeStatusUpdated(disputeStatusUpdated: true));
        store.dispatch(UpdatePaymentStatusLoading(paymentStatusLoading: false));
        // getpaymentslist
        store.dispatch(getPaymentsList({
          'PageNumber': 1,
          'FilterQuery': {   
            "Business":"",
            "Buyer":"",
            "BuyerBusiness":"",
            "CustomDateRange":
            {
                "From":"",
                "To":""
                },
            "DateRange":"",
            "SearchKey":"",
            "Seller":""
            },
          'PaymentType': '',
        }));
      } else {
        store.dispatch(PaymentsFailedAction(error: jsonResponse['Message']));
        store.dispatch(UpdatePaymentStatusLoading(paymentStatusLoading: false));
      }
      
    } catch (e) {
      store.dispatch(PaymentsFailedAction(error: e.toString()));
      store.dispatch(UpdatePaymentStatusLoading(paymentStatusLoading: false));
    }
  };
}


ThunkAction<AppState> updatePaymentDetails (Map data) {
  return (Store<AppState> store) async {
    store.dispatch(UpdatePaymentStatusLoading(paymentStatusLoading: true));
    try {
      var response = await http.post(
        Uri.parse('${AppConfig.rootUrl}/APP_API/PaymentManagement/PaymentDetailsUpdate'), 
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${store.state.authState.firebaseToken}'
        },
        body: convert.jsonEncode({
          'Seller': data['Seller'],
          'Business': data['Business'],
          'Buyer': data['Buyer'],
          'PaymentId': data['PaymentId'],
          'BuyerBusiness': data['BuyerBusiness'],
          'Payment_Status': data['PaymentStatus'],
          'InvoiceDetails': data['InvoiceDetails'],
          'PaymentDate': DateTime.now().toIso8601String(),
          'PaymentAmount': data['PaymentAmount'],
          'Remarks': data['Remarks'],
          'PaymentMode': data['PaymentMode'],
          'PaymentAttachments':[]
        })
        );
      var jsonResponse = convert.jsonDecode(response.body);
      print('updatePaymentDetails jsonResponse $jsonResponse');
      if (response.statusCode == 200) {
        store.dispatch(UpdateEditPaymentSuccess(editPaymentSuccess: true));
        store.dispatch(UpdatePaymentStatusLoading(paymentStatusLoading: false));
        // getpaymentslist
        store.dispatch(getPaymentsList({
          'PageNumber': 1,
          'FilterQuery': {   
            "Business":"",
            "Buyer":"",
            "BuyerBusiness":"",
            "CustomDateRange":
            {
                "From":"",
                "To":""
                },
            "DateRange":"",
            "SearchKey":"",
            "Seller":""
            },
          'PaymentType': '',
        }));
      } else {
        store.dispatch(PaymentsFailedAction(error: jsonResponse['Message']));
        store.dispatch(UpdatePaymentStatusLoading(paymentStatusLoading: false));
      }
      
    } catch (e) {
      store.dispatch(PaymentsFailedAction(error: e.toString()));
      store.dispatch(UpdatePaymentStatusLoading(paymentStatusLoading: false));
    }
  };
}

ThunkAction<AppState> makePayment (Map data) {
  return (Store<AppState> store) async {
    store.dispatch(UpdatePaymentCreateLoading(paymentCreateLoading: true));
    try {
      var response = await http.post(
        Uri.parse('${AppConfig.rootUrl}/APP_API/PaymentManagement/PaymentCreate'), 
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${store.state.authState.firebaseToken}'
        },
        body: convert.jsonEncode({
          'Seller': data['Seller'],
          'Business': data['Business'],
          'Buyer': data['Buyer'],
          'BuyerBusiness': data['BuyerBusiness'],
          'Payment_Status': data['PaymentStatus'],
          'InvoiceDetails': data['InvoiceDetails'],
          'PaymentDate': DateTime.now().toIso8601String(),
          'PaymentAmount': data['PaymentAmount'],
          'Remarks': data['Remarks'],
          'PaymentAttachments':[]
        })
        );
      var jsonResponse = convert.jsonDecode(response.body);
      print('makePayment jsonResponse $jsonResponse');
      if (response.statusCode == 200) {
        store.dispatch(UpdatePaymentCreated(paymentCreated: true));
        store.dispatch(UpdatePaymentCreateLoading(paymentCreateLoading: false));
        // getpaymentslist
        store.dispatch(getPaymentsList({
          'PageNumber': 1,
          'FilterQuery': {   
            "Business":"",
            "Buyer":"",
            "BuyerBusiness":"",
            "CustomDateRange":
            {
                "From":"",
                "To":""
                },
            "DateRange":"",
            "SearchKey":"",
            "Seller":""
            },
          'PaymentType': '',
        }));
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
            "StatusType":"All"
            },
            "InvoiceType":"",
            "PageNumber":1
          }));
      } else {
        store.dispatch(InvoiceFailedAction(error: jsonResponse['Message']));
        store.dispatch(UpdatePaymentCreateLoading(paymentCreateLoading: false));
      }
      
    } catch (e) {
      store.dispatch(InvoiceFailedAction(error: e.toString()));
      store.dispatch(UpdatePaymentCreateLoading(paymentCreateLoading: false));
    }
  };
}
  
  
	




	