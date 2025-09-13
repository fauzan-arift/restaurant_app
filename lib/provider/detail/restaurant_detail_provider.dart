import 'package:flutter/widgets.dart';
import 'package:restaurant_app/data/api/api_services.dart';
import 'package:restaurant_app/static/restaurant_detail_result.dart';

class RestaurantDetailProvider extends ChangeNotifier {
  final ApiService _apiService;

  RestaurantDetailProvider(this._apiService);

  RestaurantDetailResultState _resultstate = RestaurantDetailNoneState();
  RestaurantDetailResultState get state => _resultstate;

  Future<void> fetchRestaurantDetail(String id) async {
    try {
      _resultstate = RestaurantDetailLoadingState();
      notifyListeners();

      final result = await _apiService.getRestaurantDetail(id);
      if (result.error) {
        _resultstate = RestaurantDetailErrorState(result.message);
      } else {
        _resultstate = RestaurantDetailHasDataState(result.restaurant);
      }
    } catch (e) {
      _resultstate = RestaurantDetailErrorState(e.toString());
    }
    notifyListeners();
  }
}
