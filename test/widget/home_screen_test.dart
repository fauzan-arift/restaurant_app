import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/provider/home/restaurant_list_provider.dart';
import 'package:restaurant_app/static/restaurant_list_result_state.dart';
import '../test_helpers.dart';

void main() {
  group('RestaurantListProvider Widget Tests', () {
    late MockApiService mockApiService;
    late RestaurantListProvider provider;

    setUp(() {
      mockApiService = MockApiService();
      provider = RestaurantListProvider(mockApiService);
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: ChangeNotifierProvider<RestaurantListProvider>.value(
          value: provider,
          child: Scaffold(
            body: Consumer<RestaurantListProvider>(
              builder: (context, provider, child) {
                final state = provider.state;
                if (state is RestaurantListLoadingState) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is RestaurantListErrorState) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: ${state.message}'),
                        ElevatedButton(
                          onPressed: () => provider.fetchRestaurantList(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                } else if (state is RestaurantListHasDataState) {
                  return ListView.builder(
                    itemCount: state.restaurants.length,
                    itemBuilder: (context, index) {
                      final restaurant = state.restaurants[index];
                      return ListTile(
                        title: Text(restaurant.name),
                        subtitle: Text(restaurant.city),
                      );
                    },
                  );
                }
                return const Center(child: Text('No Data'));
              },
            ),
          ),
        ),
      );
    }

    testWidgets(
      'should show loading indicator when provider state is loading',
      (tester) async {
        when(() => mockApiService.getRestaurantList()).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return TestDataFactory.successResponse;
        });

        await tester.pumpWidget(createTestWidget());
        provider.fetchRestaurantList();
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'should display list of restaurants when data is loaded successfully',
      (tester) async {
        when(
          () => mockApiService.getRestaurantList(),
        ).thenAnswer((_) async => TestDataFactory.successResponse);

        await tester.pumpWidget(createTestWidget());
        await provider.fetchRestaurantList();
        await tester.pumpAndSettle();

        expect(find.byType(ListView), findsOneWidget);
        expect(find.text('Melting Pot'), findsOneWidget);
        expect(find.text('Kafe Kita'), findsOneWidget);
        expect(find.text('Medan'), findsOneWidget);
        expect(find.text('Gorontalo'), findsOneWidget);
      },
    );

    testWidgets('should show error message and retry button when API fails', (
      tester,
    ) async {
      when(
        () => mockApiService.getRestaurantList(),
      ).thenThrow(Exception('Network error'));

      await tester.pumpWidget(createTestWidget());
      await provider.fetchRestaurantList();
      await tester.pumpAndSettle();

      expect(find.text('Error: Exception: Network error'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should retry loading when retry button is tapped', (
      tester,
    ) async {
      when(
        () => mockApiService.getRestaurantList(),
      ).thenThrow(Exception('Network error'));

      await tester.pumpWidget(createTestWidget());
      await provider.fetchRestaurantList();
      await tester.pumpAndSettle();

      expect(find.text('Retry'), findsOneWidget);

      when(
        () => mockApiService.getRestaurantList(),
      ).thenAnswer((_) async => TestDataFactory.successResponse);

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(find.text('Melting Pot'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('should show no data message when no restaurants available', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('No Data'), findsOneWidget);
    });
  });
}
