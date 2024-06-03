
import 'package:aquila_hundi/store/commonValues/commonvalues.action.dart';
import 'package:aquila_hundi/store/commonValues/commonvalues.state.dart';
import 'package:redux/redux.dart';


CommonValuesState  updateScreenWidthReducer(CommonValuesState state, UpdateScreenWidthAction action) {
  return state.copyWith(screenWidth: action.screenWidth);
}

CommonValuesState  updateScreenHeightReducer(CommonValuesState state, UpdateScreenHeightAction action) {
  return state.copyWith(screenHeight: action.screenHeight);
}

CommonValuesState updateDeviceIDReducer(CommonValuesState state, UpdateDeviceIDAction action) {
  return state.copyWith(deviceID: action.deviceID);
}

CommonValuesState updateDeviceTypeReducer(CommonValuesState state, UpdateDeviceTypeAction action) {
  return state.copyWith(deviceType: action.deviceType);
}

CommonValuesState updateSelectedBottomNavIndexReducer(CommonValuesState state, UpdateSelectedBottomNavIndexAction action) {
  return state.copyWith(selectedBottomNavIndex: action.selectedBottomNavIndex);
}

CommonValuesState updateNotificationsListReducer(CommonValuesState state, UpdateNotificationsListAction action) {
  return state.copyWith(notificationsList: action.notificationsList);
}

CommonValuesState updateNotificationsListLoadedReducer(CommonValuesState state, UpdateNotificationsListLoadedAction action) {
  return state.copyWith(notificationsListLoaded: action.notificationsListLoaded);
}

CommonValuesState updateCommonValuesLoadingReducer(CommonValuesState state, UpdateCommonValuesLoadingAction action) {
  return state.copyWith(loading: action.loading);
}

CommonValuesState updateCommonValuesFailedReducer(CommonValuesState state, CommonValuesFailedAction action) {
  return state.copyWith(error: action.error);
}

final commonValuesReducer = combineReducers<CommonValuesState>([
  TypedReducer<CommonValuesState, UpdateScreenWidthAction>(updateScreenWidthReducer).call,
  TypedReducer<CommonValuesState, UpdateScreenHeightAction>(updateScreenHeightReducer).call,
  TypedReducer<CommonValuesState, UpdateDeviceIDAction>(updateDeviceIDReducer).call,
  TypedReducer<CommonValuesState, UpdateDeviceTypeAction>(updateDeviceTypeReducer).call,
  TypedReducer<CommonValuesState, UpdateSelectedBottomNavIndexAction>(updateSelectedBottomNavIndexReducer).call,
  TypedReducer<CommonValuesState, UpdateNotificationsListAction>(updateNotificationsListReducer).call,
  TypedReducer<CommonValuesState, UpdateNotificationsListLoadedAction>(updateNotificationsListLoadedReducer).call,
  TypedReducer<CommonValuesState, UpdateCommonValuesLoadingAction>(updateCommonValuesLoadingReducer).call,
  TypedReducer<CommonValuesState, CommonValuesFailedAction>(updateCommonValuesFailedReducer).call,
]);