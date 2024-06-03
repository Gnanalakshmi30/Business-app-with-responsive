
import 'package:aquila_hundi/store/dashboard/dashboard.state.dart';
import 'package:aquila_hundi/store/dashboard/dashboard.action.dart';
import 'package:redux/redux.dart';

DashboardState updateDashboardDataReducer(DashboardState state, DashboardDataAction action) {
  return state.copyWith(dashboardData: action.dashboardData);
}

DashboardState updateDashboardLoadingReducer(DashboardState state, DashboardLoadingAction action) {
  return state.copyWith(loading: action.loading);
}

DashboardState updateDashboardErrorReducer(DashboardState state, DashboardFailedAction action) {
  return state.copyWith(error: action.error);
}

DashboardState updateDashboardSuccessReducer(DashboardState state, DashboardSuccessAction action) {
  return state.copyWith(isSuccess: action.isSuccess);
}

DashboardState updateMenuItemClickedReducer(DashboardState state, UpdateMenuItemClicked action) {
  return state.copyWith(menuIconClicked: action.menuIconClicked);
}

DashboardState updateCustomerCurrentScreenReducer(DashboardState state, UpdateCustomerCurrentScreen action) {
  return state.copyWith(customerCurrentScreen: action.customerCurrentScreen);
}

DashboardState updateNewBusinessStatus(DashboardState state, UpdateNewBusinessStatus action) {
  return state.copyWith(newBusiness: action.newBusiness);
}

DashboardState updateCreateSendButton(DashboardState state, UpdateCreateSendButton action) {
  return state.copyWith(createSendButton: action.createSendButton);
}

final dashboardReducer = combineReducers<DashboardState>([
  TypedReducer<DashboardState, DashboardDataAction>(updateDashboardDataReducer).call,
  TypedReducer<DashboardState, DashboardLoadingAction>(updateDashboardLoadingReducer).call,
  TypedReducer<DashboardState, DashboardFailedAction>(updateDashboardErrorReducer).call,
  TypedReducer<DashboardState, DashboardSuccessAction>(updateDashboardSuccessReducer).call,
  TypedReducer<DashboardState, UpdateMenuItemClicked>(updateMenuItemClickedReducer).call,
  TypedReducer<DashboardState, UpdateCustomerCurrentScreen>(updateCustomerCurrentScreenReducer).call,
  TypedReducer<DashboardState, UpdateNewBusinessStatus>(updateNewBusinessStatus).call,
  TypedReducer<DashboardState, UpdateCreateSendButton>(updateCreateSendButton).call,
]);