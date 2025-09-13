import 'package:flutter/material.dart';

class RestaurantInfo extends StatelessWidget {
  final String name;
  final String city;
  final String address;
  final double rating;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  const RestaurantInfo({
    super.key,
    required this.name,
    required this.city,
    required this.address,
    required this.rating,
    this.isFavorite = false,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (onFavoriteToggle != null)
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : null,
                ),
                onPressed: onFavoriteToggle,
              ),
          ],
        ),
        Row(
          children: [
            const Icon(Icons.location_on, color: Colors.blueGrey, size: 20),
            const SizedBox(width: 4),
            Text(
              '$city, $address',
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 20),
            const SizedBox(width: 4),
            Text(
              rating.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ],
    );
  }
}
