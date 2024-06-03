import 'package:equatable/equatable.dart';

class PaymentsState extends Equatable {
  final bool loading;
  final String error;
  final Map paymentList;
  final List paymentListLocal;
  final int paymentListLoaded;
  final bool paymentListEndReached;
  final String paymentStatusType;
  final bool paymentCreated;
  final bool paymentCreateLoading;
  final bool paymentStatusUpdated;
  final bool paymentsStatusLoading;
  final bool disputeStatusUpdated;
  final bool editPaymentSuccess;



  const PaymentsState(
    this.loading, 
    this.error,
    this.paymentList,
    this.paymentListLoaded,
    this.paymentListLocal,
    this.paymentListEndReached,
    this.paymentStatusType,
    this.paymentCreated,
    this.paymentCreateLoading,
    this.paymentStatusUpdated,
    this.paymentsStatusLoading,
    this.disputeStatusUpdated,
    this.editPaymentSuccess,
    );

  factory PaymentsState.initial() {
    return const PaymentsState(
      false, 
      '',
      {},
      0,
      [],
      false,
      '',
      false,
      false,
      false,
      false,
      false,
      false,
      );
  }

  @override
  List<Object> get props => [loading, error, paymentList, paymentListLoaded, paymentListLocal, paymentListEndReached, paymentStatusType, paymentCreated, paymentCreateLoading, paymentStatusUpdated, paymentsStatusLoading, disputeStatusUpdated, editPaymentSuccess];

  @override
  bool operator ==(other) =>
    identical(this, other) ||
    other is PaymentsState &&
      runtimeType == other.runtimeType &&
      loading == other.loading &&
      error == other.error;

  @override
  int get hashCode =>
    super.hashCode ^ runtimeType.hashCode ^ loading.hashCode ^ error.hashCode;

  @override
  String toString() => "PaymentsState { loading: $loading,  error: $error, paymentList: $paymentList, paymentListLoaded: $paymentListLoaded, paymentListLocal: $paymentListLocal, paymentListEndReached: $paymentListEndReached, paymentStatusType: $paymentStatusType, paymentCreated: $paymentCreated, paymentCreateLoading: $paymentCreateLoading, paymentStatusUpdated: $paymentStatusUpdated, paymentsStatusLoading: $paymentsStatusLoading, disputeStatusUpdated: $disputeStatusUpdated, editPaymentSuccess: $editPaymentSuccess}";

  PaymentsState copyWith({bool? loading, String? error, Map? paymentList, int? paymentListLoaded, List? paymentListLocal, bool? paymentListEndReached, String? paymentStatusType, bool? paymentCreated, bool? paymentCreateLoading, bool? paymentStatusUpdated, bool? paymentsStatusLoading, bool? disputeStatusUpdated, bool? editPaymentSuccess}) {
    return PaymentsState(
      loading ?? this.loading,
      error ?? this.error,
      paymentList ?? this.paymentList,
      paymentListLoaded ?? this.paymentListLoaded,
      paymentListLocal ?? this.paymentListLocal,
      paymentListEndReached ?? this.paymentListEndReached,
      paymentStatusType ?? this.paymentStatusType,
      paymentCreated ?? this.paymentCreated,
      paymentCreateLoading ?? this.paymentCreateLoading,
      paymentStatusUpdated ?? this.paymentStatusUpdated,
      paymentsStatusLoading ?? this.paymentsStatusLoading,
      disputeStatusUpdated ?? this.disputeStatusUpdated,
      editPaymentSuccess ?? this.editPaymentSuccess,

    );
  }
}
