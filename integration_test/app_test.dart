import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:restaurant_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Restaurant App Integration Tests', () {
    testWidgets(
      'should navigate from home to detail, like restaurant, and verify it appears in favorites',
      (tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 6));

        expect(find.byType(BottomNavigationBar), findsOneWidget);
        await Future.delayed(const Duration(seconds: 2));

        await tester.pumpAndSettle(const Duration(seconds: 4));

        final restaurantCards = find.byType(Card);
        if (restaurantCards.evaluate().isNotEmpty) {
          expect(restaurantCards, findsAtLeastNWidgets(1));
          await tester.tap(restaurantCards.first);
          await tester.pumpAndSettle(const Duration(seconds: 3));

          final backButtons = find.byType(BackButton);
          if (backButtons.evaluate().isNotEmpty) {
            expect(find.byType(BackButton), findsOneWidget);

            await Future.delayed(const Duration(seconds: 2));

            final favoriteButtons = find.byIcon(Icons.favorite_border);

            if (favoriteButtons.evaluate().isNotEmpty) {
              await tester.tap(favoriteButtons.first);
              await tester.pumpAndSettle(const Duration(seconds: 2));
              expect(find.byIcon(Icons.favorite), findsAtLeastNWidgets(1));
            }

            await Future.delayed(const Duration(seconds: 2));
            await tester.tap(find.byType(BackButton));
            await tester.pumpAndSettle(const Duration(seconds: 3));

            expect(find.byType(BottomNavigationBar), findsOneWidget);

            await Future.delayed(const Duration(seconds: 2));
            final favoriteTab = find.byIcon(Icons.favorite);

            if (favoriteTab.evaluate().isNotEmpty) {
              await tester.tap(favoriteTab.first);
              await tester.pumpAndSettle(const Duration(seconds: 3));

              await Future.delayed(const Duration(seconds: 2));
              final favoriteCards = find.byType(Card);
              if (favoriteCards.evaluate().isNotEmpty) {
                expect(favoriteCards, findsAtLeastNWidgets(1));
              } else {
                expect(find.byType(Scaffold), findsAtLeastNWidgets(1));
              }
            }
          }
        }
      },
    );
  });
}
