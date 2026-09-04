import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:farm_buddy/models/activity.dart';
import 'package:farm_buddy/models/enums.dart';

/// Sales the farmer has confirmed, newest first.
class SalesNotifier extends StateNotifier<List<SaleRecord>> {
  SalesNotifier() : super(const <SaleRecord>[]);

  void add(SaleRecord sale) => state = <SaleRecord>[sale, ...state];

  double get totalEarned =>
      state.fold<double>(0, (double sum, SaleRecord s) => sum + s.net);
}

final salesProvider =
    StateNotifierProvider<SalesNotifier, List<SaleRecord>>(
  (ref) => SalesNotifier(),
);

/// Transport the farmer has booked, newest first.
class BookingsNotifier extends StateNotifier<List<BookingRecord>> {
  BookingsNotifier() : super(const <BookingRecord>[]);

  void add(BookingRecord booking) =>
      state = <BookingRecord>[booking, ...state];
}

final bookingsProvider =
    StateNotifierProvider<BookingsNotifier, List<BookingRecord>>(
  (ref) => BookingsNotifier(),
);

/// How the market list is ordered. Defaults to the app's own recommendation.
final marketSortProvider =
    StateProvider<MarketSort>((ref) => MarketSort.bestValue);

/// The market highlighted by tapping a pin on the map, if any.
final focusedMarketIdProvider = StateProvider<String?>((ref) => null);
