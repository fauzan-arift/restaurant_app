// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/provider/navigation_provider.dart';
import 'package:restaurant_app/screen/favorite/favorite_screen.dart';
import 'package:restaurant_app/screen/home/home_screen.dart';

class MainContainer extends StatelessWidget {
  const MainContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [const HomeScreen(), const FavoriteScreen()];

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
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                    ),
                    label: 'Restoran',
                    backgroundColor: Theme.of(context).cardColor,
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.favorite,
                      color: navigationProvider.currentIndex == 1
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                    ),
                    label: 'Favorit',
                    backgroundColor: Theme.of(context).cardColor,
                  ),
                ],
                currentIndex: navigationProvider.currentIndex,
                selectedItemColor: Theme.of(context).primaryColor,
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
