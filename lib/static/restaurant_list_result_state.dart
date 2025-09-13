import 'package:restaurant_app/data/model/restaurant.dart';

sealed class RestaurantListResultState {}

class RestaurantListNoneState extends RestaurantListResultState {}

class RestaurantListLoadingState extends RestaurantListResultState {}

class RestaurantListErrorState extends RestaurantListResultState {
  final String message;

  RestaurantListErrorState(this.message);
}

class RestaurantListHasDataState extends RestaurantListResultState {
  final List<Restaurant> restaurants;

  RestaurantListHasDataState(this.restaurants);
}