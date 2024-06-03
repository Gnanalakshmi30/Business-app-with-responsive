
import 'package:aquila_hundi/store/invite/invite.state.dart';
import 'package:aquila_hundi/store/invite/invite.action.dart';
import 'package:redux/redux.dart';



InviteState updateInviteLoading (InviteState state, InviteLoadingAction action) {
  return state.copyWith(loading: action.loading);
}

InviteState updateError (InviteState state, InviteFailedAction action) {
  return state.copyWith(error: action.error);
}

InviteState updateInviteList (InviteState state, UpdateAcceptedList action) {
  return state.copyWith(acceptedList: action.acceptedList);
}

InviteState updateInviteListLoaded (InviteState state, UpdateInviteListLoaded action) {
  return state.copyWith(inviteListLoaded: action.inviteListLoaded);
}

InviteState updateInviteListLocal (InviteState state, UpdateInviteListLocal action) {
  return state.copyWith(inviteListLocal: action.inviteListLocal);
}

InviteState updateEditCreditLoading (InviteState state, UpdateEditCreditLoading action) {
  return state.copyWith(editCreditLoading: action.editCreditLoading);
}

InviteState updateEditCreditError (InviteState state, UpdateEditCreditError action) {
  return state.copyWith(editCreditError: action.editCreditError);
}

InviteState updateEditCreditSuccess (InviteState state, UpdateEditCreditSuccess action) {
  return state.copyWith(editCreditSuccess: action.editCreditSuccess);
}

InviteState updateInviteBuyerSuccess (InviteState state, UpdateInviteBuyerSuccess action) {
  return state.copyWith(inviteBuyerSuccess: action.inviteBuyerSuccess);
}

InviteState updateInviteHistoryList (InviteState state, UpdateInviteHistoryList action) {
  return state.copyWith(inviteHistoryList: action.inviteHistoryList);
}

InviteState updateInviteHistoryListLoaded (InviteState state, UpdateInviteHistoryListLoaded action) {
  return state.copyWith(inviteHistoryListLoaded: action.inviteHistoryListLoaded);
}

InviteState updateMobileNumberVerified (InviteState state, UpdateMobileNumberVerified action) {
  return state.copyWith(mobileNumberVerified: action.mobileNumberVerified);
}

InviteState updateCustomerFromMobileNumber (InviteState state, UpdateCustomerFromMobileNumber action) {
  return state.copyWith(customerFromMobileNumber: action.customerFromMobileNumber);
}

InviteState updateEditRequestFromInvoice (InviteState state, UpdateEditRequestFromInvoice action) {
  return state.copyWith(editRequestFromInvoice: action.editRequestFromInvoice);
}

InviteState updateEditRequestBuyerId (InviteState state, UpdateEditRequestBuyerId action) {
  return state.copyWith(editRequestBuyerId: action.editRequestBuyerId);
}

final inviteReducer = combineReducers<InviteState>([
  TypedReducer<InviteState, InviteLoadingAction>(updateInviteLoading).call,
  TypedReducer<InviteState, InviteFailedAction>(updateError).call,
  TypedReducer<InviteState, UpdateAcceptedList>(updateInviteList).call,
  TypedReducer<InviteState, UpdateInviteListLoaded>(updateInviteListLoaded).call,
  TypedReducer<InviteState, UpdateInviteListLocal>(updateInviteListLocal).call,
  TypedReducer<InviteState, UpdateEditCreditLoading>(updateEditCreditLoading).call,
  TypedReducer<InviteState, UpdateEditCreditError>(updateEditCreditError).call,
  TypedReducer<InviteState, UpdateEditCreditSuccess>(updateEditCreditSuccess).call,
  TypedReducer<InviteState, UpdateInviteBuyerSuccess>(updateInviteBuyerSuccess).call,
  TypedReducer<InviteState, UpdateInviteHistoryList>(updateInviteHistoryList).call,
  TypedReducer<InviteState, UpdateInviteHistoryListLoaded>(updateInviteHistoryListLoaded).call,
  TypedReducer<InviteState, UpdateMobileNumberVerified>(updateMobileNumberVerified).call,
  TypedReducer<InviteState, UpdateCustomerFromMobileNumber>(updateCustomerFromMobileNumber).call,
  TypedReducer<InviteState, UpdateEditRequestFromInvoice>(updateEditRequestFromInvoice).call,
  TypedReducer<InviteState, UpdateEditRequestBuyerId>(updateEditRequestBuyerId).call,
]);