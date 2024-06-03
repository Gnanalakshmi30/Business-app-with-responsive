import 'package:equatable/equatable.dart';


class CommonValuesState extends Equatable{
	final bool loading;
	final String error;
  final String deviceID;
  final String deviceType;
  final double screenWidth;
  final double screenHeight;
  final String firebaseToken;
  final int selectedBottomNavIndex;
  final List notificationsList;
  final bool notificationsListLoaded;

  const CommonValuesState({
    required this.loading, 
    required this.error, 
    this.deviceID = '',
    this.deviceType = '',
    this.screenWidth = 0,
    this.screenHeight = 0,  
    this.firebaseToken = '',
    this.selectedBottomNavIndex = 2,
    this.notificationsList = const [],
    this.notificationsListLoaded = false,
    });
factory CommonValuesState.initial() {
  return const CommonValuesState(
    loading: false,
    error: '',
    deviceID: '',
    deviceType: '',
    screenWidth: 0,
    screenHeight: 0,
    firebaseToken: '',
    selectedBottomNavIndex: 2,
    notificationsList: [],
    notificationsListLoaded: false,
  );
}

@override
List<Object> get props => [loading, error, deviceID, deviceType, screenWidth, screenHeight, firebaseToken, selectedBottomNavIndex];
	@override
	bool operator ==(other) =>
		identical(this, other) ||
		other is CommonValuesState &&
			runtimeType == other.runtimeType &&
			loading == other.loading &&
			error == other.error;

	@override
	int get hashCode =>
		super.hashCode ^ runtimeType.hashCode ^ loading.hashCode ^ error.hashCode;

	@override
	String toString() => "CommonValuesState { loading: $loading,  error: $error, deviceID: $deviceID, deviceType: $deviceType, screenWidth: $screenWidth, screenHeight: $screenHeight, firebaseToken: $firebaseToken, selectedBottomNavIndex: $selectedBottomNavIndex, notificationsList: $notificationsList, notificationsListLoaded: $notificationsListLoaded}";

  CommonValuesState copyWith({bool? loading, String? error, String? deviceID, String? deviceType, double? screenWidth, double? screenHeight, String? firebaseToken, int? selectedBottomNavIndex, List? notificationsList, bool? notificationsListLoaded}) {
    return CommonValuesState(
      loading: loading ?? this.loading,
      error: error ?? this.error,
      deviceID: deviceID ?? this.deviceID,
      deviceType: deviceType ?? this.deviceType,
      screenWidth: screenWidth ?? this.screenWidth,
      screenHeight: screenHeight ?? this.screenHeight,
      firebaseToken: firebaseToken ?? this.firebaseToken,
      selectedBottomNavIndex: selectedBottomNavIndex ?? this.selectedBottomNavIndex,
      notificationsList: notificationsList ?? this.notificationsList,
      notificationsListLoaded: notificationsListLoaded ?? this.notificationsListLoaded,
    );
  }
}
	  