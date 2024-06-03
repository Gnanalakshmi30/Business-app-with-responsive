import 'package:aquila_hundi/store/business/business.state.dart';
import 'package:aquila_hundi/store/business/business.action.dart';
import 'package:redux/redux.dart';

BusinessState updateIndustryListReducer(BusinessState state, UpdateIndustryList action) {
  return state.copyWith(industryList: action.industryList);
}

BusinessState updateBusinessLoadingReducer(BusinessState state, BusinessLoadingAction action) {
  return state.copyWith(loading: action.loading);
}

BusinessState updateBusinessIsSuccess(BusinessState state, BusinessIssuccessAction action) {
  return state.copyWith(isSuccess: action.isSuccess);
}

BusinessState updateBusinessErrorReducer(BusinessState state, BusinessFailedAction action) {
  return state.copyWith(error: action.error);
}

BusinessState updateBusinessAddStatusReducer(BusinessState state, UpdateBusinessAddStatus action) {
  return state.copyWith(businessAddStatus: action.businessAddStatus);
}

BusinessState updateMyBusinessListReducer(BusinessState state, UpdateMyBusinessList action) {
  return state.copyWith(myBusinessList: action.myBusinessList);
}

BusinessState updateBusinessListLoadedReducer(BusinessState state, UpdateBusinessListLoaded action) {
  return state.copyWith(businessListLoaded: action.businessListLoaded);
}

BusinessState updateBusinessListLocalReducer(BusinessState state, UpdateMyBusinessListLocal action) {
  return state.copyWith(myBusinessListLocal: action.myBusinessListLocal);
}

BusinessState updateBusinessEditStatusReducer(BusinessState state, UpdateBusinessEditStatus action) {
  return state.copyWith(businessEditStatus: action.businessEditStatus);
}

BusinessState updateSellerBusinessCustomerListReducer(BusinessState state, UpdateSellerBusinsessCustomerList action) {
  return state.copyWith(sellerBusinessCustomerList: action.sellerBusinessCustomerList);
}

BusinessState updateCustomerBusinessListReducer(BusinessState state, UpdateCustomerBusinessList action) {
  return state.copyWith(customerBusinessList: action.customerBusinessList);
}



final businessReducer = combineReducers<BusinessState>([
  TypedReducer<BusinessState, UpdateIndustryList>(updateIndustryListReducer).call,
  TypedReducer<BusinessState, BusinessLoadingAction>(updateBusinessLoadingReducer).call,
  TypedReducer<BusinessState, BusinessIssuccessAction>(updateBusinessIsSuccess).call,
  TypedReducer<BusinessState, BusinessFailedAction>(updateBusinessErrorReducer).call,
  TypedReducer<BusinessState, UpdateBusinessAddStatus>(updateBusinessAddStatusReducer).call,
  TypedReducer<BusinessState, UpdateMyBusinessList>(updateMyBusinessListReducer).call,
  TypedReducer<BusinessState, UpdateBusinessListLoaded>(updateBusinessListLoadedReducer).call,
  TypedReducer<BusinessState, UpdateMyBusinessListLocal>(updateBusinessListLocalReducer).call,
  TypedReducer<BusinessState, UpdateBusinessEditStatus>(updateBusinessEditStatusReducer).call,
  TypedReducer<BusinessState, UpdateSellerBusinsessCustomerList>(updateSellerBusinessCustomerListReducer).call,
  TypedReducer<BusinessState, UpdateCustomerBusinessList>(updateCustomerBusinessListReducer).call,
]);
	