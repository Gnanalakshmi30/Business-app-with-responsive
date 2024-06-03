import 'package:redux/redux.dart';
import 'package:aquila_hundi/store/support/support.state.dart';
import 'package:aquila_hundi/store/support/support.action.dart';

SupportState updateSupportLoading(SupportState state, SupportLoadingAction action) {
  return state.copyWith(loading: action.loading);
}

SupportState updateSupportError(SupportState state, SupportFailedAction action) {
  return state.copyWith(error: action.error);
}

SupportState updateSupportList(SupportState state, UpdateSupportList action) {
  return state.copyWith(supportList: action.supportList);
}

SupportState updateSupportListLoaded(SupportState state, UpdateSupportListLoaded action) {
  return state.copyWith(supportListLoaded: action.supportListLoaded);
}

SupportState updateSupportCreateLoading(SupportState state, SupportCreateLoadingAction action) {
  return state.copyWith(supportCreateLoading: action.supportCreateLoading);
}

SupportState updateSupportCreated(SupportState state, SupportCreatedAction action) {
  return state.copyWith(supportCreated: action.supportCreated);
}

final supportReducer = combineReducers<SupportState>([
  TypedReducer<SupportState, SupportLoadingAction>(updateSupportLoading).call,
  TypedReducer<SupportState, SupportFailedAction>(updateSupportError).call,
  TypedReducer<SupportState, UpdateSupportList>(updateSupportList).call,
  TypedReducer<SupportState, UpdateSupportListLoaded>(updateSupportListLoaded).call,
  TypedReducer<SupportState, SupportCreateLoadingAction>(updateSupportCreateLoading).call,
  TypedReducer<SupportState, SupportCreatedAction>(updateSupportCreated).call,
]);






	