import 'package:aquila_hundi/store/myProfile/myProfile.action.dart';
import 'package:aquila_hundi/store/myProfile/myProfile.state.dart';
import 'package:redux/redux.dart';

MyProfileState updateMyProfileFailedAction(
    MyProfileState state, MyProfileFailedAction action) {
  return state.copyWith(error: action.error);
}

MyProfileState updateMyProfileLoadingActionr(
    MyProfileState state, MyProfileLoadingAction action) {
  return state.copyWith(loading: action.loading);
}

MyProfileState myProfileUpdated(MyProfileState state, MyProfileUpdated action) {
  return state.copyWith(myProfileupdated: action.myProfileupdated);
}

MyProfileState updateProfileImageUpdated(
    MyProfileState state, UpdateProfileImageUpdated action) {
  return state.copyWith(profileImageUpdated: action.profileImageUpdated);
}

final myProfileReducer = combineReducers<MyProfileState>([
  TypedReducer<MyProfileState, MyProfileFailedAction>(
          updateMyProfileFailedAction)
      .call,
  TypedReducer<MyProfileState, MyProfileLoadingAction>(
          updateMyProfileLoadingActionr)
      .call,
  TypedReducer<MyProfileState, MyProfileUpdated>(myProfileUpdated).call,
  TypedReducer<MyProfileState, UpdateProfileImageUpdated>(
          updateProfileImageUpdated)
      .call,
]);
