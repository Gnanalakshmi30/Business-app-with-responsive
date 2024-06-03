
import 'package:redux/redux.dart';
import 'package:aquila_hundi/store/auth/auth.state.dart';
import 'package:aquila_hundi/store/auth/auth.action.dart';

AuthState authSuccess (AuthState state, AuthSuccessAction action) {
  return state.copyWith(loading: action.loading);
}

AuthState authFailure (AuthState state, AuthFailedAction action) {
  return state.copyWith(error: action.error);
}

AuthState  updateOTP (AuthState state, UpdateOTPAction action) {
  return state.copyWith(otp: action.otp, otpStatus: true);
}

AuthState  updateOTPStatus (AuthState state, AuthOtpStatusAction action) {
  return state.copyWith(otpStatus: action.otpStatus);
}

AuthState updateMobileNumber (AuthState state, UpdateMobileNumberAction action) {
  return state.copyWith(mobileNumber: action.mobileNumber);
}

AuthState updateCustomerType (AuthState state, UpdateCustomerTypeAction action) {
  return state.copyWith(customerType: action.customerType);
}

AuthState updateFirebaseToken (AuthState state, UpdateFirebaseTokenAction action) {
  return state.copyWith(firebaseToken: action.firebaseToken);
}

AuthState updatOTPVerified (AuthState state, UpdateOTPVerifiedAction action) {
  return state.copyWith(isOTPVerified: action.isOTPVerified);
}

AuthState updateCustomerDetails (AuthState state, UpdateOwnerDetails action) {
  return state.copyWith(
    contactName: action.contactName,
    email: action.email,
    customerCategory: action.customerCategory,
    state: action.state,
  );
}

AuthState updateStateList (AuthState state, UpdateStateList action) {
  return state.copyWith(stateList: action.stateList);
}

AuthState updateCustomerData (AuthState state, UpdateCustomerData action) {
  return state.copyWith(customerData: action.customerData);
}

AuthState updateDeviceOtp (AuthState state, UpdateDeviceOTP action) {
  return state.copyWith(deviceOtp: action.deviceOtp);
}

AuthState updateRegisterSuccess (AuthState state, UpdateRegisterSuccess action) {
  return state.copyWith(registerSuccess: action.registerSuccess);
}

AuthState updateUserList (AuthState state, UpdateUserList action) {
  return state.copyWith(userList: action.userList, isUserListLoaded: true);
}

AuthState updateUserListLoaded (AuthState state, UpdateUserListLoaded action) {
  return state.copyWith(isUserListLoaded: action.isUserListLoaded);
}

AuthState updateUserCreateLoading (AuthState state, UpdateUserCreateLoading action) {
  return state.copyWith(userCreateLoading: action.userCreateLoading);
}

AuthState updateUserCreateSuccess (AuthState state, UpdateUserCreateSuccess action) {
  return state.copyWith(userCreateSuccess: action.userCreateSuccess);
}

final authReducer = combineReducers<AuthState>([
  TypedReducer<AuthState, AuthSuccessAction>(authSuccess).call,
  TypedReducer<AuthState, AuthFailedAction>(authFailure).call,
  TypedReducer<AuthState, UpdateOTPAction>(updateOTP).call,
  TypedReducer<AuthState, AuthOtpStatusAction>(updateOTPStatus).call,
  TypedReducer<AuthState, UpdateMobileNumberAction>(updateMobileNumber).call,
  TypedReducer<AuthState, UpdateCustomerTypeAction>(updateCustomerType).call,
  TypedReducer<AuthState, UpdateFirebaseTokenAction>(updateFirebaseToken).call,
  TypedReducer<AuthState, UpdateOTPVerifiedAction>(updatOTPVerified).call,
  TypedReducer<AuthState, UpdateOwnerDetails>(updateCustomerDetails).call,
  TypedReducer<AuthState, UpdateStateList>(updateStateList).call,
  TypedReducer<AuthState, UpdateCustomerData>(updateCustomerData).call,
  TypedReducer<AuthState, UpdateDeviceOTP>(updateDeviceOtp).call,
  TypedReducer<AuthState, UpdateRegisterSuccess>(updateRegisterSuccess).call,
  TypedReducer<AuthState, UpdateUserList>(updateUserList).call,
  TypedReducer<AuthState, UpdateUserListLoaded>(updateUserListLoaded).call,
  TypedReducer<AuthState, UpdateUserCreateLoading>(updateUserCreateLoading).call,
  TypedReducer<AuthState, UpdateUserCreateSuccess>(updateUserCreateSuccess).call,
]);

	