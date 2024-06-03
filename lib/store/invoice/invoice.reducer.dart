
import 'package:redux/redux.dart';
import 'package:aquila_hundi/store/invoice/invoice.state.dart';
import 'package:aquila_hundi/store/invoice/invoice.action.dart';

InvoiceState updateInvoiceLoading(InvoiceState state, InvoiceLoadingAction action) {
  return state.copyWith(loading: action.loading);
}

InvoiceState updateInvoiceError(InvoiceState state, InvoiceFailedAction action) {
  return state.copyWith(error: action.error);
}

InvoiceState updateInvoiceList(InvoiceState state, UpdateInvoiceList action) {
  return state.copyWith(invoiceList: action.invoiceList);
}

InvoiceState updateInvoiceListLoaded(InvoiceState state, UpdateInvoiceListLoaded action) {
  return state.copyWith(invoiceListLoaded: action.invoiceListLoaded);
}

InvoiceState updateInvoiceListLocal(InvoiceState state, UpdateInvoiceListLocal action) {
  return state.copyWith(invoiceListLocal: action.invoiceListLocal);
}

InvoiceState updateInvoiceListEndReached(InvoiceState state, UpdateInvoiceListEndReached action) {
  return state.copyWith(invoiceListEndReached: action.invoiceListEndReached);
}

InvoiceState updateInvoiceStatusType(InvoiceState state, UpdateInvoiceStatusType action) {
  return state.copyWith(invoiceStatusType: action.invoiceStatusType);
}

InvoiceState updateInvoiceCreated(InvoiceState state, UpdateInvoiceCreated action) {
  return state.copyWith(invoiceCreated: action.invoiceCreated);
}

InvoiceState updateInvoiceCreateLoading(InvoiceState state, UpdateInvoiceCreateLoading action) {
  return state.copyWith(invoiceCreateLoading: action.invoiceCreateLoading);
}

InvoiceState updateInvoiceStatusUpdated(InvoiceState state, UpdateInvoiceStatusUpdated action) {
  return state.copyWith(invoiceStatusUpdated: action.invoiceStatusUpdated);
}

InvoiceState updateInvoiceStatusLoadingReducer(InvoiceState state, UpdateInvoiceStatusLoading action) {
  return state.copyWith(invoiceStatusLoading: action.invoiceStatusLoading);
}

InvoiceState updateInvoiceDisputeStatusUpdated(InvoiceState state, UpdateInvoiceDisputeStatusUpdated action) {
  return state.copyWith(invoiceDisputedStatusUpdated: action.invoiceDisputedStatusUpdated);
}

final invoiceReducer = combineReducers<InvoiceState>([
  TypedReducer<InvoiceState, InvoiceLoadingAction>(updateInvoiceLoading).call,
  TypedReducer<InvoiceState, InvoiceFailedAction>(updateInvoiceError).call,
  TypedReducer<InvoiceState, UpdateInvoiceList>(updateInvoiceList).call,
  TypedReducer<InvoiceState, UpdateInvoiceListLoaded>(updateInvoiceListLoaded).call,
  TypedReducer<InvoiceState, UpdateInvoiceListLocal>(updateInvoiceListLocal).call,
  TypedReducer<InvoiceState, UpdateInvoiceListEndReached>(updateInvoiceListEndReached).call,
  TypedReducer<InvoiceState, UpdateInvoiceStatusType>(updateInvoiceStatusType).call,
  TypedReducer<InvoiceState, UpdateInvoiceCreated>(updateInvoiceCreated).call,
  TypedReducer<InvoiceState, UpdateInvoiceCreateLoading>(updateInvoiceCreateLoading).call,
  TypedReducer<InvoiceState, UpdateInvoiceStatusUpdated>(updateInvoiceStatusUpdated).call,
  TypedReducer<InvoiceState, UpdateInvoiceStatusLoading>(updateInvoiceStatusLoadingReducer).call,
  TypedReducer<InvoiceState, UpdateInvoiceDisputeStatusUpdated>(updateInvoiceDisputeStatusUpdated).call,
]);