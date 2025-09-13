import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/provider/detail/restaurant_detail_provider.dart';
import 'package:restaurant_app/provider/favorite/favorite_state_provider.dart';
import 'package:restaurant_app/screen/detail/body_of_detail_screen_widget.dart';
import 'package:restaurant_app/screen/error/error_state_widget.dart';
import 'package:restaurant_app/static/restaurant_detail_result.dart';
import 'package:restaurant_app/static/error_message_helper.dart';

class DetailScreen extends StatefulWidget {
  final String restaurantId;

  const DetailScreen({super.key, required this.restaurantId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<RestaurantDetailProvider>().fetchRestaurantDetail(
        widget.restaurantId,
      );

      context.read<FavoriteStateProvider>().checkFavoriteStatus(
        widget.restaurantId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detail Restoran")),
      body: Consumer<RestaurantDetailProvider>(
        builder: (context, provider, child) {
          final state = provider.state;
          if (state is RestaurantDetailLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is RestaurantDetailHasDataState) {
            return BodyOfDetailScreenWidget(restaurant: state.restaurantDetail);
          }
          if (state is RestaurantDetailErrorState) {
            return ErrorStateWidget(
              message: ErrorMessageHelper.getErrorMessage(state.message),
              onRetry: () {
                provider.fetchRestaurantDetail(widget.restaurantId);
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

class FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onPressed;

  const FavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        color: isFavorite ? Colors.red : null,
      ),
      onPressed: onPressed,
    );
  }
}
