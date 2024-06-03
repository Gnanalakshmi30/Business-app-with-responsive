import 'package:equatable/equatable.dart';



class DashboardState extends Equatable {
  final int isSuccess;
	final bool loading;
	final String error;
  final Map<String, dynamic> dashboardData;
  final String customerCurrentScreen;
  final bool menuIconClicked;
  final bool newBusiness;
  final String createSendButton;

	const DashboardState(
    this.isSuccess,
    this.loading, 
    this.error,
    this.dashboardData,
    this.customerCurrentScreen,
    this.menuIconClicked,
    this.newBusiness,
    this.createSendButton,
    )
    ;

	factory DashboardState.initial() {
    return const DashboardState(
      0,
      true, 
      '',
      {},
      'Seller',
      false,
      false,
      '',
      );
  }

  @override
  List<Object> get props => [isSuccess, error, dashboardData, customerCurrentScreen, menuIconClicked, newBusiness, createSendButton];

	@override
	bool operator ==(other) =>
		identical(this, other) ||
		other is DashboardState &&
			runtimeType == other.runtimeType &&
			loading == other.loading &&
			error == other.error;

	@override
	int get hashCode =>
		super.hashCode ^ runtimeType.hashCode ^ loading.hashCode ^ error.hashCode;

	@override
	String toString() => "DashboardState { isSuccess: $isSuccess, loading: $loading,  error: $error, dashboardData: $dashboardData, customerCurrentScreen: $customerCurrentScreen, menuIconClicked: $menuIconClicked, newBusiness: $newBusiness, createSendButton: $createSendButton}";

  DashboardState copyWith({int? isSuccess, bool? loading, String? error, Map<String, dynamic>? dashboardData, String? customerCurrentScreen, bool? menuIconClicked, bool? newBusiness, String? createSendButton}) {
    return DashboardState(
      isSuccess ?? this.isSuccess,
      loading ?? this.loading,
      error ?? this.error,
      dashboardData ?? this.dashboardData,
      customerCurrentScreen ?? this.customerCurrentScreen,
      menuIconClicked ?? this.menuIconClicked,
      newBusiness ?? this.newBusiness,
      createSendButton ?? this.createSendButton,
    );
  }
}
	  