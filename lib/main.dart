import 'package:flutter/material.dart';
import 'package:restaurant_app/data/api/api_services.dart';
import 'package:restaurant_app/data/local/local_like_database_service.dart';
import 'package:restaurant_app/provider/detail/add_review_provider.dart';
import 'package:restaurant_app/provider/detail/restaurant_detail_provider.dart';
import 'package:restaurant_app/provider/favorite/favorite_provider.dart';
import 'package:restaurant_app/provider/favorite/favorite_state_provider.dart';
import 'package:restaurant_app/provider/navigation_provider.dart';
import 'package:restaurant_app/provider/theme/theme_provider.dart';
import 'package:restaurant_app/provider/reminder/reminder_provider.dart';
import 'package:restaurant_app/screen/detail/detail_screen.dart';
import 'package:restaurant_app/screen/favorite/favorite_screen.dart';
import 'package:restaurant_app/screen/main_container.dart';
import 'package:restaurant_app/screen/settings/settings_screen.dart';
import 'package:restaurant_app/style/theme/restaurant_theme.dart';
import 'package:restaurant_app/notif/notification_service.dart';
import 'package:restaurant_app/notif/background_service.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/provider/home/restaurant_list_provider.dart';
import 'package:restaurant_app/static/navigation_route.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService().initialize();
  await BackgroundService.initialize();

  final notificationService = NotificationService();
  final notificationAppLaunchDetails = await notificationService
      .getNotificationAppLaunchDetails();

  String? launchPayload;

  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    final notificationResponse =
        notificationAppLaunchDetails!.notificationResponse;
    if (notificationResponse?.payload != null) {
      launchPayload = notificationResponse!.payload;
    }
  }

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (context) => ApiService()),
        Provider(create: (context) => LocalLikeDatabaseService()),
        ChangeNotifierProvider(
          create: (context) =>
              RestaurantListProvider(context.read<ApiService>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              RestaurantDetailProvider(context.read<ApiService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => AddReviewProvider(context.read<ApiService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => FavoriteProvider(
            databaseService: context.read<LocalLikeDatabaseService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => FavoriteStateProvider(
            databaseService: context.read<LocalLikeDatabaseService>(),
          ),
        ),
        ChangeNotifierProvider(create: (context) => NavigationProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => ReminderProvider()),
      ],
      child: MainApp(launchPayload: launchPayload),
    ),
  );
}

class MainApp extends StatelessWidget {
  final String? launchPayload;

  const MainApp({super.key, this.launchPayload});

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Restaurant App',
          navigatorKey: navigatorKey,
          theme: RestaurantTheme.lightTheme,
          darkTheme: RestaurantTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          initialRoute: NavigationRoute.mainRoute.name,
          routes: {
            NavigationRoute.mainRoute.name: (context) {
              return MainContainer(launchPayload: launchPayload);
            },
            NavigationRoute.detailRoute.name: (context) {
              // Normal navigation with arguments
              final args =
                  ModalRoute.of(context)?.settings.arguments
                      as Map<String, String>?;
              final restaurantId = args?['id'] ?? '';
              return DetailScreen(restaurantId: restaurantId);
            },
            NavigationRoute.favoriteRoute.name: (context) =>
                const FavoriteScreen(),
            NavigationRoute.settingsRoute.name: (context) =>
                const SettingsScreen(),
          },
        );
      },
    );
  }
}
