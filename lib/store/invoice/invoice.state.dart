import 'package:equatable/equatable.dart';

class InvoiceState extends Equatable {
  final bool loading;
  final String error;
  final Map invoiceList;
  final List invoiceListLocal;
  final int invoiceListLoaded;
  final bool invoiceListEndReached;
  final String invoiceStatusType;
  final bool invoiceCreated;
  final bool invoiceCreateLoading;
  final String selectedDate;
  final bool invoiceStatusUpdated;
  final bool invoiceStatusLoading;
  final bool invoiceDisputedStatusUpdated;

  const InvoiceState(
    this.loading, 
    this.error,
    this.invoiceList,
    this.invoiceListLoaded,
    this.invoiceListLocal,
    this.invoiceListEndReached,
    this.invoiceStatusType,
    this.invoiceCreated,
    this.invoiceCreateLoading,
    this.selectedDate,
    this.invoiceStatusUpdated,
    this.invoiceStatusLoading,
    this.invoiceDisputedStatusUpdated,
    );

  factory InvoiceState.initial() {
    return const InvoiceState(
      false, 
      '',
      {},
      0,
      [],
      false,
      '',
      false,
      false,
      '',
      false,
      false,
      false,
      );
  }

  @override
  List<Object> get props => [loading, error, invoiceList, invoiceListLoaded, invoiceListLocal, invoiceListEndReached, invoiceStatusType, invoiceCreated, invoiceCreateLoading, selectedDate, invoiceStatusUpdated, invoiceStatusLoading, invoiceDisputedStatusUpdated];

  @override
  bool operator ==(other) =>
    identical(this, other) ||
    other is InvoiceState &&
      runtimeType == other.runtimeType &&
      loading == other.loading &&
      error == other.error;

  @override
  int get hashCode =>
    super.hashCode ^ runtimeType.hashCode ^ loading.hashCode ^ error.hashCode;

  @override
  String toString() => "InvoiceState { loading: $loading,  error: $error, invoiceList: $invoiceList, invoiceListLoaded: $invoiceListLoaded, invoiceListLocal: $invoiceListLocal, invoiceListEndReached: $invoiceListEndReached, invoiceStatusType: $invoiceStatusType, invoiceCreated: $invoiceCreated, invoiceCreateLoading: $invoiceCreateLoading, selectedDate: $selectedDate, invoiceStatusUpdated: $invoiceStatusUpdated, invoiceStatusLoading: $invoiceStatusLoading}";

  InvoiceState copyWith({bool? loading, String? error, Map? invoiceList, int? invoiceListLoaded, List? invoiceListLocal, bool? invoiceListEndReached, String? invoiceStatusType, bool? invoiceCreated, bool? invoiceCreateLoading, String? selectedDate, bool? invoiceStatusUpdated, bool? invoiceStatusLoading, bool? invoiceDisputedStatusUpdated}) {
    return InvoiceState(
      loading ?? this.loading,
      error ?? this.error,
      invoiceList ?? this.invoiceList,
      invoiceListLoaded ?? this.invoiceListLoaded,
      invoiceListLocal ?? this.invoiceListLocal,
      invoiceListEndReached ?? this.invoiceListEndReached,
      invoiceStatusType ?? this.invoiceStatusType,
      invoiceCreated ?? this.invoiceCreated,
      invoiceCreateLoading ?? this.invoiceCreateLoading,
      selectedDate ?? this.selectedDate,
      invoiceStatusUpdated ?? this.invoiceStatusUpdated,
      invoiceStatusLoading ?? this.invoiceStatusLoading,
      invoiceDisputedStatusUpdated ?? this.invoiceDisputedStatusUpdated,
      
    );
  }
}