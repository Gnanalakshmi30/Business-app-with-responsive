import 'package:equatable/equatable.dart';



class InviteState extends Equatable {
	final bool loading;
	final String error;
  final List acceptedList;
  final bool inviteListLoaded;
  final List inviteListLocal;
  final bool editCreditLoading;
  final String editCreditError;
  final bool editCreditSuccess;
  final bool inviteBuyerSuccess;
  final List inviteHistoryList;
  final bool inviteHistoryListLoaded;
  final bool mobileNumberVerified;
  final Map customerFromMobileNumber;
  final bool editRequestFromInvoice;
  final String editRequestBuyerId;

	const InviteState(
    this.loading, 
    this.error,
    this.acceptedList,
    this.inviteListLoaded,
    this.inviteListLocal,
    this.editCreditLoading,
    this.editCreditError,
    this.editCreditSuccess,
    this.inviteBuyerSuccess,
    this.inviteHistoryList,
    this.inviteHistoryListLoaded,
    this.mobileNumberVerified,
    this.customerFromMobileNumber,
    this.editRequestFromInvoice,
    this.editRequestBuyerId,
    );

	factory InviteState.initial() {
    return const InviteState(
      true,
      '',
      [],
      false,
      [],
      false,
      '',
      false,
      false,
      [],
      false,
      false,
      {},
      false,
      '',
    );
  }

	@override
  List<Object> get props => [loading, error, acceptedList, inviteListLoaded, inviteListLocal, editCreditLoading, editCreditError, editCreditSuccess, inviteBuyerSuccess, inviteHistoryList, inviteHistoryListLoaded, mobileNumberVerified, customerFromMobileNumber, editRequestFromInvoice, editRequestBuyerId];

	@override
	bool operator ==(other) =>
		identical(this, other) ||
		other is InviteState &&
			runtimeType == other.runtimeType &&
			loading == other.loading &&
			error == other.error;

	@override
	int get hashCode =>
		super.hashCode ^ runtimeType.hashCode ^ loading.hashCode ^ error.hashCode;

	@override
	String toString() => "InviteState { loading: $loading,  error: $error, acceptedList: $acceptedList, inviteListLoaded: $inviteListLoaded, inviteListLocal: $inviteListLocal, editCreditLoading: $editCreditLoading, editCreditError: $editCreditError, editCreditSuccess: $editCreditSuccess, inviteBuyerSuccess: $inviteBuyerSuccess, inviteHistoryList: $inviteHistoryList, inviteHistoryListLoaded: $inviteHistoryListLoaded, mobileNumberVerified: $mobileNumberVerified, customerFromMobileNumber: $customerFromMobileNumber, editRequestFromInvoice: $editRequestFromInvoice, editRequestBuyerId: $editRequestBuyerId}";

  InviteState copyWith({bool? loading, String? error, List? acceptedList, bool? inviteListLoaded, List? inviteListLocal, bool? editCreditLoading, String? editCreditError, bool? editCreditSuccess, bool? inviteBuyerSuccess, List? inviteHistoryList, bool? inviteHistoryListLoaded, bool? mobileNumberVerified, Map? customerFromMobileNumber,  bool? editRequestFromInvoice, String? editRequestBuyerId}) {
    return InviteState(
      loading ?? this.loading,
      error ?? this.error,
      acceptedList ?? this.acceptedList,
      inviteListLoaded ?? this.inviteListLoaded,
      inviteListLocal ?? this.inviteListLocal,
      editCreditLoading ?? this.editCreditLoading,
      editCreditError ?? this.editCreditError,
      editCreditSuccess ?? this.editCreditSuccess,
      inviteBuyerSuccess ?? this.inviteBuyerSuccess,
      inviteHistoryList ?? this.inviteHistoryList,
      inviteHistoryListLoaded ?? this.inviteHistoryListLoaded,
      mobileNumberVerified ?? this.mobileNumberVerified,
      customerFromMobileNumber ?? this.customerFromMobileNumber,
      editRequestFromInvoice ?? this.editRequestFromInvoice,
      editRequestBuyerId ?? this.editRequestBuyerId,
    );
  }
}
	  