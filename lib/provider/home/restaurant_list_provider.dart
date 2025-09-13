import 'package:flutter/widgets.dart';
import 'package:restaurant_app/data/api/api_services.dart';
import 'package:restaurant_app/static/restaurant_list_result_state.dart';

class RestaurantListProvider extends ChangeNotifier {
  final ApiService apiService;

  RestaurantListProvider(this.apiService);

  RestaurantListResultState _resultstate = RestaurantListNoneState();
  RestaurantListResultState get state => _resultstate;

  Future<void> fetchRestaurantList() async {
    try {
      _resultstate = RestaurantListLoadingState();
      notifyListeners();

      final result = await apiService.getRestaurantList();
      if (result.error) {
        _resultstate = RestaurantListErrorState(result.message);
        notifyListeners();
      } else {
        _resultstate = RestaurantListHasDataState(result.restaurants);
        notifyListeners();
      }
    } catch (e) {
      _resultstate = RestaurantListErrorState(e.toString());
      notifyListeners();
    }

    notifyListeners();
  }

  Future<void> search(String query) async {
    try {
      _resultstate = RestaurantListLoadingState();
      notifyListeners();

      final result = await apiService.searchRestaurants(query);
      if (result.error) {
        _resultstate = RestaurantListErrorState(result.message);
        notifyListeners();
      } else {
        _resultstate = RestaurantListHasDataState(result.restaurants);
        notifyListeners();
      }
    } catch (e) {
      _resultstate = RestaurantListErrorState(e.toString());
      notifyListeners();
    }

    notifyListeners();
  }
}
