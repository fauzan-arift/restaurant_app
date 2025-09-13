import 'package:flutter/foundation.dart';
import 'package:restaurant_app/data/local/local_like_database_service.dart';
import 'package:restaurant_app/data/model/restaurant.dart';

enum FavoriteResultState { loading, hasData, noData, error }

class FavoriteProvider extends ChangeNotifier {
  final LocalLikeDatabaseService databaseService;

  FavoriteProvider({required this.databaseService}) {
    _getFavorites();
  }

  late FavoriteResultState _state;
  FavoriteResultState get state => _state;

  String _message = '';
  String get message => _message;

  List<Restaurant> _favorites = [];
  List<Restaurant> get favorites => _favorites;

  void _getFavorites() async {
    _state = FavoriteResultState.loading;
    notifyListeners();

    try {
      final favoriteList = await databaseService.getFavorites();
      if (favoriteList.isEmpty) {
        _state = FavoriteResultState.noData;
        _message = 'Anda belum memiliki restoran favorit';
        notifyListeners();
      } else {
        _state = FavoriteResultState.hasData;
        _favorites = favoriteList;
        notifyListeners();
      }
    } catch (e) {
      _state = FavoriteResultState.error;
      _message = 'Terjadi kesalahan: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<bool> isFavorite(String id) async {
    return await databaseService.isFavorite(id);
  }

  Future<void> addFavorite(Restaurant restaurant) async {
    try {
      await databaseService.insertFavorite(restaurant);
      _getFavorites();
    } catch (e) {
      _state = FavoriteResultState.error;
      _message = 'Gagal menambahkan ke favorit';
      notifyListeners();
    }
  }

  Future<void> removeFavorite(String id) async {
    try {
      await databaseService.removeFavorite(id);
      _getFavorites();
    } catch (e) {
      _state = FavoriteResultState.error;
      _message = 'Gagal menghapus dari favorit';
      notifyListeners();
    }
  }

  void refreshFavorites() {
    _getFavorites();
  }
}
