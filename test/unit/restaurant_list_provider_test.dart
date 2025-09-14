import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:restaurant_app/provider/home/restaurant_list_provider.dart';
import 'package:restaurant_app/static/restaurant_list_result_state.dart';
import '../test_helpers.dart';

void main() {
  group('RestaurantListProvider Unit Tests', () {
    late RestaurantListProvider provider;
    late MockApiService mockApiService;

    setUp(() {
      mockApiService = MockApiService();
      provider = RestaurantListProvider(mockApiService);
    });

    group('Initial State', () {
      test('should have initial state as RestaurantListNoneState', () {
        expect(provider.state, isA<RestaurantListNoneState>());
      });
    });

    group('Fetch Restaurant List - Success', () {
      test(
        'should return list of restaurants when API call is successful',
        () async {
          when(
            () => mockApiService.getRestaurantList(),
          ).thenAnswer((_) async => TestDataFactory.successResponse);

          await provider.fetchRestaurantList();

          expect(provider.state, isA<RestaurantListHasDataState>());

          final hasDataState = provider.state as RestaurantListHasDataState;
          expect(hasDataState.restaurants.length, 2);
          expect(hasDataState.restaurants[0].name, 'Melting Pot');
          expect(hasDataState.restaurants[1].name, 'Kafe Kita');

          verify(() => mockApiService.getRestaurantList()).called(1);
        },
      );

      test('should pass through loading state during API call', () async {
        final List<RestaurantListResultState> capturedStates = [];
        provider.addListener(() {
          capturedStates.add(provider.state);
        });

        when(
          () => mockApiService.getRestaurantList(),
        ).thenAnswer((_) async => TestDataFactory.successResponse);

  
        await provider.fetchRestaurantList();

        expect(capturedStates.length, greaterThanOrEqualTo(2));
        expect(capturedStates[0], isA<RestaurantListLoadingState>());
        expect(capturedStates.last, isA<RestaurantListHasDataState>());
      });
    });

    group('Fetch Restaurant List - Error', () {
      test(
        'should return error state when API call fails with exception',
        () async {
          when(
            () => mockApiService.getRestaurantList(),
          ).thenThrow(Exception('Network error'));

          await provider.fetchRestaurantList();

          expect(provider.state, isA<RestaurantListErrorState>());

          final errorState = provider.state as RestaurantListErrorState;
          expect(errorState.message, contains('Exception: Network error'));

          verify(() => mockApiService.getRestaurantList()).called(1);
        },
      );

      test(
        'should return error state when API returns error response',
        () async {

          when(
            () => mockApiService.getRestaurantList(),
          ).thenAnswer((_) async => TestDataFactory.errorResponse);

          await provider.fetchRestaurantList();

          expect(provider.state, isA<RestaurantListErrorState>());

          final errorState = provider.state as RestaurantListErrorState;
          expect(errorState.message, 'Restaurant not found');

          verify(() => mockApiService.getRestaurantList()).called(1);
        },
      );

      test('should handle different types of errors gracefully', () async {
        final testCases = [
          'Connection timeout',
          'Server error 500',
          'Not found 404',
          'Invalid JSON response',
        ];

        for (final errorMessage in testCases) {
          when(
            () => mockApiService.getRestaurantList(),
          ).thenThrow(Exception(errorMessage));

          await provider.fetchRestaurantList();

          expect(provider.state, isA<RestaurantListErrorState>());
          final errorState = provider.state as RestaurantListErrorState;
          expect(errorState.message, contains(errorMessage));
        }
      });
    });

    group('Search Functionality', () {
      test('should return search results when search is successful', () async {
        when(
          () => mockApiService.searchRestaurants('melting'),
        ).thenAnswer((_) async => TestDataFactory.successResponse);

        await provider.search('melting');

        expect(provider.state, isA<RestaurantListHasDataState>());

        final hasDataState = provider.state as RestaurantListHasDataState;
        expect(hasDataState.restaurants.isNotEmpty, true);

        verify(() => mockApiService.searchRestaurants('melting')).called(1);
      });

      test('should return error when search fails', () async {
        when(
          () => mockApiService.searchRestaurants('unknown'),
        ).thenThrow(Exception('Search failed'));

        await provider.search('unknown');

        expect(provider.state, isA<RestaurantListErrorState>());

        final errorState = provider.state as RestaurantListErrorState;
        expect(errorState.message, contains('Search failed'));
      });
    });
  });
}
