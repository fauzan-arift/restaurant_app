import 'package:flutter/material.dart';
import 'package:restaurant_app/data/model/restaurant_detail.dart';
import 'package:restaurant_app/screen/detail/chip_list_section.dart';
import 'package:restaurant_app/screen/detail/description_section.dart';
import 'package:restaurant_app/screen/detail/restaurant_image.dart';
import 'package:restaurant_app/screen/detail/restaurant_info.dart';
import 'package:restaurant_app/screen/detail/review_section.dart';

class BodyOfDetailScreenWidget extends StatelessWidget {
  final RestaurantDetail restaurant;

  const BodyOfDetailScreenWidget({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RestaurantImage(pictureId: restaurant.pictureId),
          const SizedBox(height: 16),
          RestaurantInfo(
            name: restaurant.name,
            city: restaurant.city,
            address: restaurant.address,
            rating: restaurant.rating,
          ),
          const SizedBox(height: 16),
          if (restaurant.categories.isNotEmpty)
            ChipListSection(
              title: 'Kategori',
              items: restaurant.categories,
              iconBuilder: (_) => Icons.local_offer,
              colorBuilder: (_) => Colors.orange,
              labelBuilder: (item) => item.name,
            ),
          DescriptionSection(description: restaurant.description),
          const SizedBox(height: 16),
          if (restaurant.menus.foods.isNotEmpty)
            ChipListSection(
              title: 'Menu Makanan',
              items: restaurant.menus.foods,
              iconBuilder: (_) => Icons.restaurant_menu,
              colorBuilder: (_) => Colors.blue,
              labelBuilder: (item) => item.name,
            ),
          if (restaurant.menus.drinks.isNotEmpty)
            ChipListSection(
              title: 'Menu Minuman',
              items: restaurant.menus.drinks,
              iconBuilder: (_) => Icons.local_drink,
              colorBuilder: (_) => Colors.green,
              labelBuilder: (item) => item.name,
            ),
          ReviewSection(
            reviews: restaurant.customerReviews,
            restaurantId: restaurant.id,
          ),
        ],
      ),
    );
  }
}
