import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/notif/notification_service.dart';
import 'package:restaurant_app/provider/navigation_provider.dart';
import 'package:restaurant_app/screen/favorite/favorite_screen.dart';
import 'package:restaurant_app/screen/home/home_screen.dart';
import 'package:restaurant_app/screen/settings/settings_screen.dart';
import 'package:restaurant_app/static/navigation_route.dart';

class MainContainer extends StatefulWidget {
  final String? launchPayload;

  const MainContainer({super.key, this.launchPayload});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  late final NotificationService _notificationService;
  StreamSubscription<String?>? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    _notificationService = NotificationService();
    _configureSelectNotificationSubject();

    // Handle cold start navigation from notification
    if (widget.launchPayload != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleNotificationPayload(widget.launchPayload!);
      });
    }
  }

  void _configureSelectNotificationSubject() {
    _notificationSubscription = _notificationService.selectNotificationStream
        .listen((String? payload) {
          if (payload != null && mounted) {
            _handleNotificationPayload(payload);
          }
        });
  }

  void _handleNotificationPayload(String payload) {
    try {
      final data = jsonDecode(payload);
      final restaurantId = data['id'] as String?;
      if (restaurantId != null) {
        Navigator.pushNamed(
          context,
          NavigationRoute.detailRoute.name,
          arguments: {'id': restaurantId},
        );
      }
    } catch (e) {
      debugPrint('Error parsing notification payload: $e');
    }
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const HomeScreen(),
      const FavoriteScreen(),
      const SettingsScreen(),
    ];

    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, child) {
        return Scaffold(
          body: screens[navigationProvider.currentIndex],
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: BottomNavigationBar(
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.restaurant_menu,
                      color: navigationProvider.currentIndex == 0
                          ? Theme.of(context).brightness == Brightness.dark
                                ? Colors.lightBlueAccent
                                : Theme.of(context).primaryColor
                          : Colors.grey,
                    ),
                    label: 'Restoran',
                    backgroundColor: Theme.of(context).cardColor,
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.favorite,
                      color: navigationProvider.currentIndex == 1
                          ? Theme.of(context).brightness == Brightness.dark
                                ? Colors.lightBlueAccent
                                : Theme.of(context).primaryColor
                          : Colors.grey,
                    ),
                    label: 'Favorit',
                    backgroundColor: Theme.of(context).cardColor,
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.settings,
                      color: navigationProvider.currentIndex == 2
                          ? Theme.of(context).brightness == Brightness.dark
                                ? Colors.lightBlueAccent
                                : Theme.of(context).primaryColor
                          : Colors.grey,
                    ),
                    label: 'Pengaturan',
                    backgroundColor: Theme.of(context).cardColor,
                  ),
                ],
                currentIndex: navigationProvider.currentIndex,
                selectedItemColor:
                    Theme.of(context).brightness == Brightness.dark
                    ? Colors.lightBlueAccent
                    : Theme.of(context).primaryColor,
                unselectedItemColor: Colors.grey,
                selectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 12,
                ),
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                backgroundColor: Theme.of(context).cardColor,
                onTap: (index) => navigationProvider.setIndex(index),
              ),
            ),
          ),
        );
      },
    );
  }
}
