import 'package:flutter/foundation.dart';
import 'package:restaurant_app/data/local/local_like_database_service.dart';
import 'package:restaurant_app/data/model/restaurant.dart';

class FavoriteStateProvider extends ChangeNotifier {
  final LocalLikeDatabaseService databaseService;

  FavoriteStateProvider({required this.databaseService});

  final Map<String, bool> _favoriteStatus = {};

  bool isFavorite(String restaurantId) {
    return _favoriteStatus[restaurantId] ?? false;
  }

  Future<void> checkFavoriteStatus(String restaurantId) async {
    final isFavorite = await databaseService.isFavorite(restaurantId);
    _favoriteStatus[restaurantId] = isFavorite;
    notifyListeners();
  }

  Future<void> toggleFavorite(Restaurant restaurant) async {
    final restaurantId = restaurant.id;
    final currentStatus = _favoriteStatus[restaurantId] ?? false;

    _favoriteStatus[restaurantId] = !currentStatus;
    notifyListeners();

    if (!currentStatus) {
      await databaseService.insertFavorite(restaurant);
    } else {
      await databaseService.removeFavorite(restaurantId);
    }
  }
}
