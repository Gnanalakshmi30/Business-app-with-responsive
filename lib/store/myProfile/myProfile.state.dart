import 'package:equatable/equatable.dart';

class MyProfileState extends Equatable {
  final bool loading;
  final String error;
  

  final bool myProfileupdated;
  final bool profileImageUpdated;

  const MyProfileState(
    this.loading,
    this.error,
    this.myProfileupdated,
    this.profileImageUpdated,
  );

  factory MyProfileState.initial() {
    return const MyProfileState(
      false,
      '',
      false,
      false,
    );
  }

  @override
  List<Object> get props => [loading, error, myProfileupdated, profileImageUpdated];

  @override
  bool operator ==(other) =>
      identical(this, other) ||
      other is MyProfileState &&
          runtimeType == other.runtimeType &&
          loading == other.loading &&
          error == other.error;

  @override
  int get hashCode =>
      super.hashCode ^ runtimeType.hashCode ^ loading.hashCode ^ error.hashCode;

  @override
  String toString() =>
      "MyProfileState { loading: $loading,  error: $error, myProfileupdated: $myProfileupdated, profileImageUpdated: $profileImageUpdated}";

  MyProfileState copyWith({
    bool? loading,
    String? error,
    int? myProfile,
    bool? myProfileupdated,
    bool? profileImageUpdated,
  }) {
    return MyProfileState(
      loading ?? this.loading,
      error ?? this.error,
      myProfileupdated ?? this.myProfileupdated,
      profileImageUpdated ?? this.profileImageUpdated,
    );
  }
}
