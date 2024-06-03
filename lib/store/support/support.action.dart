
import 'package:aquila_hundi/app/helper_widgets/config.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:aquila_hundi/store/app.state.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;


class SupportAction {

	@override
	String toString() {
	return 'SupportAction { }';
	}
}

class SupportSuccessAction {
	final int isSuccess;

	SupportSuccessAction({required this.isSuccess});
	@override
	String toString() {
	return 'SupportSuccessAction { isSuccess: $isSuccess }';
	}
}

class SupportFailedAction {
	final String error;

	SupportFailedAction({required this.error});

	@override
	String toString() {
	return 'SupportFailedAction { error: $error }';
	}
}

class SupportLoadingAction {
  final bool loading;

  SupportLoadingAction({required this.loading});

  @override
  String toString() {
  return 'SupportLoadingAction { loading: $loading }';
  }
}

class UpdateSupportList {
  final List supportList;

  UpdateSupportList({required this.supportList});

  @override
  String toString() {
  return 'SupportDataAction { supportList: $supportList }';
  }
}

class UpdateSupportListLoaded {
  final bool supportListLoaded;

  UpdateSupportListLoaded({required this.supportListLoaded});

  @override
  String toString() {
  return 'SupportDataAction { supportListLoaded: $supportListLoaded }';
  }
}

class SupportCreateLoadingAction {
  final bool supportCreateLoading;

  SupportCreateLoadingAction({required this.supportCreateLoading});

  @override
  String toString() {
  return 'SupportCreateLoadingAction { supportCreateLoading: $supportCreateLoading }';
  }
}

class SupportCreatedAction {
  final bool supportCreated;

  SupportCreatedAction({required this.supportCreated});

  @override
  String toString() {
  return 'SupportCreatedAction { supportCreated: $supportCreated }';
  }
}

ThunkAction<AppState> createSupport(Map supportData) {
  return (Store<AppState> store) async {
    store.dispatch(SupportCreateLoadingAction(supportCreateLoading: true));
    store.dispatch(SupportLoadingAction(loading: true));
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.rootUrl}/APP_API/SupportManagement/CustomerSupport_Create'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${store.state.authState.firebaseToken}',
        },
        body: convert.jsonEncode({
          'CustomerId': store.state.authState.customerData['_id'],
          'SupportTitle': supportData['Title'],
          'Message': supportData['Query'],
        
        }),
      );
      final responseData = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        store.dispatch(SupportCreatedAction(supportCreated: true));
        store.dispatch(SupportLoadingAction(loading: false));
        store.dispatch(SupportCreateLoadingAction(supportCreateLoading: false));
        store.dispatch(getSupportList());
      } else {
        store.dispatch(SupportFailedAction(error: responseData['message']));
        store.dispatch(SupportLoadingAction(loading: false));
        store.dispatch(SupportCreateLoadingAction(supportCreateLoading: false));
      }
    } catch (error) {
      store.dispatch(SupportFailedAction(error: 'An error occurred'));
      store.dispatch(SupportLoadingAction(loading: false));
      store.dispatch(SupportCreateLoadingAction(supportCreateLoading: false));
    }
  };
}

ThunkAction<AppState> getSupportList() {
  return (Store<AppState> store) async {
      store.dispatch(SupportLoadingAction(loading: true));
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.rootUrl}/APP_API/SupportManagement/CustomerSupport_List'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${store.state.authState.firebaseToken}',
        },
        body: convert.jsonEncode({
          'CustomerId': store.state.authState.customerData['_id'],
        }),
      );
      final responseData = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (responseData['Status'] == true){
        store.dispatch(UpdateSupportList(supportList: responseData['Response']));
        store.dispatch(SupportLoadingAction(loading: false));
        store.dispatch(UpdateSupportListLoaded(supportListLoaded: true));
      } else {
        store.dispatch(SupportFailedAction(error: responseData['message']));
        store.dispatch(SupportLoadingAction(loading: false));
        store.dispatch(UpdateSupportListLoaded(supportListLoaded: false));
      }
      } else {
        store.dispatch(SupportFailedAction(error: 'An error occurred'));
        store.dispatch(SupportLoadingAction(loading: false));
        store.dispatch(UpdateSupportListLoaded(supportListLoaded: false));
      }
    } catch (error) {
      store.dispatch(SupportFailedAction(error: 'An error occurred'));
      store.dispatch(SupportLoadingAction(loading: false));
      store.dispatch(UpdateSupportListLoaded(supportListLoaded: false));
    }
  };
}

	