
import 'package:aquila_hundi/app/helper_widgets/config.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:aquila_hundi/store/app.state.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;


class InviteAction {

	@override
	String toString() {
	return 'InviteAction { }';
	}
}

class InviteSuccessAction {
	final int isSuccess;

	InviteSuccessAction({required this.isSuccess});
	@override
	String toString() {
	return 'InviteSuccessAction { isSuccess: $isSuccess }';
	}
}

class InviteFailedAction {
	final String error;

	InviteFailedAction({required this.error});

	@override
	String toString() {
	return 'InviteFailedAction { error: $error }';
	}
}

class InviteLoadingAction {
  final bool loading;

  InviteLoadingAction({required this.loading});

  @override
  String toString() {
  return 'InviteLoadingAction { loading: $loading }';
  }
}

class UpdateAcceptedList {
  final List acceptedList;

  UpdateAcceptedList({required this.acceptedList});

  @override
  String toString() {
  return 'InviteDataAction { acceptedList: $acceptedList }';
  }
}


// ThunkAction<AppState> getInviteList = (Store<AppState> store) async {
//   print('getInviteList');
//     store.dispatch(InviteLoadingAction(loading: true));
//     try {
//       final response = await http.post(
//         Uri.parse('${AppConfig.rootUrl}/APP_API/HundiScoreManagement/ConnectedCustomerWithAdvancedFilter'),
//         headers: {
//           'Authorization': 'Bearer ${store.state.authState.firebaseToken}',
//         },
//         body: convert.jsonEncode(<String, dynamic>{
//           'CustomerId': store.state.authState.customerData['_id'],
//           'CustomerCategory': store.state.dashboardState.customerCurrentScreen,
//           'FilterQuery': {   "Business":"",
//             "Buyer":"",
//             "BuyerBusiness":""
//             },
//         }),

//       );
//       print('response: ${response.body}');
//       if (response.statusCode == 200) {
//         final data = convert.jsonDecode(response.body);
//         store.dispatch(UpdateInviteListLocal(inviteListLocal: []));
//         store.dispatch(UpdateAcceptedList(acceptedList: data['Response']));
//         store.dispatch(InviteLoadingAction(loading: false));
//         store.dispatch(UpdateInviteListLoaded(inviteListLoaded: true));
//       } else {
//         store.dispatch(InviteFailedAction(error: 'Failed to load invite list'));
//         store.dispatch(InviteLoadingAction(loading: false));
//       }
//     } catch (e) {
//       store.dispatch(InviteFailedAction(error: 'Failed to load invite list'));
//       store.dispatch(InviteLoadingAction(loading: false));
//     }
// };

ThunkAction<AppState> getInviteList = (Store<AppState> store) async {
    store.dispatch(InviteLoadingAction(loading: true));
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.rootUrl}/APP_API/HundiScoreManagement/ConnectedCustomerWithAdvancedFilter'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${store.state.authState.firebaseToken}',
        },
        body: convert.jsonEncode(<String, dynamic>{
          'CustomerId': store.state.authState.customerData['_id'],
          'CustomerCategory': store.state.dashboardState.customerCurrentScreen,
          'FilterQuery': {   
            "Business":"",
            "Buyer":"",
            "BuyerBusiness":"",
              "Seller": ""
            },
        }),

      );

      if (response.statusCode == 200) {
        final data = convert.jsonDecode(response.body);
        if (data['Status'] == false) {
          store.dispatch(InviteFailedAction(error: data['Message']));
          store.dispatch(InviteLoadingAction(loading: false));
          return;
        }
        store.dispatch(UpdateInviteListLocal(inviteListLocal: []));
        store.dispatch(UpdateAcceptedList(acceptedList: data['Response']));
        store.dispatch(InviteLoadingAction(loading: false));
        store.dispatch(UpdateInviteListLoaded(inviteListLoaded: true));
      } else {
        store.dispatch(InviteFailedAction(error: 'Failed to load invite list'));
        store.dispatch(InviteLoadingAction(loading: false));
      }
    } catch (e) {
      store.dispatch(InviteFailedAction(error: 'Failed to load invite list'));
      store.dispatch(InviteLoadingAction(loading: false));
    }
};


class UpdateInviteListLoaded {
  final bool inviteListLoaded;

  UpdateInviteListLoaded({required this.inviteListLoaded});

  @override
  String toString() {
  return 'InviteDataAction { inviteListLoaded: $inviteListLoaded }';
  }
}

class UpdateInviteListLocal {
  final List inviteListLocal;

  UpdateInviteListLocal({required this.inviteListLocal});

  @override
  String toString() {
  return 'InviteDataAction { inviteListLocal: $inviteListLocal }';
  }
}

class UpdateEditCreditLoading {
  final bool editCreditLoading;

  UpdateEditCreditLoading({required this.editCreditLoading});

  @override
  String toString() {
  return 'InviteDataAction { editCreditLoading: $editCreditLoading }';
  }
}

class UpdateEditCreditError {
  final String editCreditError;

  UpdateEditCreditError({required this.editCreditError});

  @override
  String toString() {
  return 'InviteDataAction { editCreditError: $editCreditError }';
  }
}

class UpdateEditCreditSuccess {
  final bool editCreditSuccess;

  UpdateEditCreditSuccess({required this.editCreditSuccess});

  @override
  String toString() {
  return 'InviteDataAction { editCreditSuccess: $editCreditSuccess }';
  }
}

ThunkAction<AppState> editBusinessCreditLimit (Map data) {
  return (Store<AppState> store) async {
    store.dispatch(InviteLoadingAction(loading: true));

    store.dispatch(UpdateEditCreditLoading(editCreditLoading: true));
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.rootUrl}/APP_API/InviteManagements/SellerUpdateToBuyerCreditLimit'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${store.state.authState.firebaseToken}',
        },
        body: convert.jsonEncode(data),
      );
      var dataReturned = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (dataReturned['Status'] == false){

          store.dispatch(UpdateEditCreditError(editCreditError: dataReturned['Message']));
          store.dispatch(UpdateEditCreditLoading(editCreditLoading: false));
          store.dispatch(UpdateEditCreditSuccess(editCreditSuccess: false));
          store.dispatch(InviteLoadingAction(loading: false));

        } else {

          store.dispatch(UpdateEditCreditSuccess(editCreditSuccess: true));
          store.dispatch(UpdateEditCreditLoading(editCreditLoading: false));
          store.dispatch(getInviteList);
          store.dispatch(InviteLoadingAction(loading: false));
        }
      } else {
        store.dispatch(UpdateEditCreditError(editCreditError: 'Failed to update credit limit'));
        store.dispatch(UpdateEditCreditLoading(editCreditLoading: false));
        store.dispatch(UpdateEditCreditSuccess(editCreditSuccess: false));
        store.dispatch(InviteLoadingAction(loading: false));
      }
    } catch (e) {
      store.dispatch(UpdateEditCreditError(editCreditError: 'Failed to update credit limit'));
      store.dispatch(UpdateEditCreditLoading(editCreditLoading: false));
      store.dispatch(UpdateEditCreditSuccess(editCreditSuccess: false));
      store.dispatch(InviteLoadingAction(loading: false));
    }
  };
}

class UpdateInviteBuyerSuccess {
  final bool inviteBuyerSuccess;

  UpdateInviteBuyerSuccess({required this.inviteBuyerSuccess});

  @override
  String toString() {
  return 'InviteDataAction { inviteBuyerSuccess: $inviteBuyerSuccess }';
  }
}

ThunkAction<AppState> inviteBuyer (Map data) {
  print('inviteBuyer, data: $data');
  return (Store<AppState> store) async {
    store.dispatch(InviteLoadingAction(loading: true));
    store.dispatch(UpdateInviteBuyerSuccess(inviteBuyerSuccess: false));
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.rootUrl}${store.state.dashboardState.customerCurrentScreen == 'Seller' ? '/APP_API/InviteManagements/SellerSendInvite' : '/APP_API/InviteManagements/BuyerSendInvite'}'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${store.state.authState.firebaseToken}',
        },
        body: convert.jsonEncode(data),
      );
      var dataReturned = convert.jsonDecode(response.body);
      print('dataReturned: $dataReturned');
      if (response.statusCode == 200) {
        if (dataReturned['Status'] == false){
          store.dispatch(InviteFailedAction(error: dataReturned['Message']));
          store.dispatch(InviteLoadingAction(loading: false));
        } else {
          store.dispatch(UpdateInviteBuyerSuccess(inviteBuyerSuccess: true));
          store.dispatch(getInviteList);
          store.dispatch(getInviteHistoryList);
          store.dispatch(InviteLoadingAction(loading: false));
        }
      } else {
        store.dispatch(InviteFailedAction(error: dataReturned['Message']));
        store.dispatch(InviteLoadingAction(loading: false));
      }
    } catch (e) {
      store.dispatch(InviteFailedAction(error: 'Failed to invite buyer'));
      store.dispatch(InviteLoadingAction(loading: false));
    }
  };
}

class UpdateInviteHistoryList {
  final List inviteHistoryList;

  UpdateInviteHistoryList({required this.inviteHistoryList});

  @override
  String toString() {
  return 'InviteDataAction { inviteHistoryList: $inviteHistoryList }';
  }
}

class UpdateInviteHistoryListLoaded {
  final bool inviteHistoryListLoaded;

  UpdateInviteHistoryListLoaded({required this.inviteHistoryListLoaded});

  @override
  String toString() {
  return 'InviteDataAction { inviteHistoryListLoaded: $inviteHistoryListLoaded }';
  }
}

ThunkAction<AppState> getInviteHistoryList = (Store<AppState> store) async {
    store.dispatch(InviteLoadingAction(loading: true));
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.rootUrl}/APP_API/InviteManagements/SellerAndBuyerInviteList'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${store.state.authState.firebaseToken}',
        },
        body: convert.jsonEncode(<String, dynamic>{
          'CustomerId': store.state.authState.customerData['_id'],
          'CustomerCategory': store.state.dashboardState.customerCurrentScreen,
        }),
      );
      if (response.statusCode == 200) {
        final data = convert.jsonDecode(response.body);
        if (data['Status'] == false) {
          store.dispatch(InviteFailedAction(error: data['Message']));
          store.dispatch(InviteLoadingAction(loading: false));
          return;
        }
        store.dispatch(UpdateInviteHistoryList(inviteHistoryList: data['Response']));
        store.dispatch(UpdateInviteHistoryListLoaded(inviteHistoryListLoaded: true));
        store.dispatch(InviteLoadingAction(loading: false));
      } else {
        store.dispatch(InviteFailedAction(error: 'Failed to load invite history list'));
        store.dispatch(InviteLoadingAction(loading: false));
      }
    } catch (e) {
      store.dispatch(InviteFailedAction(error: 'Failed to load invite history list'));
      store.dispatch(InviteLoadingAction(loading: false));
    }
};

class UpdateMobileNumberVerified {
  final bool mobileNumberVerified;

  UpdateMobileNumberVerified({required this.mobileNumberVerified});

  @override
  String toString() {
  return 'InviteDataAction { mobileNumberVerified: $mobileNumberVerified }';
  }
}

class UpdateCustomerFromMobileNumber {
  final Map customerFromMobileNumber;

  UpdateCustomerFromMobileNumber({required this.customerFromMobileNumber});

  @override
  String toString() {
  return 'InviteDataAction { customerFromMobileNumber: $customerFromMobileNumber }';
  }
}

ThunkAction<AppState> getCustomerFromMobileNumber (Map data) {
  return (Store<AppState> store) async {
    store.dispatch(InviteLoadingAction(loading: true));
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.rootUrl}/APP_API/InviteManagements/VerifyCustomer_Mobile'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${store.state.authState.firebaseToken}',
        },
        body: convert.jsonEncode(data),
      );
      var dataReturned = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (dataReturned['Status'] == false){
          store.dispatch(InviteFailedAction(error: dataReturned['Message']));
          store.dispatch(UpdateMobileNumberVerified(mobileNumberVerified: true));
          store.dispatch(InviteLoadingAction(loading: false));
        } else {
          store.dispatch(UpdateCustomerFromMobileNumber(customerFromMobileNumber: dataReturned['Response']));
          store.dispatch(UpdateMobileNumberVerified(mobileNumberVerified: true));
          store.dispatch(InviteLoadingAction(loading: false));
        }
      } else {
        store.dispatch(InviteFailedAction(error: dataReturned['Message']));
        store.dispatch(InviteLoadingAction(loading: false));
      }
    } catch (e) {
      store.dispatch(InviteFailedAction(error: 'Failed to get customer from mobile number'));
      store.dispatch(InviteLoadingAction(loading: false));
    }
  };
}


class UpdateEditRequestFromInvoice {
  final bool editRequestFromInvoice;

  UpdateEditRequestFromInvoice({required this.editRequestFromInvoice});

  @override
  String toString() {
  return 'InviteDataAction { editRequestFromInvoice: $editRequestFromInvoice }';
  }
}

class UpdateEditRequestBuyerId {
  final String editRequestBuyerId;

  UpdateEditRequestBuyerId({required this.editRequestBuyerId});

  @override
  String toString() {
  return 'InviteDataAction { editRequestBuyerId: $editRequestBuyerId }';
  }
}


