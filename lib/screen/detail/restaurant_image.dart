import 'package:flutter/material.dart';

class RestaurantImage extends StatelessWidget {
  final String pictureId;
  const RestaurantImage({super.key, required this.pictureId});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Hero(
        tag: 'restaurant-$pictureId',
        child: Image.network(
          'https://restaurant-api.dicoding.dev/images/large/$pictureId',
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey[200],
            height: 200,
            child: const Icon(
              Icons.image_not_supported,
              size: 64,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
