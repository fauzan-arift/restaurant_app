import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/provider/detail/restaurant_detail_provider.dart';
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detail Restoran")),
      body: Consumer<RestaurantDetailProvider>(
        builder: (context, value, child) {
          final state = value.state;
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
                value.fetchRestaurantDetail(widget.restaurantId);
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
