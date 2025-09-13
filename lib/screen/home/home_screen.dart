import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/screen/home/restaurant_card_widget.dart';
import 'package:restaurant_app/screen/home/search_bar_widget.dart';
import 'package:restaurant_app/screen/error/error_state_widget.dart';
import 'package:restaurant_app/static/navigation_route.dart';
import 'package:restaurant_app/static/restaurant_list_result_state.dart';
import 'package:restaurant_app/static/error_message_helper.dart';
import 'package:restaurant_app/provider/home/restaurant_list_provider.dart';
import 'package:restaurant_app/screen/home/empty_state_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<RestaurantListProvider>().fetchRestaurantList();
    });
  }

  void _submitSearch(BuildContext context) {
    FocusScope.of(context).unfocus();
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      context.read<RestaurantListProvider>().fetchRestaurantList();
      return;
    }
    context.read<RestaurantListProvider>().search(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Restoran'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          SearchBarWidget(
            controller: _searchController,
            onSubmit: () => _submitSearch(context),
          ),
          Expanded(
            child: Consumer<RestaurantListProvider>(
              builder: (context, value, child) {
                final state = value.state;
                if (state is RestaurantListLoadingState) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is RestaurantListErrorState) {
                  return ErrorStateWidget(
                    message: ErrorMessageHelper.getErrorMessage(state.message),
                    onRetry: () {
                      _searchController.clear();
                      context
                          .read<RestaurantListProvider>()
                          .fetchRestaurantList();
                    },
                    retryButtonText: 'Muat Ulang',
                    icon: Icons.wifi_off,
                  );
                }
                if (state is RestaurantListHasDataState) {
                  if (state.restaurants.isEmpty) {
                    return EmptyStateWidget(
                      onReset: () {
                        FocusScope.of(context).unfocus();
                        _searchController.clear();
                        context
                            .read<RestaurantListProvider>()
                            .fetchRestaurantList();
                      },
                    );
                  }
                  return ListView.builder(
                    itemCount: state.restaurants.length,
                    itemBuilder: (context, index) {
                      final restaurant = state.restaurants[index];
                      return RestaurantCard(
                        restaurant: restaurant,
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          Navigator.pushNamed(
                            context,
                            NavigationRoute.detailRoute.name,
                            arguments: {'id': restaurant.id},
                          );
                        },
                      );
                    },
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}
