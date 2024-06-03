
import 'package:redux/redux.dart';
import 'package:aquila_hundi/store/payments/payments.state.dart';
import 'package:aquila_hundi/store/payments/payments.action.dart';

PaymentsState updatePaymentsLoading(PaymentsState state, PaymentsLoadingAction action) {
  return state.copyWith(loading: action.loading);
}

PaymentsState updatePaymentsError(PaymentsState state, PaymentsFailedAction action) {
  return state.copyWith(error: action.error);
}

PaymentsState updatePaymentsList(PaymentsState state, UpdatePaymentsList action) {
  return state.copyWith(paymentList: action.paymentList);
}

PaymentsState updatePaymentsListLoaded(PaymentsState state, UpdatePaymentsListLoaded action) {
  return state.copyWith(paymentListLoaded: action.paymentListLoaded);
}

PaymentsState updatePaymentsListLocal(PaymentsState state, UpdatePaymentsListLocal action) {
  return state.copyWith(paymentListLocal: action.paymentListLocal);
}

PaymentsState updatePaymentsListEndReached(PaymentsState state, UpdatePaymentsListEndReached action) {
  return state.copyWith(paymentListEndReached: action.paymentListEndReached);
}

PaymentsState updatePaymentsStatusType(PaymentsState state, UpdatePaymentStatusType action) {
  return state.copyWith(paymentStatusType: action.paymentStatusType);
}

PaymentsState updatePaymentsCreated(PaymentsState state, UpdatePaymentCreated action) {
  return state.copyWith(paymentCreated: action.paymentCreated);
}

PaymentsState updatePaymentsCreateLoading(PaymentsState state, UpdatePaymentCreateLoading action) {
  return state.copyWith(paymentCreateLoading: action.paymentCreateLoading);
}

PaymentsState updatePaymentStatusUpdated(PaymentsState state, UpdatePaymentStatusUpdated action) {
  return state.copyWith(paymentStatusUpdated: action.paymentStatusUpdated);
}

PaymentsState updatePaymentsStatusLoading(PaymentsState state, UpdatePaymentStatusLoading action) {
  return state.copyWith(paymentsStatusLoading: action.paymentStatusLoading);
}

PaymentsState updateDisputeStatusUpdated(PaymentsState state, UpdateDisputeStatusUpdated action) {
  return state.copyWith(disputeStatusUpdated: action.disputeStatusUpdated);
}

PaymentsState updateEditPaymentSuccess(PaymentsState state, UpdateEditPaymentSuccess action) {
  return state.copyWith(editPaymentSuccess: action.editPaymentSuccess);
}

final paymentsReducer = combineReducers<PaymentsState>([
  TypedReducer<PaymentsState, PaymentsLoadingAction>(updatePaymentsLoading).call,
  TypedReducer<PaymentsState, PaymentsFailedAction>(updatePaymentsError).call,
  TypedReducer<PaymentsState, UpdatePaymentsList>(updatePaymentsList).call,
  TypedReducer<PaymentsState, UpdatePaymentsListLoaded>(updatePaymentsListLoaded).call,
  TypedReducer<PaymentsState, UpdatePaymentsListLocal>(updatePaymentsListLocal).call,
  TypedReducer<PaymentsState, UpdatePaymentsListEndReached>(updatePaymentsListEndReached).call,
  TypedReducer<PaymentsState, UpdatePaymentStatusType>(updatePaymentsStatusType).call,
  TypedReducer<PaymentsState, UpdatePaymentCreated>(updatePaymentsCreated).call,
  TypedReducer<PaymentsState, UpdatePaymentCreateLoading>(updatePaymentsCreateLoading).call,
  TypedReducer<PaymentsState, UpdatePaymentStatusUpdated>(updatePaymentStatusUpdated).call,
  TypedReducer<PaymentsState, UpdatePaymentStatusLoading>(updatePaymentsStatusLoading).call,
  TypedReducer<PaymentsState, UpdateDisputeStatusUpdated>(updateDisputeStatusUpdated).call,
  TypedReducer<PaymentsState, UpdateEditPaymentSuccess>(updateEditPaymentSuccess).call,
]);
	