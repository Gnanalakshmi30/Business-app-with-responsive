import 'package:aquila_hundi/store/myProfile/myProfile.reducer.dart';
import 'package:aquila_hundi/store/support/support.reducer.dart';
import './payments/payments.reducer.dart';
import './invoice/invoice.reducer.dart';
import './invite/invite.reducer.dart';
import './business/business.reducer.dart';
import './dashboard/dashboard.reducer.dart';
import 'package:aquila_hundi/store/commonValues/commonvalues.reducer.dart';
import 'package:aquila_hundi/store/auth/auth.reducer.dart';
import 'package:aquila_hundi/store/app.state.dart';

AppState appReducer(AppState state, dynamic action) {
  return AppState(
    supportState: supportReducer(state.supportState, action),
    paymentsState: paymentsReducer(state.paymentsState, action),
    invoiceState: invoiceReducer(state.invoiceState, action),
    inviteState: inviteReducer(state.inviteState, action),
    businessState: businessReducer(state.businessState, action),
    dashboardState: dashboardReducer(state.dashboardState, action),
    authState: authReducer(state.authState, action),
    commonValuesState: commonValuesReducer(state.commonValuesState, action),
    myProfileState: myProfileReducer(state.myProfileState, action),
  );
}
