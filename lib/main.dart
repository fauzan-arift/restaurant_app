import 'package:flutter/material.dart';
import 'package:restaurant_app/data/api/api_services.dart';
import 'package:restaurant_app/data/local/local_like_database_service.dart';
import 'package:restaurant_app/provider/detail/add_review_provider.dart';
import 'package:restaurant_app/provider/detail/restaurant_detail_provider.dart';
import 'package:restaurant_app/provider/favorite/favorite_provider.dart';
import 'package:restaurant_app/provider/favorite/favorite_state_provider.dart';
import 'package:restaurant_app/provider/navigation_provider.dart';
import 'package:restaurant_app/provider/theme/theme_provider.dart';
import 'package:restaurant_app/screen/detail/detail_screen.dart';
import 'package:restaurant_app/screen/favorite/favorite_screen.dart';
import 'package:restaurant_app/screen/main_container.dart';
import 'package:restaurant_app/screen/settings/settings_screen.dart';
import 'package:restaurant_app/style/theme/restaurant_theme.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/provider/home/restaurant_list_provider.dart';
import 'package:restaurant_app/static/navigation_route.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Restaurant App',
          theme: RestaurantTheme.lightTheme,
          darkTheme: RestaurantTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          initialRoute: NavigationRoute.mainRoute.name,
          routes: {
            NavigationRoute.mainRoute.name: (context) => const MainContainer(),
            NavigationRoute.detailRoute.name: (context) {
              final args =
                  ModalRoute.of(context)?.settings.arguments
                      as Map<String, String>;
              final restaurantId = args['id'] ?? '';
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
