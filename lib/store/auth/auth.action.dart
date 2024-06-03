
// ignore_for_file: avoid_print
import 'package:aquila_hundi/app/helper_widgets/config.dart';
import 'package:aquila_hundi/main.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:aquila_hundi/store/app.state.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:shared_preferences/shared_preferences.dart';





class AuthAction {

	@override
	String toString() {
	return 'AuthAction { }';
	}
}

class AuthSuccessAction {
	final bool loading;

	AuthSuccessAction({required this.loading});
	@override
	String toString() {
	return 'AuthSuccessAction { isSuccess: $loading }';
	}
}

class AuthFailedAction {
	final String error;

	AuthFailedAction({required this.error});

	@override
	String toString() {
	return 'AuthFailedAction { error: $error }';
	}
}
	
class UpdateOTPAction {
  final int otp;
  UpdateOTPAction(this.otp);

  @override
  String toString() {
  return 'UpdateOTP { otp: $otp }';
  }
}

ThunkAction<AppState> updateOTP(String mobileNumber) {
  print('mobileNumber from thunk: $mobileNumber');
  return (Store<AppState> store) async {
    try {
      var otpResponse = await getOTP(mobileNumber);
      print('otpResponse: $otpResponse');
      var otpStatus = otpResponse['SuccessStatus'];
      if (otpStatus == true) {

      var otp = otpResponse['OTP'];
      // convert mobileNumber to int
      var mobileNumberInt = int.parse(mobileNumber);

      store.dispatch(UpdateMobileNumberAction(mobileNumberInt));
      store.dispatch(UpdateOTPAction(otp));
      store.dispatch(AuthOtpStatusAction(otpStatus: true));
      store.dispatch(UpdateCustomerTypeAction(otpResponse['CustomerType']));
      store.dispatch(AuthSuccessAction(loading: false));
      } else {
        store.dispatch(AuthFailedAction(error: otpResponse['Message']));
        store.dispatch(AuthSuccessAction(loading: false));
      }
    } catch (error) {
      print('Error from updateOTP: $error');
    }
  };

  
}



Future getOTP(String mobileNumber) async {
  print('mobileNumber from getOTP: $mobileNumber');
  var url = '${AppConfig.rootUrl}/APP_API/CommonManagement/GenerateOTP';
  
  var response = await http.post (
    Uri.parse(url),
    body: {
      'Mobile': mobileNumber,
    }
  );
  print('response from getOTP: $response');

  
  final Map<String, dynamic> result = convert.jsonDecode(response.body);
  print('result from getOTP: $result');
  if (result['Status'] == true) {
    return result;
  }
  throw Exception('Failed to get OTP');
  }


class AuthOtpStatusAction {
  final bool otpStatus;
  AuthOtpStatusAction({required this.otpStatus});

  @override
  String toString() {
  return 'AuthOtpStatusAction { otpStatus: $otpStatus }';
  }
}


class UpdateMobileNumberAction {
  final int mobileNumber;
  UpdateMobileNumberAction(this.mobileNumber);

  @override
  String toString() {
  return 'UpdateMobileNumberAction { mobileNumber: $mobileNumber }';
  }
}

class UpdateCustomerTypeAction {
  final String customerType;
  UpdateCustomerTypeAction(this.customerType);

  @override
  String toString() {
  return 'UpdateCustomerTypeAction { customerType: $customerType }';
  }
}

Future logoutDevices(String mobileNumber) async {
  var url = '${AppConfig.rootUrl}/APP_API/CommonManagement/LogOut';
  
  var response = await http.post (
    Uri.parse(url),
    body: {
      'Mobile': mobileNumber,
    }
  );
  
  final Map<String, dynamic> result = convert.jsonDecode(response.body);
  if (result['Status'] == true) {
    return result;
  }
  throw Exception('Failed to logout');
  }

  ThunkAction<AppState> logout(String mobileNumber) {
    print('working here at logout');
  return (Store<AppState> store) async {
    try {
      var logoutResponse = await logoutDevices(mobileNumber);
      var logoutStatus = logoutResponse['Status'];
      if (logoutStatus == true) {
        store.dispatch(AuthOtpStatusAction(otpStatus: false));
        store.dispatch(AuthSuccessAction(loading: false));
        store.dispatch(AuthFailedAction(error: ''));
        store.dispatch(UpdateOwnerDetails('', '', '', ''));
        store.dispatch(UpdateOTPVerifiedAction(false));
        store.dispatch(UpdateDeviceOTP(''));
        // remove data from device storage
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.remove('customerData');
        // remove deviceOtp from device storage
        prefs.remove('deviceOtp');
        
        
      } else {
        store.dispatch(AuthFailedAction(error: logoutResponse['Message']));
        print('Error from logout: ${logoutResponse['Message']}');
      }
    } catch (error) {
      print('Error from logout: $error');
    }
  };
}

class UpdateFirebaseTokenAction {
  final String firebaseToken;
  UpdateFirebaseTokenAction(this.firebaseToken);

  @override
  String toString() {
  return 'UpdateFirebaseTokenAction { firebaseToken: $firebaseToken }';
  }
}

Future verifyOTPServer(String mobileNumber, int otp) async {
  var url = '${AppConfig.rootUrl}/APP_API/CommonManagement/VerifyOTP';
  // get deviceId from store
  var deviceID = store.state.commonValuesState.deviceID;
  var deviceType = store.state.commonValuesState.deviceType;
  
  var response = await http.post (
    Uri.parse(url),
    body: {
      'Mobile': mobileNumber,
      'OTP': otp.toString(),
      'Device_Id': deviceID,
      'Device_Type': deviceType,
    }
  );

  final Map<String, dynamic> result = convert.jsonDecode(response.body);
  if (result['Status'] == true) {
    return result;
  }
  throw Exception('Failed to verify OTP');
  }

  ThunkAction<AppState> verifyOtp(String mobileNumber, int otp) {
  return (Store<AppState> store) async {
    try {
      var verifyOtpResponse = await verifyOTPServer(mobileNumber, otp);
      bool verifyOtpStatus = verifyOtpResponse['SuccessStatus'];
      final Map<String, dynamic> data = verifyOtpStatus ? verifyOtpResponse['Response'] : {};
      print('data from verifyOtp: $data');


      if (verifyOtpStatus == true) {
        final String firebaseToken = data['Firebase_Token'];
        store.dispatch(AuthOtpStatusAction(otpStatus: false));
        store.dispatch(AuthSuccessAction(loading: false));
        store.dispatch(AuthFailedAction(error: ''));
        // store firebase token
        store.dispatch(UpdateFirebaseTokenAction(firebaseToken));
        store.dispatch(UpdateOTPVerifiedAction(true));
        // store data in device storage
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('customerData', convert.jsonEncode(data));
        store.dispatch(UpdateCustomerData(data));
        
      } else {
        store.dispatch(AuthFailedAction(error: verifyOtpResponse['Message']));
        store.dispatch(AuthOtpStatusAction(otpStatus: true));
        store.dispatch(AuthSuccessAction(loading: false));
      }
    } catch (error) {
      print('Error from verifyOtp whole: $error');
    }
  };
}

class UpdateOTPVerifiedAction {
  final bool isOTPVerified;
  UpdateOTPVerifiedAction(this.isOTPVerified);

  @override
  String toString() {
  return 'updateOTPVerifiedAction { isOTPVerified: $isOTPVerified }';
  }
}

Future<void> registerUserServer( String contactName, String email, String customerCategory, String state, ) async {
  print('contactName: $contactName, email: $email, customerCategory: $customerCategory, state: $state');
  var url = '${AppConfig.rootUrl}/APP_API/CustomerManagement/OwnerRegisterMobile';
  var response = await http.post (
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer ${store.state.authState.firebaseToken}',
    },
    body: {
      'id': store.state.authState.customerData['_id'],
      'ContactName': contactName,
      'Email': email,
      'State': state,
      'CustomerCategory': customerCategory,
    }
  );

  final Map<String, dynamic> result = convert.jsonDecode(response.body);
  if (result['Status'] == true) {
    print('result: $result');
    store.dispatch(AuthSuccessAction(loading: false));
    store.dispatch(UpdateCustomerData(result['Response']));
    store.dispatch(UpdateRegisterSuccess(true));
    // store data in device storage
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('customerData', convert.jsonEncode(result['Response']));
  } else {
    throw Exception('Failed to register');
  }
  
}

class UpdateOwnerDetails {
  final String contactName;
  final String email;
  final String customerCategory;
  final String state;
  UpdateOwnerDetails(this.contactName, this.email, this.customerCategory, this.state);

  @override
  String toString() {
  return 'UpdateOwnerDetails { contactName: $contactName, email: $email, customerCategory: $customerCategory, state: $state }';
  }
}

class UpdateStateList {
  final List stateList;
  UpdateStateList(this.stateList);

  @override
  String toString() {
  return 'UpdateStateList { stateList: $stateList }';
  }
}

Future<void> getStateListServer() async {
  var url = '${AppConfig.rootUrl}/APP_API/CustomerManagement/StateListMobile';
  var response = await http.get (
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer ${store.state.authState.firebaseToken}',
    }
  );

  final Map<String, dynamic> result = convert.jsonDecode(response.body);
  if (result['Status'] == true) {
    store.dispatch(UpdateStateList(result['Response']));
  } else {
    throw Exception('Failed to get state list');
  }
}

class UpdateCustomerData {
  final Map<String, dynamic> customerData;
  UpdateCustomerData(this.customerData);

  @override
  String toString() {
  return 'UpdateCustomerData { customerData: $customerData }';
  }
}

class UpdateDeviceOTP {
  final String deviceOtp;
  UpdateDeviceOTP(this.deviceOtp);

  @override
  String toString() {
  return 'UpdateDeviceOTP { deviceOtp: $deviceOtp }';
  }
}

class UpdateRegisterSuccess {
  final bool registerSuccess;
  UpdateRegisterSuccess(this.registerSuccess);

  @override
  String toString() {
  return 'UpdateRegisterSuccess { registerSuccess: $registerSuccess }';
  }
}

class UpdateUserList {
  final List userList;
  UpdateUserList(this.userList);

  @override
  String toString() {
  return 'UpdateUserList { userList: $userList }';
  }
}

class UpdateUserListLoaded {
  final bool isUserListLoaded;
  UpdateUserListLoaded(this.isUserListLoaded);

  @override
  String toString() {
  return 'UpdateUserListLoaded { isUserListLoaded: $isUserListLoaded }';
  }
}

Future<void> getUserListServer() async {
  store.dispatch(AuthSuccessAction(loading: true));
  var url = '${AppConfig.rootUrl}/APP_API/CustomerManagement/OwnerAgainstUserList';
  var response = await http.post (
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer ${store.state.authState.firebaseToken}',
    },
    body: {
      'CustomerId': store.state.authState.customerData['_id'],
      'CustomerCategory': store.state.dashboardState.customerCurrentScreen,
    }
  );

  final Map<String, dynamic> result = convert.jsonDecode(response.body);
  print('result from getUserListServer: $result');
  if (response.statusCode == 200) {
    if (result['Status'] == true) {
      store.dispatch(UpdateUserList(result['Response']));
      store.dispatch(UpdateUserListLoaded(true));
      store.dispatch(AuthSuccessAction(loading: false));
    } else {
      store.dispatch(AuthFailedAction(error: result['Message']));
      store.dispatch(AuthSuccessAction(loading: false));
    }
  } else {
    store.dispatch(AuthFailedAction(error: 'Failed to get user list'));
    store.dispatch(AuthSuccessAction(loading: false));
  }
}

class UpdateUserCreateLoading {
  final bool userCreateLoading;
  UpdateUserCreateLoading(this.userCreateLoading);

  @override
  String toString() {
  return 'UpdateUserCreateLoading { userCreateLoading: $userCreateLoading }';
  }
}

class UpdateUserCreateSuccess {
  final bool userCreateSuccess;
  UpdateUserCreateSuccess(this.userCreateSuccess);

  @override
  String toString() {
  return 'UpdateUserCreateSuccess { userCreateSuccess: $userCreateSuccess }';
  }
}

Future<void> createUserServer(Map data) async {
  print('businesses from createUserServer: $data');
  store.dispatch(UpdateUserCreateLoading(true));
  var url = '${AppConfig.rootUrl}/APP_API/CustomerManagement/User_Create';
  var response = await http.post (
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ${store.state.authState.firebaseToken}',
    },
    body: convert.jsonEncode({
      'Owner': store.state.authState.customerData['_id'],
      'CustomerCategory': store.state.dashboardState.customerCurrentScreen,
      'ContactName': data['contactName'],
      'Mobile': data['mobile'],
      'BusinessAndBranches': data['businesses'],
    })
  );

  final result = convert.jsonDecode(response.body);
  if (response.statusCode == 200) {
    print('working at createUserServer');
    if (result['Status'] == true) {
      store.dispatch(UpdateUserCreateSuccess(true));
      store.dispatch(UpdateUserCreateLoading(false));
      store.dispatch(AuthSuccessAction(loading: false));
      store.dispatch(getUserListServer());
    } else {
      store.dispatch(AuthFailedAction(error: result['Message']));
      store.dispatch(UpdateUserCreateLoading(false));
      store.dispatch(AuthSuccessAction(loading: false));
    }
  } else {
    store.dispatch(AuthFailedAction(error: 'Failed to create user'));
    store.dispatch(UpdateUserCreateLoading(false));
    store.dispatch(AuthSuccessAction(loading: false));
  }
}

Future<void> editUserServer(Map data) async {
  print('businesses from editUserServer: $data');
  store.dispatch(UpdateUserCreateLoading(true));
  var url = '${AppConfig.rootUrl}/APP_API/CustomerManagement/UserUpdated';
  var response = await http.post (
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ${store.state.authState.firebaseToken}',
    },
    body: convert.jsonEncode({
      'BusinessAndBranches': data['businesses'],
      'UserId': data['userId'],
    })
  );

  final result = convert.jsonDecode(response.body);
  print('result from editUserServer: ${result}');
  if (response.statusCode == 200) {
    print('working at editUserServer');
    if (result['Status'] == true) {
      store.dispatch(UpdateUserCreateSuccess(true));
      store.dispatch(UpdateUserCreateLoading(false));
      store.dispatch(AuthSuccessAction(loading: false));
      store.dispatch(getUserListServer());
    } else {
      store.dispatch(AuthFailedAction(error: result['Message']));
      store.dispatch(UpdateUserCreateLoading(false));
      store.dispatch(AuthSuccessAction(loading: false));
    }
  } else {
    store.dispatch(AuthFailedAction(error: 'Failed to edit user'));
    store.dispatch(UpdateUserCreateLoading(false));
    store.dispatch(AuthSuccessAction(loading: false));
  }
}




