import 'package:aquila_hundi/app/helper_widgets/config.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:aquila_hundi/store/app.state.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class BusinessAction {

	@override
	String toString() {
	return 'BusinessAction { }';
	}
}

class BusinessFailedAction {
	final String error;

	BusinessFailedAction({required this.error});

	@override
	String toString() {
	return 'BusinessFailedAction { error: $error }';
	}
}

class BusinessLoadingAction {
  final bool loading;

  BusinessLoadingAction({required this.loading});

  @override
  String toString() {
  return 'BusinessLoadingAction { loading: $loading }';
  }
}

class BusinessIssuccessAction {
  final int isSuccess;

  BusinessIssuccessAction({required this.isSuccess});

  @override
  String toString() {
  return 'BusinessIssuccessAction { isSuccess: $isSuccess }';
  }
}

class UpdateIndustryList {
  final Map<String, dynamic> industryList;

  UpdateIndustryList({required this.industryList});

  @override
  String toString() {
  return 'BusinessDataAction { industryList: $industryList }';
  }
}

ThunkAction<AppState> getIndustryList = (Store<AppState> store) async {
    store.dispatch(BusinessLoadingAction(loading: true));
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.rootUrl}/APP_API/BusinessAndBranchManagement/IndustrySimpleListMobile'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${store.state.authState.firebaseToken}',
        },
        );
      if (response.statusCode == 200) {
        final Map<String, dynamic> industryList = convert.jsonDecode(response.body);
        store.dispatch(UpdateIndustryList(industryList: industryList));
        store.dispatch(BusinessLoadingAction(loading: false));
      } else {
        store.dispatch(BusinessFailedAction(error: 'Failed to load industry list'));
        store.dispatch(BusinessLoadingAction(loading: false));
      }
    } catch (e) {
      store.dispatch(BusinessFailedAction(error: 'Failed to load industry list'));
      store.dispatch(BusinessLoadingAction(loading: false));
    }
  };

class UpdateBusinessAddStatus {
  final bool businessAddStatus;

  UpdateBusinessAddStatus({required this.businessAddStatus});

  @override
  String toString() {
  return 'BusinessDataAction { businessAddStatus: $businessAddStatus }';
  }
}

ThunkAction<AppState> addBusiness (String businessName, String branchName, String selectedIndustry, double businessCreditLimit) {
  return (Store<AppState> store) async {
    store.dispatch(BusinessLoadingAction(loading: true));
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.rootUrl}/APP_API/BusinessAndBranchManagement/CreateBusinessMobile'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${store.state.authState.firebaseToken}',
        },
        body: convert.jsonEncode(<String, dynamic>{
          'CustomerId': store.state.authState.customerData['_id'],
          'FirstName': businessName,
          'LastName': branchName,
          'Mobile':  store.state.authState.customerData['Mobile'],
          'Industry': selectedIndustry,
          'BusinessCreditLimit': store.state.dashboardState.customerCurrentScreen == 'Seller' ? businessCreditLimit : '0',
          'CustomerCategory': store.state.dashboardState.customerCurrentScreen,
        }),
      );
      var responseData = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (responseData['Message'] == 'Mobile number already registered for this business name') {
          store.dispatch(BusinessLoadingAction(loading: false));
          store.dispatch(UpdateBusinessAddStatus(businessAddStatus: false));
          store.dispatch(BusinessFailedAction(error: 'Mobile number already registered for this business name'));
          store.dispatch(BusinessIssuccessAction(isSuccess: 2));
        } else {
        store.dispatch(UpdateBusinessAddStatus(businessAddStatus: true));
        store.dispatch(BusinessLoadingAction(loading: false));
        store.dispatch(BusinessIssuccessAction(isSuccess: 1));
        store.dispatch(getMyBusinessList);

        }
        

      } else {
        store.dispatch(BusinessFailedAction(error: 'Failed to add business'));
        store.dispatch(UpdateBusinessAddStatus(businessAddStatus: false));
        store.dispatch(BusinessLoadingAction(loading: false));
        store.dispatch(BusinessIssuccessAction(isSuccess: 2));
      }
    } catch (e) {
      store.dispatch(BusinessFailedAction(error: 'Failed to add business'));
      store.dispatch(UpdateBusinessAddStatus(businessAddStatus: false));
      store.dispatch(BusinessLoadingAction(loading: false));
      store.dispatch(BusinessIssuccessAction(isSuccess: 2));
    }
  };
}


class UpdateMyBusinessList {
  final List myBusinessList;

  UpdateMyBusinessList({required this.myBusinessList});

  @override
  String toString() {
  return 'BusinessDataAction { myBusinessList: $myBusinessList }';
  }
}

ThunkAction<AppState> getMyBusinessList = (Store<AppState> store) async {

    store.dispatch(BusinessLoadingAction(loading: true));
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.rootUrl}/APP_API/BusinessAndBranchManagement/MyBusinessListMobile?Customer=${store.state.authState.customerData['_id']}&CustomerCategory=${store.state.dashboardState.customerCurrentScreen}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${store.state.authState.firebaseToken}',
        },
        );
      final Map<String, dynamic> myBusinessList = convert.jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (myBusinessList['Status'] == 'false'){
        store.dispatch(BusinessFailedAction(error: myBusinessList['Message']));
        store.dispatch(BusinessLoadingAction(loading: false));
        return;
        }
        store.dispatch(UpdateMyBusinessList(myBusinessList: myBusinessList['Response']));
        store.dispatch(BusinessLoadingAction(loading: false));
        store.dispatch(UpdateBusinessListLoaded(businessListLoaded: 1));
        store.dispatch(UpdateMyBusinessListLocal(myBusinessListLocal: []));

      } else {
        store.dispatch(BusinessFailedAction(error: 'Failed to load my business list'));
        store.dispatch(BusinessLoadingAction(loading: false));
      }
    } catch (e) {
      store.dispatch(BusinessFailedAction(error: 'Failed to load my business list'));
      store.dispatch(BusinessLoadingAction(loading: false));
    }
  };

class UpdateCustomerBusinessList {
  final List customerBusinessList;

  UpdateCustomerBusinessList({required this.customerBusinessList});

  @override
  String toString() {
  return 'BusinessDataAction { customerBusinessList: $customerBusinessList }';
  }
  
}


ThunkAction<AppState> getCustomerBusinessList (String customerId, String customerCategory) {
  return (Store<AppState> store) async {

    try {
      final response = await http.get(
        Uri.parse('${AppConfig.rootUrl}/APP_API/BusinessAndBranchManagement/MyBusinessListMobile?Customer=$customerId&CustomerCategory=$customerCategory'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${store.state.authState.firebaseToken}',
        },
        );
      if (response.statusCode == 200) {
        final Map<String, dynamic> myBusinessList = convert.jsonDecode(response.body);
        store.dispatch(UpdateCustomerBusinessList(customerBusinessList: myBusinessList['Response']));

      } else {
        store.dispatch(BusinessFailedAction(error: 'Failed to load my business list'));
        store.dispatch(BusinessLoadingAction(loading: false));
      }
    } catch (e) {
      store.dispatch(BusinessFailedAction(error: 'Failed to load my business list'));
      store.dispatch(BusinessLoadingAction(loading: false));
    }
  };
}


  ThunkAction<AppState> updateBusiness (String businessId, String businessName, String branchName, String selectedIndustry, double businessCreditLimit) {

  return (Store<AppState> store) async {
    store.dispatch(BusinessLoadingAction(loading: true));
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.rootUrl}/APP_API/BusinessAndBranchManagement/BusinessUpdateMobile'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${store.state.authState.firebaseToken}',
        },
        body: convert.jsonEncode(<String, dynamic>{
          'CustomerId': store.state.authState.customerData['_id'],
          'BusinessId': businessId,
          'FirstName': businessName,
          'LastName': branchName,
          'Mobile':  store.state.authState.customerData['Mobile'],
          'Industry': selectedIndustry,
          'BusinessCreditLimit': businessCreditLimit,
          'CustomerCategory': store.state.dashboardState.customerCurrentScreen,
        }),
      );
      var responseData = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (responseData['Message'] == 'Mobile number already registered for this business name') {
          store.dispatch(BusinessLoadingAction(loading: false));
          store.dispatch(UpdateBusinessEditStatus(businessEditStatus: false));
          store.dispatch(BusinessFailedAction(error: 'Mobile number already registered for this business name'));
          store.dispatch(BusinessIssuccessAction(isSuccess: 2));
        } else {
        store.dispatch(UpdateBusinessEditStatus(businessEditStatus: true));
        store.dispatch(BusinessLoadingAction(loading: false));
        store.dispatch(BusinessIssuccessAction(isSuccess: 1));
        store.dispatch(UpdateMyBusinessListLocal(myBusinessListLocal: []));
        store.dispatch(getMyBusinessList);

        }
        

      } else {
        store.dispatch(BusinessFailedAction(error: 'Failed to update business'));
        store.dispatch(UpdateBusinessEditStatus(businessEditStatus: false));
        store.dispatch(BusinessLoadingAction(loading: false));
        store.dispatch(BusinessIssuccessAction(isSuccess: 2));
      }
    } catch (e) {
      store.dispatch(BusinessFailedAction(error: 'Failed to update business'));
      store.dispatch(UpdateBusinessEditStatus(businessEditStatus: false));
      store.dispatch(BusinessLoadingAction(loading: false));
      store.dispatch(BusinessIssuccessAction(isSuccess: 2));
    }
  };
}

class UpdateBusinessListLoaded {
  final int businessListLoaded;

  UpdateBusinessListLoaded({required this.businessListLoaded});

  @override
  String toString() {
  return 'BusinessDataAction { businessListLoaded: $businessListLoaded }';
  }
}

class UpdateMyBusinessListLocal {
  final List myBusinessListLocal;

  UpdateMyBusinessListLocal({required this.myBusinessListLocal});

  @override
  String toString() {
  return 'BusinessDataAction { myBusinessListLocal: $myBusinessListLocal }';
  }

}

class UpdateBusinessEditStatus {
  final bool businessEditStatus;

  UpdateBusinessEditStatus({required this.businessEditStatus});

  @override
  String toString() {
  return 'BusinessDataAction { businessEditStatus: $businessEditStatus }';
  }
}

class UpdateSellerBusinsessCustomerList {
  final List sellerBusinessCustomerList;

  UpdateSellerBusinsessCustomerList({required this.sellerBusinessCustomerList});

  @override
  String toString() {
  return 'BusinessDataAction { sellerBusinessCustomerList: $sellerBusinessCustomerList }';
  }
}

ThunkAction<AppState> getSellerBusinessCustomerList (Map data) {
  return (Store<AppState> store) async {
    store.dispatch(UpdateSellerBusinsessCustomerList(sellerBusinessCustomerList: []));
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.rootUrl}/APP_API/HundiScoreManagement/ConnectedCustomerWithAdvancedFilter'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${store.state.authState.firebaseToken}',
        },
        body: convert.jsonEncode(<String, dynamic>{
          'CustomerId': store.state.authState.customerData['_id'],
          'CustomerCategory': store.state.dashboardState.customerCurrentScreen,
          "FilterQuery": data['FilterQuery'],
        }),
        );
      if (response.statusCode == 200) {
        final Map<String, dynamic> sellerBusinessCustomerList = convert.jsonDecode(response.body);
        store.dispatch(UpdateSellerBusinsessCustomerList(sellerBusinessCustomerList: sellerBusinessCustomerList['Response']));
      } else {
        store.dispatch(BusinessFailedAction(error: 'Failed to load seller business customer list'));
      }
    } catch (e) {
      store.dispatch(BusinessFailedAction(error: 'Failed to load seller business customer list'));
    }
  };
}





	