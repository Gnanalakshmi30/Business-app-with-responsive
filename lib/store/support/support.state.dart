import 'package:equatable/equatable.dart';



class SupportState extends Equatable {
	final bool loading;
	final String error;
  final List supportList;
  final bool supportListLoaded;
  final bool supportCreateLoading;
  final bool supportCreated;


	const SupportState(
    this.loading, 
    this.error,
    this.supportList,
    this.supportListLoaded,
    this.supportCreateLoading,
    this.supportCreated,
    );

	factory SupportState.initial() {
    return const SupportState(
      false, 
      '',
      [],
      false,
      false,
      false,
      );
  }

  @override
  List<Object> get props => [loading, error, supportList, supportListLoaded, supportCreateLoading, supportCreated];

	@override
	bool operator ==(other) =>
		identical(this, other) ||
		other is SupportState &&
			runtimeType == other.runtimeType &&
			loading == other.loading &&
			error == other.error;

	@override
	int get hashCode =>
		super.hashCode ^ runtimeType.hashCode ^ loading.hashCode ^ error.hashCode;

	@override
	String toString() => "SupportState { loading: $loading,  error: $error, supportList: $supportList, supportListLoaded: $supportListLoaded, supportCreateLoading: $supportCreateLoading, supportCreated: $supportCreated}";

  SupportState copyWith({bool? loading, String? error, List? supportList, bool? supportListLoaded, bool? supportCreateLoading, bool? supportCreated}) {
    return SupportState(
      loading ?? this.loading,
      error ?? this.error,
      supportList ?? this.supportList,
      supportListLoaded ?? this.supportListLoaded,
      supportCreateLoading ?? this.supportCreateLoading,
      supportCreated ?? this.supportCreated,
    );
  }
}
	  