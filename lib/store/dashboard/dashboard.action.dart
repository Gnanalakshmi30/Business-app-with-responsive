
import 'package:aquila_hundi/app/helper_widgets/config.dart';
import 'package:aquila_hundi/main.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:aquila_hundi/store/app.state.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;


class DashboardAction {

	@override
	String toString() {
	return 'DashboardAction { }';
	}
}

class DashboardSuccessAction {
	final int isSuccess;

	DashboardSuccessAction({required this.isSuccess});
	@override
	String toString() {
	return 'DashboardSuccessAction { isSuccess: $isSuccess }';
	}
}

class DashboardFailedAction {
	final String error;

	DashboardFailedAction({required this.error});

	@override
	String toString() {
	return 'DashboardFailedAction { error: $error }';
	}
}

class DashboardLoadingAction {
  final bool loading;

  DashboardLoadingAction({required this.loading});

  @override
  String toString() {
  return 'DashboardLoadingAction { loading: $loading }';
  }
}

class DashboardDataAction {
  final Map<String, dynamic> dashboardData;

  DashboardDataAction({required this.dashboardData});

  @override
  String toString() {
  return 'DashboardDataAction { dashboardData: $dashboardData }';
  }
}

ThunkAction<AppState> getDashboardDataAction = (Store<AppState> store) async {
  store.dispatch(DashboardLoadingAction(loading: true));
  try {
    final response = await http.post(
      Uri.parse('${AppConfig.rootUrl}/APP_API/HundiScoreManagement/CustomerDashBoard'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${store.state.authState.firebaseToken}',
      },
      body: convert.jsonEncode(<String, dynamic>{
        'CustomerId': store.state.authState.customerData['_id'],
        'CustomerCategory': store.state.dashboardState.customerCurrentScreen,
      }),
      );
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = convert.jsonDecode(response.body);
      store.dispatch(DashboardDataAction(dashboardData: responseData['Response']));
      store.dispatch(UpdateNewBusinessStatus(responseData['Response']['MyBusiness'] == true ? false : true));
      store.dispatch(DashboardSuccessAction(isSuccess: 1));
      store.dispatch(DashboardLoadingAction(loading: false));
    } else {
      store.dispatch(DashboardFailedAction(error: 'Failed to load data'));
      store.dispatch(DashboardSuccessAction(isSuccess: 0));
      store.dispatch(DashboardLoadingAction(loading: false));
    }
  } catch (e) {
    store.dispatch(DashboardFailedAction(error: 'Failed to load data'));
    store.dispatch(DashboardSuccessAction(isSuccess: 0));
    store.dispatch(DashboardLoadingAction(loading: false));
  }
};

class UpdateMenuItemClicked {
  final bool menuIconClicked;

  UpdateMenuItemClicked(this.menuIconClicked);

  @override
  String toString() {
  return 'UpdateMenuItemClicked { menuIconClicked: $menuIconClicked }';
  }
}

class UpdateCustomerCurrentScreen {
  final String customerCurrentScreen;

  UpdateCustomerCurrentScreen(this.customerCurrentScreen);

  @override
  String toString() {
  return 'UpdateCustomerCurrentScreen { customerCurrentScreen: $customerCurrentScreen }';
  }
}

class UpdateNewBusinessStatus {
  final bool newBusiness;

  UpdateNewBusinessStatus(this.newBusiness);

  @override
  String toString() {
  return 'UpdateNewBusinessStatus { newBusiness: $newBusiness }';
  }
}

class UpdateCreateSendButton {
  final String createSendButton;

  UpdateCreateSendButton(this.createSendButton);

  @override
  String toString() {
  return 'UpdateCreateSendButton { createSendButton: $createSendButton }';
  }
}
	