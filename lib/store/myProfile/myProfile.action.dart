import 'package:aquila_hundi/app/helper_widgets/config.dart';
import 'package:aquila_hundi/store/app.state.dart';
import 'package:aquila_hundi/store/auth/auth.action.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:shared_preferences/shared_preferences.dart';

class MyProfileAction {
  @override
  String toString() {
    return 'MyProfileAction { }';
  }
}

class MyProfileFailedAction {
  final String error;

  MyProfileFailedAction({required this.error});

  @override
  String toString() {
    return 'MyProfileFailedAction { error: $error }';
  }
}

class MyProfileLoadingAction {
  final bool loading;

  MyProfileLoadingAction({required this.loading});

  @override
  String toString() {
    return 'MyProfileLoadingAction { loading: $loading }';
  }
}

class MyProfileUpdated {
  final bool myProfileupdated;

  MyProfileUpdated({required this.myProfileupdated});

  @override
  String toString() {
    return 'MyProfileAction { myProfileupdated: $myProfileupdated }';
  }
}

class UpdateProfileImageUpdated {
  final bool profileImageUpdated;

  UpdateProfileImageUpdated({required this.profileImageUpdated});

  @override
  String toString() {
    return 'MyProfileAction { profileImageUpdated: $profileImageUpdated }';
  }
}

ThunkAction<AppState> updateMyProfileData(
    String contactName, String emailId, String mobileNum) {
  return (Store<AppState> store) async {
    store.dispatch(MyProfileLoadingAction(loading: true));
    try {
      final response = await http.post(
        Uri.parse(
            '${AppConfig.rootUrl}/APP_API/CustomerManagement/CustomerDetailsUpdate'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${store.state.authState.firebaseToken}'
        },
        body: convert.jsonEncode({
          'CustomerId': store.state.authState.customerData['_id'],
          'ContactName': contactName,
          'Mobile': mobileNum,
          'Email': emailId,
          'Device_Id': store.state.commonValuesState.deviceID,
          'Device_Type': store.state.commonValuesState.deviceType,
          'Firebase_Token': store.state.authState.firebaseToken,
        }),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            convert.jsonDecode(response.body);
        if (responseData['Status'] == true) {
          final Map<String, dynamic> successProfileData = {
            '_id': responseData['Response']['_id'],
            'ContactName': responseData['Response']['ContactName'],
            'ReferralCode': store.state.authState.customerData['ReferralCode'],
            'Referral_Unique':
                store.state.authState.customerData['Referral_Unique'],
            'Mobile': responseData['Response']['Mobile'],
            'Email': responseData['Response']['Email'],
            'State': store.state.authState.customerData['State'],
            'CustomerCategory': responseData['Response']['CustomerCategory'],
            'CustomerType': responseData['Response']['CustomerType'],
            'IfUserBusiness': responseData['Response']['IfUserBusiness'],
            'BusinessAndBranches':
                store.state.authState.customerData['BusinessAndBranches'],
            'IfUserBranch': responseData['Response']['IfUserBranch'],
            'IfBuyerUserPaymentApprove': responseData['Response']
                ['IfBuyerUserInvoiceApprove'],
            'IfBuyerUserPaymentNotify':
                store.state.authState.customerData['IfBuyerUserPaymentNotify'],
            'IfSellerUserPaymentApprove': responseData['Response']
                ['IfSellerUserPaymentApprove'],
            'IfSellerUserPaymentNotify':
                store.state.authState.customerData['IfSellerUserPaymentNotify'],
            'Firebase_Token':
                store.state.authState.customerData['Firebase_Token'],
            'Device_Id': store.state.authState.customerData['Device_Id'],
            'Device_Type': store.state.authState.customerData['Device_Type'],
            'File_Name': responseData['Response']['File_Name'],
            'LoginPin': responseData['Response']['LoginPin'],
            'Owner': store.state.authState.customerData['Owner'],
            'ActiveStatus': responseData['Response']['ActiveStatus'],
            'IfDeleted': responseData['Response']['IfDeleted'],
            'createdAt': responseData['Response']['createdAt'],
            'updatedAt': responseData['Response']['updatedAt'],
            '__v': responseData['Response']['__v'],
          };

          // store customer data in local storage
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString(
              'customerData', convert.jsonEncode(successProfileData));

          store.dispatch(UpdateCustomerData(successProfileData));

          store.dispatch(MyProfileUpdated(myProfileupdated: true));
          store.dispatch(MyProfileLoadingAction(loading: false));
        } else {
          store.dispatch(MyProfileFailedAction(error: responseData['Message']));
          store.dispatch(MyProfileLoadingAction(loading: false));
        }
      } else {
        store.dispatch(MyProfileFailedAction(
            error: 'Failed to update profile information'));
        store.dispatch(MyProfileLoadingAction(loading: false));
      }
    } catch (error) {
      store.dispatch(
          MyProfileFailedAction(error: 'Failed to update profile information'));
      store.dispatch(MyProfileLoadingAction(loading: false));
    }
  };
}

ThunkAction<AppState> updateProfileImage(image) {
  return (Store<AppState> store) async {
    store.dispatch(MyProfileLoadingAction(loading: true));
    try {
      final response = await http.post(
        Uri.parse(
            '${AppConfig.rootUrl}/APP_API/CustomerManagement/CustomerProfileUpload'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${store.state.authState.firebaseToken}'
        },
        body: convert.jsonEncode({
          'CustomerId': store.state.authState.customerData['_id'],
          'File_Name': image,
        }),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            convert.jsonDecode(response.body);
        print('responseData image upload: $responseData');
        if (responseData['Status'] == true) {
          store.dispatch(UpdateProfileImageUpdated(profileImageUpdated: true));
          store.dispatch(MyProfileLoadingAction(loading: false));
          store.dispatch(UpdateCustomerData(
            // only change File_Name in customer data
            {
              ...store.state.authState.customerData,
              'File_Name': '',
            },
          ));
          store.dispatch(UpdateCustomerData(
            // only change File_Name in customer data
            {
              ...store.state.authState.customerData,
              'File_Name': responseData['Response']['File_Name'],
            },
          ));
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString(
              'customerData',
              convert.jsonEncode({
                ...store.state.authState.customerData,
                'File_Name': '',
              }));
          prefs.setString(
              'customerData',
              convert.jsonEncode({
                ...store.state.authState.customerData,
                'File_Name': responseData['Response']['File_Name'],
              }));
          //store.dispatch(getCustomerDetails);
        } else {
          store.dispatch(MyProfileFailedAction(error: responseData['Message']));
          store.dispatch(MyProfileLoadingAction(loading: false));
        }
      } else {
        store.dispatch(MyProfileFailedAction(
            error: 'Failed to update profile image information'));
        store.dispatch(MyProfileLoadingAction(loading: false));
      }
    } catch (error) {
      store.dispatch(MyProfileFailedAction(
          error: 'Failed to update profile image information'));
      store.dispatch(MyProfileLoadingAction(loading: false));
    }
  };
}

ThunkAction<AppState> deleteProfileImage = (Store<AppState> store) async {
  store.dispatch(MyProfileLoadingAction(loading: true));
  try {
    final response = await http.post(
      Uri.parse(
          '${AppConfig.rootUrl}/APP_API/CustomerManagement/CustomerProfileDelete'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${store.state.authState.firebaseToken}'
      },
      body: convert.jsonEncode({
        'CustomerId': store.state.authState.customerData['_id'],
      }),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData =
          convert.jsonDecode(response.body);
      if (responseData['Status'] == true) {
        store.dispatch(UpdateProfileImageUpdated(profileImageUpdated: true));
        store.dispatch(MyProfileLoadingAction(loading: false));
        store.dispatch(UpdateCustomerData(
          // only change File_Name in customer data
          {
            ...store.state.authState.customerData,
            'File_Name': '',
          },
        ));
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString(
            'customerData',
            convert.jsonEncode({
              ...store.state.authState.customerData,
              'File_Name': '',
            }));
      } else {
        store.dispatch(MyProfileFailedAction(error: responseData['Message']));
        store.dispatch(MyProfileLoadingAction(loading: false));
      }
    } else {
      store.dispatch(MyProfileFailedAction(
          error: 'Failed to delete profile image information'));
      store.dispatch(MyProfileLoadingAction(loading: false));
    }
  } catch (error) {
    store.dispatch(MyProfileFailedAction(
        error: 'Failed to delete profile image information'));
    store.dispatch(MyProfileLoadingAction(loading: false));
  }
};

ThunkAction<AppState> switchtoBothBuyerAndSeller() {
  return (Store<AppState> store) async {
    store.dispatch(MyProfileLoadingAction(loading: true));
    try {
      final response = await http.post(
        Uri.parse(
            '${AppConfig.rootUrl}/APP_API/CustomerManagement/SwitchTo_BothBuyerAndSeller'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${store.state.authState.firebaseToken}'
        },
        body: convert.jsonEncode({
          'CustomerId': store.state.authState.customerData['_id'],
          'CustomerCategory': "BothBuyerAndSeller",
        }),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            convert.jsonDecode(response.body);
        if (responseData['Status'] == true) {
          final Map<String, dynamic> successProfileData = {
            '_id': responseData['Response']['_id'],
            'ContactName': responseData['Response']['ContactName'],
            'ReferralCode': responseData['Response']['ReferralCode'],
            'Referral_Unique': responseData['Response']['Referral_Unique'],
            'Mobile': responseData['Response']['Mobile'],
            'Email': responseData['Response']['Email'],
            'State': responseData['Response']['State'],
            'CustomerCategory': responseData['Response']['CustomerCategory'],
            'CustomerType': responseData['Response']['CustomerType'],
            'IfUserBusiness': responseData['Response']['IfUserBusiness'],
            'BusinessAndBranches': responseData['Response']
                ['BusinessAndBranches'],
            'IfUserBranch': responseData['Response']['IfUserBranch'],
            'IfBuyerUserPaymentApprove': responseData['Response']
                ['IfBuyerUserPaymentApprove'],
            'IfBuyerUserPaymentNotify':
                store.state.authState.customerData['IfBuyerUserPaymentNotify'],
            'IfSellerUserPaymentApprove': responseData['Response']
                ['IfSellerUserPaymentApprove'],
            'IfSellerUserPaymentNotify':
                store.state.authState.customerData['IfSellerUserPaymentNotify'],
            'Firebase_Token':
                store.state.authState.customerData['Firebase_Token'],
            'Device_Id': store.state.authState.customerData['Device_Id'],
            'Device_Type': store.state.authState.customerData['Device_Type'],
            'File_Name': store.state.authState.customerData['File_Name'],
            'LoginPin': responseData['Response']['LoginPin'],
            'Owner': responseData['Response']['Owner'],
            'ActiveStatus': responseData['Response']['ActiveStatus'],
            'IfDeleted': responseData['Response']['IfDeleted'],
            'createdAt': responseData['Response']['createdAt'],
            'updatedAt': responseData['Response']['updatedAt'],
            '__v': responseData['Response']['__v'],
          };

          // store customer data in local storage
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString(
              'customerData', convert.jsonEncode(successProfileData));

          store.dispatch(UpdateCustomerData(successProfileData));

          store.dispatch(MyProfileUpdated(myProfileupdated: true));
          store.dispatch(MyProfileLoadingAction(loading: false));
        } else {
          store.dispatch(MyProfileFailedAction(error: responseData['Message']));
          store.dispatch(MyProfileLoadingAction(loading: false));
        }
      } else {
        store.dispatch(MyProfileFailedAction(
            error: 'Failed to update profile information'));
        store.dispatch(MyProfileLoadingAction(loading: false));
      }
    } catch (error) {
      store.dispatch(
          MyProfileFailedAction(error: 'Failed to update profile information'));
      store.dispatch(MyProfileLoadingAction(loading: false));
    }
  };
}
