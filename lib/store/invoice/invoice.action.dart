
import 'package:aquila_hundi/app/helper_widgets/config.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:aquila_hundi/store/app.state.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class InvoiceAction {

	@override
	String toString() {
	return 'InvoiceAction { }';
	}
}


class InvoiceFailedAction {
	final String error;

	InvoiceFailedAction({required this.error});

	@override
	String toString() {
	return 'InvoiceFailedAction { error: $error }';
	}
}

class InvoiceLoadingAction {
  final bool loading;

  InvoiceLoadingAction({required this.loading});

  @override
  String toString() {
  return 'InvoiceLoadingAction { loading: $loading }';
  }
}

class UpdateInvoiceList {
  final Map invoiceList;

  UpdateInvoiceList({required this.invoiceList});

  @override
  String toString() {
  return 'InvoiceDataAction { invoiceList: $invoiceList }';
  }
}

class UpdateInvoiceListLoaded {
  final int invoiceListLoaded;

  UpdateInvoiceListLoaded({required this.invoiceListLoaded});

  @override
  String toString() {
  return 'InvoiceDataAction { invoiceListLoaded: $invoiceListLoaded }';
  }
}

class UpdateInvoiceListLocal {
  final List invoiceListLocal;

  UpdateInvoiceListLocal({required this.invoiceListLocal});

  @override
  String toString() {
  return 'InvoiceDataAction { invoiceListLocal: $invoiceListLocal }';
  }
}

class UpdateInvoiceListEndReached {
  final bool invoiceListEndReached;

  UpdateInvoiceListEndReached({required this.invoiceListEndReached});

  @override
  String toString() {
  return 'InvoiceDataAction { invoiceListEndReached: $invoiceListEndReached }';
  }
}

ThunkAction<AppState> getInvoiceList (Map data) {
  print('data' + data.toString());
  return (Store<AppState> store) async {
    if (data['PageNumber'] == 1) {
        store.dispatch(InvoiceLoadingAction(loading: true));
        store.dispatch(UpdateInvoiceListEndReached(invoiceListEndReached: false));
    }
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.rootUrl}/APP_API/InvoiceManagement/CompleteInvoiceList'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${store.state.authState.firebaseToken}'
        },
        body: convert.jsonEncode({
          'CustomerId': store.state.authState.customerData['_id'],
          'CustomerCategory': store.state.dashboardState.customerCurrentScreen,
          'FilterQuery' : data['FilterQuery'],
          'InvoiceType' : data['InvoiceType'],
          'PageNumber' : data['PageNumber'],
        }),
      );
      if (response.statusCode == 200) {

        final Map<String, dynamic> responseData = convert.jsonDecode(response.body);
        store.dispatch(UpdateInvoiceList(invoiceList: responseData['Response']));
        store.dispatch(UpdateInvoiceListLoaded(invoiceListLoaded: 1));
        store.dispatch(InvoiceLoadingAction(loading: false));
        final List invoiceListLocal = store.state.invoiceState.invoiceListLocal;
        if (data['PageNumber'] == 1) {
          store.dispatch(UpdateInvoiceListLocal(invoiceListLocal: responseData['Response']['InvoiceList']));
          if (responseData['Response']['InvoiceList'].length < 25) {
          store.dispatch(UpdateInvoiceListEndReached(invoiceListEndReached: true));
          }

        } 
        else {
          final List invoiceList = responseData['Response']['InvoiceList'];
          var updatedInvoiceListLocal = invoiceListLocal;
          // check duplicates and add
          if (invoiceListLocal.isNotEmpty) {
          for (var i = 0; i < invoiceList.length; i++) {
            final index = invoiceListLocal.indexWhere((element) => element['_id'] == invoiceList[i]['_id']);
            if (index == -1) {
              updatedInvoiceListLocal.add(invoiceList[i]);
            }
          }
          store.dispatch(UpdateInvoiceListLocal(invoiceListLocal: updatedInvoiceListLocal));
          if (invoiceList.length < 25) {
          store.dispatch(UpdateInvoiceListEndReached(invoiceListEndReached: true));
          }
          } else {
          store.dispatch(UpdateInvoiceListEndReached(invoiceListEndReached: true));
          }
        }

      } else {
        store.dispatch(InvoiceFailedAction(error: 'Failed to load invoice list'));
        store.dispatch(InvoiceLoadingAction(loading: false));
      }
    } catch (error) {
      store.dispatch(InvoiceFailedAction(error: 'Failed to load invoice list'));
      store.dispatch(InvoiceLoadingAction(loading: false));
    }
  };
}

class UpdateInvoiceStatusType {
  final String invoiceStatusType;

  UpdateInvoiceStatusType({required this.invoiceStatusType});

  @override
  String toString() {
  return 'InvoiceDataAction { invoiceStatusType: $invoiceStatusType }';
  }
}

class UpdateInvoiceCreated {
  final bool invoiceCreated;

  UpdateInvoiceCreated({required this.invoiceCreated});

  @override
  String toString() {
  return 'InvoiceDataAction { invoiceCreated: $invoiceCreated }';
  }
}

class UpdateInvoiceCreateLoading {
  final bool invoiceCreateLoading;

  UpdateInvoiceCreateLoading({required this.invoiceCreateLoading});

  @override
  String toString() {
  return 'InvoiceDataAction { invoiceCreateLoading: $invoiceCreateLoading }';
  }
}

class UpdateInvoiceStatusUpdated {
  final bool invoiceStatusUpdated;

  UpdateInvoiceStatusUpdated({required this.invoiceStatusUpdated});

  @override
  String toString() {
  return 'InvoiceDataAction { invoiceStatusUpdated: $invoiceStatusUpdated }';
  }
}

class UpdateInvoiceStatusLoading {
  final bool invoiceStatusLoading;

  UpdateInvoiceStatusLoading({required this.invoiceStatusLoading});

  @override
  String toString() {
  return 'InvoiceDataAction { invoiceStatusLoading: $invoiceStatusLoading }';
  }
}

class UpdateInvoiceDisputeStatusUpdated {
  final bool invoiceDisputedStatusUpdated;

  UpdateInvoiceDisputeStatusUpdated({required this.invoiceDisputedStatusUpdated});

  @override
  String toString() {
  return 'InvoiceDataAction { invoiceDisputedStatusUpdated: $invoiceDisputedStatusUpdated }';
  }
}

ThunkAction<AppState> createInvoice (Map data) {
  print('data from create invoice' + data.toString());
  return (Store<AppState> store) async {
    store.dispatch(UpdateInvoiceCreateLoading(invoiceCreateLoading: true));
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.rootUrl}/APP_API/InvoiceManagement/InvoiceCreate'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${store.state.authState.firebaseToken}'
        },
        body: convert.jsonEncode([data]),
      );
              final Map<String, dynamic> responseData = convert.jsonDecode(response.body);
        print('responseData' + responseData.toString());

      if (response.statusCode == 200) {

        if (responseData['Status'] == true) {

          store.dispatch(UpdateInvoiceCreated(invoiceCreated: true));
          store.dispatch(UpdateInvoiceCreateLoading(invoiceCreateLoading: false));
        } else {
          store.dispatch(InvoiceFailedAction(error: responseData['Message']));
        }
      } else {
        store.dispatch(InvoiceFailedAction(error: 'Failed to create invoice'));
        store.dispatch(UpdateInvoiceCreateLoading(invoiceCreateLoading: false));
      }
    } catch (error) {
      store.dispatch(InvoiceFailedAction(error: 'Failed to create invoice local'));
      store.dispatch(UpdateInvoiceCreateLoading(invoiceCreateLoading: false));
    }
  };
}

ThunkAction<AppState> editInvoice (Map data) {
  return (Store<AppState> store) async {
    store.dispatch(UpdateInvoiceCreateLoading(invoiceCreateLoading: true));
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.rootUrl}/APP_API/InvoiceManagement/InvoiceDetailsUpdate'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${store.state.authState.firebaseToken}'
        },
        body: convert.jsonEncode(data),
      );
      if (response.statusCode == 200) {

        final Map<String, dynamic> responseData = convert.jsonDecode(response.body);
        if (responseData['Status'] == true) {

          store.dispatch(UpdateInvoiceCreated(invoiceCreated: true));
          store.dispatch(UpdateInvoiceCreateLoading(invoiceCreateLoading: false));
        } else {
          store.dispatch(InvoiceFailedAction(error: responseData['Message']));
        }
      } else {
        store.dispatch(InvoiceFailedAction(error: 'Failed to edit invoice'));
        store.dispatch(UpdateInvoiceCreateLoading(invoiceCreateLoading: false));
      }
    } catch (error) {
      store.dispatch(InvoiceFailedAction(error: 'Failed to edit invoice local'));
      store.dispatch(UpdateInvoiceCreateLoading(invoiceCreateLoading: false));
    }
  };
}

ThunkAction<AppState> acceptInvoice (Map data) {
  return (Store<AppState> store) async {
    store.dispatch(UpdateInvoiceStatusLoading(invoiceStatusLoading: true));
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.rootUrl}/APP_API/InvoiceManagement/BuyerInvoice_Accept'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${store.state.authState.firebaseToken}'
        },
        body: convert.jsonEncode({
          'InvoiceId': [{'id': data['InvoiceId']}],
          'Buyer': store.state.authState.customerData['_id'],
          'InvoiceStatus': 'Accept'
        }),
      );
      if (response.statusCode == 200) {

        final Map<String, dynamic> responseData = convert.jsonDecode(response.body);
        if (responseData['Status'] == true) {

          store.dispatch(UpdateInvoiceStatusUpdated(invoiceStatusUpdated: true));
          store.dispatch(UpdateInvoiceStatusLoading(invoiceStatusLoading: false));
        } else {
          store.dispatch(InvoiceFailedAction(error: responseData['Message']));
        }
      } else {
        store.dispatch(InvoiceFailedAction(error: 'Failed to accept invoice'));
        store.dispatch(UpdateInvoiceStatusLoading(invoiceStatusLoading: false));
      }
    } catch (error) {
      store.dispatch(InvoiceFailedAction(error: 'Failed to accept invoice local'));
      store.dispatch(UpdateInvoiceStatusLoading(invoiceStatusLoading: false));
    }
  };
}

ThunkAction<AppState> disputeInvoice (Map data) {
  return (Store<AppState> store) async {
    store.dispatch(UpdateInvoiceStatusLoading(invoiceStatusLoading: true));
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.rootUrl}/APP_API/InvoiceManagement/BuyerInvoice_Dispute'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${store.state.authState.firebaseToken}'
        },
        body: convert.jsonEncode({
          'InvoiceId': [{'_id': data['InvoiceId']}],
          'Buyer': store.state.authState.customerData['_id'],
          'InvoiceStatus': 'Disputed'
        }),
      );
      if (response.statusCode == 200) {

        final Map<String, dynamic> responseData = convert.jsonDecode(response.body);
        if (responseData['Status'] == true) {

          store.dispatch(UpdateInvoiceDisputeStatusUpdated(invoiceDisputedStatusUpdated: true));
          store.dispatch(UpdateInvoiceStatusLoading(invoiceStatusLoading: false));
        } else {
          store.dispatch(InvoiceFailedAction(error: responseData['Message']));
        }
      } else {
        store.dispatch(InvoiceFailedAction(error: 'Failed to dispute invoice'));
        store.dispatch(UpdateInvoiceStatusLoading(invoiceStatusLoading: false));
      }
    } catch (error) {
      store.dispatch(InvoiceFailedAction(error: 'Failed to dispute invoice local'));
      store.dispatch(UpdateInvoiceStatusLoading(invoiceStatusLoading: false));
    }
  };
}

