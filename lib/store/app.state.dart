import 'package:aquila_hundi/store/myProfile/myProfile.state.dart';
import 'package:aquila_hundi/store/support/support.state.dart';

import './payments/payments.state.dart';
import './invoice/invoice.state.dart';
import './invite/invite.state.dart';
import './business/business.state.dart';
import './dashboard/dashboard.state.dart';
import 'package:equatable/equatable.dart';
import 'package:aquila_hundi/store/commonValues/commonvalues.state.dart';
import 'package:aquila_hundi/store/auth/auth.state.dart';

class AppState extends Equatable {
  final PaymentsState paymentsState;
  final InvoiceState invoiceState;
  final InviteState inviteState;
  final BusinessState businessState;
  final DashboardState dashboardState;
  final CommonValuesState commonValuesState;
  final AuthState authState;
  final SupportState supportState;
  final MyProfileState myProfileState;

  const AppState(
      {required this.paymentsState,
      required this.invoiceState,
      required this.inviteState,
      required this.businessState,
      required this.dashboardState,
      required this.commonValuesState,
      required this.authState,
      required this.supportState,
      required this.myProfileState});

  factory AppState.initial() => AppState(
      paymentsState: PaymentsState.initial(),
      invoiceState: InvoiceState.initial(),
      inviteState: InviteState.initial(),
      businessState: BusinessState.initial(),
      dashboardState: DashboardState.initial(),
      commonValuesState: CommonValuesState.initial(),
      authState: AuthState.initial(),
      supportState: SupportState.initial(),
      myProfileState: MyProfileState.initial());

  @override
  List<Object> get props => [
        commonValuesState,
        authState,
        dashboardState,
        businessState,
        inviteState,
        invoiceState,
        paymentsState,
        supportState,
        myProfileState
      ];

  @override
  bool operator ==(other) =>
      identical(this, other) ||
      other is AppState &&
          runtimeType == other.runtimeType &&
          paymentsState == other.paymentsState &&
          invoiceState == other.invoiceState &&
          inviteState == other.inviteState &&
          businessState == other.businessState &&
          dashboardState == other.dashboardState &&
          commonValuesState == other.commonValuesState &&
          authState == other.authState &&
          authState == other.authState &&
          supportState == other.supportState &&
          myProfileState == other.myProfileState;

  @override
  int get hashCode =>
      super.hashCode ^
      paymentsState.hashCode ^
      invoiceState.hashCode ^
      inviteState.hashCode ^
      businessState.hashCode ^
      dashboardState.hashCode ^
      commonValuesState.hashCode ^
      authState.hashCode ^
      authState.hashCode ^
      supportState.hashCode ^
      myProfileState.hashCode;

  @override
  String toString() {
    return "AppState { paymentsState: $paymentsState invoiceState: $invoiceState inviteState: $inviteState businessState: $businessState dashboardState: $dashboardState commonValuesState: $commonValuesState authState: $authState authState: $authState  supportState: $supportState myProfileState: $myProfileState}";
  }

  AppState copyWith(
      {CommonValuesState? commonValuesState,
      AuthState? authState,
      DashboardState? dashboardState,
      BusinessState? businessState,
      InviteState? inviteState,
      InvoiceState? invoiceState,
      PaymentsState? paymentsState,
      SupportState? supportState,
      MyProfileState? myProfileState}) {
    return AppState(
        commonValuesState: commonValuesState ?? this.commonValuesState,
        authState: authState ?? this.authState,
        dashboardState: dashboardState ?? this.dashboardState,
        businessState: businessState ?? this.businessState,
        inviteState: inviteState ?? this.inviteState,
        invoiceState: invoiceState ?? this.invoiceState,
        paymentsState: paymentsState ?? this.paymentsState,
        supportState: supportState ?? this.supportState,
        myProfileState: myProfileState ?? this.myProfileState);
  }
}
