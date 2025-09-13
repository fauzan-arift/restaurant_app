import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/provider/favorite/favorite_provider.dart';
import 'package:restaurant_app/screen/home/restaurant_card_widget.dart';
import 'package:restaurant_app/static/navigation_route.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      Provider.of<FavoriteProvider>(context, listen: false).refreshFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restoran Favorit'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          SizedBox(height: 8),
          Expanded(
            child: Consumer<FavoriteProvider>(
              builder: (context, provider, child) {
                switch (provider.state) {
                  case FavoriteResultState.loading:
                    return const Center(child: CircularProgressIndicator());

                  case FavoriteResultState.hasData:
                    return ListView.builder(
                      itemCount: provider.favorites.length,
                      itemBuilder: (context, index) {
                        final restaurant = provider.favorites[index];
                        return RestaurantCard(
                          restaurant: restaurant,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              NavigationRoute.detailRoute.name,
                              arguments: {'id': restaurant.id},
                            ).then((_) {
                              // Refresh favorites when returning from detail screen
                              provider.refreshFavorites();
                            });
                          },
                        );
                      },
                    );

                  case FavoriteResultState.noData:
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.favorite_border,
                            color: Colors.grey,
                            size: 80,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Restoran Favorit Belum Ada',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    );

                  case FavoriteResultState.error:
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 60,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Terjadi Kesalahan',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            provider.message,
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              provider.refreshFavorites();
                            },
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
