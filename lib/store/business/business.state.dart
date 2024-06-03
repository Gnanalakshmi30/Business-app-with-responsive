import 'package:equatable/equatable.dart';



class BusinessState extends Equatable {
	final bool loading;
	final String error;
  final Map<String, dynamic> industryList;
  final bool businessAddStatus;
  final int isSuccess;
  final List myBusinessList;
  final int businessListLoaded;
  final List myBusinessListLocal;
  final bool businessEditStatus;
  final List sellerBusinessCustomerList;
  final List customerBusinessList;

	const BusinessState(
    this.loading, 
    this.error,
    this.industryList,
    this.businessAddStatus,
    this.isSuccess,
    this.myBusinessList,
    this.businessListLoaded,
    this.myBusinessListLocal,
    this.businessEditStatus,
    this.sellerBusinessCustomerList,
    this.customerBusinessList,
    );

	factory BusinessState.initial() {
    return const BusinessState(
      true, 
      '',
      {},
      false,
      0,
      [],
      0,
      [],
      false,
      [],
      [],
      );
  }

  @override
  List<Object> get props => [loading, error, industryList, businessAddStatus, isSuccess, myBusinessList, businessListLoaded, myBusinessListLocal, businessEditStatus, sellerBusinessCustomerList, customerBusinessList];

	@override
	bool operator ==(other) =>
		identical(this, other) ||
		other is BusinessState &&
			runtimeType == other.runtimeType &&
			loading == other.loading &&
			error == other.error;

	@override
	int get hashCode =>
		super.hashCode ^ runtimeType.hashCode ^ loading.hashCode ^ error.hashCode;

	@override
	String toString() => "BusinessState { loading: $loading,  error: $error, industryList: $industryList, businessAddStatus: $businessAddStatus, isSuccess: $isSuccess, myBusinessList: $myBusinessList, businessListLoaded: $businessListLoaded, myBusinessListLocal: $myBusinessListLocal, businessEditStatus: $businessEditStatus, sellerBusinessCustomerList: $sellerBusinessCustomerList, customerBusinessList: $customerBusinessList}";

  BusinessState copyWith({bool? loading, String? error, Map<String, dynamic>? industryList, bool? businessAddStatus, int? isSuccess, List? myBusinessList, int? businessListLoaded, List? myBusinessListLocal, bool? businessEditStatus, List? sellerBusinessCustomerList, List? customerBusinessList}){
    return BusinessState(
      loading ?? this.loading,
      error ?? this.error,
      industryList ?? this.industryList,
      businessAddStatus ?? this.businessAddStatus,
      isSuccess ?? this.isSuccess,
      myBusinessList ?? this.myBusinessList,
      businessListLoaded ?? this.businessListLoaded,
      myBusinessListLocal ?? this.myBusinessListLocal,
      businessEditStatus ?? this.businessEditStatus,
      sellerBusinessCustomerList ?? this.sellerBusinessCustomerList,
      customerBusinessList ?? this.customerBusinessList,
    );
  }
}
	  