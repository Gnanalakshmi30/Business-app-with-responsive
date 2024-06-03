import 'package:equatable/equatable.dart';


class AuthState extends Equatable{
	final bool loading;
	final String error;
  final int otp;
  final bool otpStatus;
  final int mobileNumber;
  final String customerType;
  final String firebaseToken;
  final bool isOTPVerified;
  final String contactName;
  final String email;
  final String customerCategory;
  final String state;
  final List stateList;
  final Map<String, dynamic> customerData;
  final String deviceOtp;
  final bool registerSuccess;
  final List userList;
  final bool isUserListLoaded;
  final bool userCreateLoading;
  final bool userCreateSuccess;

  // create object with status and OTP
     

	const AuthState(
    this.loading, 
    this.error, 
    this.otp, 
    this.otpStatus,
    this.mobileNumber,
    this.customerType,
    this.firebaseToken,
    this.isOTPVerified,
    this.contactName,
    this.email,
    this.customerCategory,
    this.state,
    this.stateList,
    this.customerData,
    this.deviceOtp,
    this.registerSuccess,
    this.userList,
    this.isUserListLoaded,
    this.userCreateLoading,
    this.userCreateSuccess
    );

	factory AuthState.initial() {
    return const AuthState(
      false, 
      '', 
      0,
      false,
      0,
      '',
      '',
      false,
      '',
      '',
      '',
      '',
      [],
      {},
      '',
      false,
      [],
      false,
      false,
      false
      );
  }

@override
List<Object> get props => [loading, error, otp, otpStatus, mobileNumber, customerType, firebaseToken, isOTPVerified, contactName, email, customerCategory, state, stateList, customerData, deviceOtp, registerSuccess, userList, isUserListLoaded, userCreateLoading, userCreateSuccess];
	@override
	bool operator ==(other) =>
		identical(this, other) ||
		other is AuthState &&
			runtimeType == other.runtimeType &&
			loading == other.loading &&
			error == other.error;

	@override
	int get hashCode =>
		super.hashCode ^ runtimeType.hashCode ^ loading.hashCode ^ error.hashCode;

	@override
	String toString() => "AuthState { loading: $loading,  error: $error, otp: $otp, otpStatus: $otpStatus, mobileNumber: $mobileNumber, customerType: $customerType, firebaseToken: $firebaseToken, isOTPVerified: $isOTPVerified, contactName: $contactName, email: $email, customerCategory: $customerCategory, state: $state, stateList: $stateList, customerData: $customerData, deviceOtp: $deviceOtp, registerSuccess: $registerSuccess, userList: $userList, isUserListLoaded: $isUserListLoaded, userCreateLoading: $userCreateLoading, userCreateSuccess: $userCreateSuccess}";

  AuthState copyWith({bool? loading, String? error, int? otp, bool? otpStatus, int? mobileNumber, String? customerType, String? firebaseToken, bool? isOTPVerified, String? contactName, String? email, String? customerCategory, String? state, List? stateList, Map<String, dynamic>? customerData, String? deviceOtp, bool? registerSuccess, List? userList, bool? isUserListLoaded, bool? userCreateLoading, bool? userCreateSuccess}) {
    return AuthState(
      loading ?? this.loading,
      error ?? this.error,
      otp ?? this.otp,
      otpStatus?? this.otpStatus,
      mobileNumber ?? this.mobileNumber,
      customerType ?? this.customerType,
      firebaseToken ?? this.firebaseToken,
      isOTPVerified ?? this.isOTPVerified,
      contactName ?? this.contactName,
      email ?? this.email,
      customerCategory ?? this.customerCategory,
      state ?? this.state,
      stateList ?? this.stateList,
      customerData ?? this.customerData,
      deviceOtp ?? this.deviceOtp,
      registerSuccess ?? this.registerSuccess,
      userList ?? this.userList,
      isUserListLoaded ?? this.isUserListLoaded,
      userCreateLoading ?? this.userCreateLoading,
      userCreateSuccess ?? this.userCreateSuccess
    );
  }
}


	  