import 'package:aquila_hundi/app/helper_widgets/config.dart';
import 'package:aquila_hundi/store/app.state.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class CommonValuesAction {
  @override
  String toString() {
    return 'CommonValuesAction{}';
  }
}

class CommonValuesFailedAction {
  final String error;
  CommonValuesFailedAction(this.error);

  @override
  String toString() {
    return 'CommonValuesFailedAction{error: $error}';
  }
}

class UpdateScreenWidthAction {
  final double screenWidth;
  UpdateScreenWidthAction(this.screenWidth);

  @override
  String toString() {
    return 'UpdateScreenWidthAction(screenWidth: $screenWidth)';
  }
}

class UpdateScreenHeightAction {
  final double screenHeight;
  UpdateScreenHeightAction(this.screenHeight);

  @override
  String toString() {
    return 'UpdateScreenHeightAction(screenHeight: $screenHeight)';
  }
}

class UpdateDeviceIDAction {
  final String deviceID;
  UpdateDeviceIDAction(this.deviceID);

  @override
  String toString() {
    return 'UpdateDeviceIDAction(deviceID: $deviceID)';
  }
}

class UpdateDeviceTypeAction {
  final String deviceType;
  UpdateDeviceTypeAction(this.deviceType);

  @override
  String toString() {
    return 'UpdateDeviceTypeAction(deviceType: $deviceType)';
  }
}

class UpdateSelectedBottomNavIndexAction {
  final int selectedBottomNavIndex;
  UpdateSelectedBottomNavIndexAction(this.selectedBottomNavIndex);

  @override
  String toString() {
    return 'UpdateSelectedBottomNavIndexAction(selectedBottomNavIndex: $selectedBottomNavIndex)';
  }
}

class UpdateNotificationsListAction {
  final List notificationsList;
  UpdateNotificationsListAction(this.notificationsList);

  @override
  String toString() {
    return 'UpdateNotificationsListAction(notificationsList: $notificationsList)';
  }
}

class UpdateNotificationsListLoadedAction {
  final bool notificationsListLoaded;
  UpdateNotificationsListLoadedAction(this.notificationsListLoaded);

  @override
  String toString() {
    return 'UpdateNotificationsListLoadedAction(notificationsListLoaded: $notificationsListLoaded)';
  }
}

class UpdateCommonValuesLoadingAction {
  final bool loading;
  UpdateCommonValuesLoadingAction(this.loading);

  @override
  String toString() {
    return 'UpdateCommonValuesLoadingAction(loading: $loading)';
  }
}

ThunkAction<AppState> getNotificationsList = (Store<AppState> store) async {
  store.dispatch(UpdateCommonValuesLoadingAction(true));
  try {
    // final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));
    // final List notificationsList = convert.jsonDecode(response.body);
    // store.dispatch(UpdateNotificationsListAction(notificationsList));
    final response = await http.post(
      Uri.parse(
          '${AppConfig.rootUrl}/APP_API/CommonManagement/All_Notifications_List'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization':
            'Bearer ${store.state.commonValuesState.firebaseToken}',
      },
      body: convert.jsonEncode(<String, dynamic>{
        'Customer': store.state.authState.customerData['_id'],
        'CustomerCategory': store.state.dashboardState.customerCurrentScreen,
      }),
    );
    final notificationsList = convert.jsonDecode(response.body);
    print('notificationsList: $notificationsList');
    if (notificationsList['Success'] == true) {
      store.dispatch(
          UpdateNotificationsListAction(notificationsList['Response']));
      store.dispatch(UpdateNotificationsListLoadedAction(true));
      store.dispatch(UpdateCommonValuesLoadingAction(false));
    } else {
      store.dispatch(UpdateNotificationsListLoadedAction(true));
      store.dispatch(CommonValuesFailedAction(notificationsList['Message']));
      store.dispatch(UpdateCommonValuesLoadingAction(false));
    }
  } catch (e) {
    store.dispatch(UpdateCommonValuesLoadingAction(false));
  }
};

ThunkAction<AppState> markNotificationRead(Map data) {
  return (Store<AppState> store) async {
    try {
      final response = await http.post(
        Uri.parse(
            '${AppConfig.rootUrl}/APP_API/CommonManagement/Notification_Viewed_Update'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization':
              'Bearer ${store.state.commonValuesState.firebaseToken}',
        },
        body: convert.jsonEncode(<String, dynamic>{
          'NotificationID': data['NotificationId'],
        }),
      );
      final responseData = convert.jsonDecode(response.body);
      if (responseData['Success'] == true) {
        store.dispatch(getNotificationsList);
      } else {
        store.dispatch(CommonValuesFailedAction(responseData['Message']));
      }
    } catch (e) {
      store.dispatch(UpdateCommonValuesLoadingAction(false));
    }
  };
}

//added by gnanalakshmi
ThunkAction<AppState> deleteNotification(String notificationId) {
  return (Store<AppState> store) async {
    try {
      final response = await http.post(
        Uri.parse(
            '${AppConfig.rootUrl}/APP_API/CommonManagement/Viewed_Notifications_Delete'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${store.state.authState.firebaseToken}'
        },
        body: convert.jsonEncode({
          'Customer': store.state.authState.customerData['_id'],
          'CustomerCategory': store.state.dashboardState.customerCurrentScreen,
          'NotificationID': notificationId,
        }),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            convert.jsonDecode(response.body);
        if (responseData['Success'] == true) {
          store.dispatch(getNotificationsList);
        } else {
          store.dispatch(CommonValuesFailedAction(responseData['Message']));
        }
      } else {
        store.dispatch(
            CommonValuesFailedAction('Failed to update notification status'));
      }
    } catch (error) {
      store.dispatch(UpdateCommonValuesLoadingAction(false));
    }
  };
}
//added by gnanalakshmi